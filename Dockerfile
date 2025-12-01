# ====== 1. Build Stage ======
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

# Copier tout le projet
COPY . .

# Donner la permission au mvnw
RUN chmod +x mvnw

# Build du projet
RUN ./mvnw clean package -DskipTests


# ====== 2. Runtime Stage ======
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copier le jar compilé
COPY --from=builder /app/target/*.jar app.jar

# Exposer le port 8080 (classique Spring Boot)
EXPOSE 8080

# Lancer l'application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
