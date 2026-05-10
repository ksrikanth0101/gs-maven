
# Stage 1: Build the application using Maven
FROM maven:3.9-eclipse-temurin-17 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the build configuration file first to cache dependencies
COPY pom.xml .

# Fetch all project dependencies (cached unless pom.xml changes)
RUN mvn dependency:go-offline -B

# Copy the application source code
COPY src ./src

# Compile and package the application into a JAR file
RUN mvn clean package -DskipTests

# Stage 2: Create the minimal runtime image
FROM eclipse-temurin:17-jre-alpine

# Create a non-root system user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the active container user
USER appuser

# Set runtime working directory
WORKDIR /app

# Copy only the compiled JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the application network port
EXPOSE 8080

# Execute the Java application
ENTRYPOINT ["java", "-jar", "app.jar"]
