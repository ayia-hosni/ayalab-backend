FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
# The cache mount keeps ~/.m2 between builds (and between failed attempts), and
# the retry/TTL flags make downloads tolerate flaky connections to Maven Central.
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B clean package -DskipTests \
      -Dmaven.wagon.http.retryHandler.count=10 \
      -Dmaven.wagon.http.retryHandler.requestSentEnabled=true \
      -Daether.connector.http.connectionMaxTtl=25

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /build/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
