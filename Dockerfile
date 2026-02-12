# ============================================
# Optimized Multi-Stage Dockerfile for Render Free Tier
# Addresses: build timeouts, memory limits, caching
# ============================================

# ============================================
# Stage 1: Frontend Build (Node.js + Gulp)
# ============================================
FROM node:18-alpine AS frontend-builder

WORKDIR /app

# Copy package files ONLY (better caching)
COPY package*.json ./

# Install dependencies with npm ci (faster, more reliable)
RUN npm ci --only=production --no-audit --prefer-offline

# Copy frontend source
COPY gulpfile.js ./
COPY src/main/resources/assets ./src/main/resources/assets

# Build frontend assets
RUN npx gulp build

# ============================================
# Stage 2: Backend Build (Maven + Java)
# ============================================
FROM maven:3.9-eclipse-temurin-17-alpine AS backend-builder

WORKDIR /app

# Copy Maven files ONLY (better caching)
COPY pom.xml ./

# Download dependencies ONLY (cached if pom.xml unchanged)
# Use --fail-never to handle transient network issues
RUN mvn dependency:go-offline -B --fail-never || true

# Copy source code
COPY src ./src

# Copy built frontend assets from stage 1
COPY --from=frontend-builder /app/src/main/resources/assets/dist ./src/main/resources/assets/dist

# Build JAR with optimizations for free tier
# -DskipTests: Skip tests to save time
# -T 1C: Use 1 thread per CPU core
# -Dmaven.compiler.fork=false: Reduce memory usage
RUN mvn clean package -DskipTests -B \
    -Dmaven.compiler.fork=false \
    -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false

# ============================================
# Stage 3: Runtime (Minimal Production Image)
# ============================================
FROM eclipse-temurin:17-jre-alpine

# Install wget for health checks (minimal)
RUN apk add --no-cache wget

WORKDIR /app

# Copy only the JAR and config (minimal image)
COPY --from=backend-builder /app/target/budgetapp-*.jar budgetapp.jar
COPY config.yml ./

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser

# Expose application port
EXPOSE 8080

# Health check using admin endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8081/healthcheck || exit 1

# Run with optimized JVM settings for free tier (512MB)
# -Xmx384m: Max heap 384MB (leave room for non-heap)
# -Xms192m: Initial heap 192MB
# -XX:+UseSerialGC: Lightweight GC for small heap
# -XX:MaxMetaspaceSize=128m: Limit metaspace
CMD ["java", \
    "-Xmx384m", \
    "-Xms192m", \
    "-XX:+UseSerialGC", \
    "-XX:MaxMetaspaceSize=128m", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-jar", "budgetapp.jar", \
    "server", "config.yml"]
