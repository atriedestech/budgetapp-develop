# ============================================
# Stage 1: Frontend Build
# Purpose: Build production-ready frontend assets (minified CSS/JS)
# ============================================
FROM node:20-alpine AS frontend-builder

# Set working directory
WORKDIR /build

# Copy package files first for better layer caching
# This layer is cached unless package.json or package-lock.json changes
COPY package.json package-lock.json ./

# Install dependencies using npm ci for deterministic builds
# - npm ci is faster than npm install
# - Uses exact versions from package-lock.json
# - Automatically removes node_modules before installing
RUN npm ci --only=production

# Copy frontend source files
COPY gulpfile.js ./
COPY src/main/resources/app ./src/main/resources/app/

# Build production assets (minified CSS)
# This generates optimized CSS files in src/main/resources/app/assets/css/
RUN npm run build

# Verify build output exists
RUN ls -la src/main/resources/app/assets/css/

# ============================================
# Stage 2: Backend Build
# Purpose: Compile Java code and create shaded JAR
# ============================================
FROM maven:3.8-eclipse-temurin-8 AS backend-builder

# Set working directory
WORKDIR /build

# Copy pom.xml first for better layer caching
# This layer is cached unless pom.xml changes
COPY pom.xml ./

# Download all Maven dependencies and cache them
# This step is cached until pom.xml changes, saving significant build time
RUN mvn dependency:go-offline -B

# Copy project source files
COPY src ./src
COPY config ./config
COPY database ./database

# Copy the built frontend assets from Stage 1
# The shaded JAR will package these resources
COPY --from=frontend-builder /build/src/main/resources/app ./src/main/resources/app

# Build the application (skip tests for production build)
# Output: target/budgetapp.jar (shaded JAR with all dependencies)
RUN mvn clean package -DskipTests -B

# Verify the JAR was created
RUN ls -lh target/budgetapp.jar

# ============================================
# Stage 3: Runtime
# Purpose: Minimal, secure runtime environment
# ============================================
FROM eclipse-temurin:8-jre-alpine

# Install wget for health checks
RUN apk add --no-cache wget

# Create non-root user and group for running the application
# Security best practice: never run applications as root
RUN addgroup -S budgetapp && adduser -S budgetapp -G budgetapp

# Set working directory
WORKDIR /app

# Copy the shaded JAR from Stage 2
# --chown ensures the file is owned by the budgetapp user
COPY --from=backend-builder --chown=budgetapp:budgetapp /build/target/budgetapp.jar ./budgetapp.jar

# Copy configuration file
COPY --chown=budgetapp:budgetapp config/config.yml ./config.yml

# Switch to non-root user
# All subsequent commands and the application will run as this user
USER budgetapp

# Expose application port (8080)
# Admin port (8081) is NOT exposed for security - only accessible via docker exec
EXPOSE 8080

# Health check using the admin health endpoint
# Docker/orchestrators can use this to detect unhealthy containers
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8081/healthcheck || exit 1

# Run the application
CMD ["java", "-jar", "budgetapp.jar", "server", "config.yml"]

