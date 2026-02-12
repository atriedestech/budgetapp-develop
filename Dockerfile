# ============================================
# Multi-Stage Dockerfile for Render Free Tier
# Java 8 | Dropwizard | Gulp | PostgreSQL
# ============================================

# ============================================
# Stage 1: Frontend Build
# ============================================
FROM node:20-alpine AS frontend-builder

WORKDIR /build

# Copy package files first for layer caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy frontend source files
COPY gulpfile.js ./
COPY src/main/resources/app ./src/main/resources/app/

# Build production assets
RUN npm run build

# Verify build output exists
RUN ls -la src/main/resources/app/assets/css/

# ============================================
# Stage 2: Backend Build
# ============================================
FROM maven:3.8-eclipse-temurin-8 AS backend-builder

WORKDIR /build

# Copy pom.xml first for dependency caching
COPY pom.xml ./

# Download dependencies (cached until pom.xml changes)
RUN mvn dependency:go-offline -B || true

# Copy project source files
COPY src ./src
COPY config ./config
COPY database ./database

# Copy built frontend assets from Stage 1
COPY --from=frontend-builder /build/src/main/resources/app ./src/main/resources/app

# Build the application (skip tests)
RUN mvn clean package -DskipTests -B \
    -Dmaven.compiler.fork=false \
    -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false

# Verify the JAR was created
RUN ls -lh target/budgetapp.jar

# ============================================
# Stage 3: Runtime
# ============================================
FROM eclipse-temurin:8-jre-alpine

# Install wget for health checks
RUN apk add --no-cache wget

# Create non-root user
RUN addgroup -S budgetapp && adduser -S budgetapp -G budgetapp

WORKDIR /app

# Copy JAR and config
COPY --from=backend-builder --chown=budgetapp:budgetapp /build/target/budgetapp.jar ./budgetapp.jar
COPY --chown=budgetapp:budgetapp config/config.yml ./config.yml

# Switch to non-root user
USER budgetapp

# Expose application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8081/healthcheck || exit 1

# Run the application
# Copy startup script
COPY start.sh .
RUN chmod +x start.sh

# Run the application via script
CMD ["./start.sh"]
