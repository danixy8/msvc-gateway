ARG MSVC_NAME=msvc-gateway

FROM openjdk:17.0-jdk-slim-buster as builder
ARG MSVC_NAME
WORKDIR /app/$MSVC_NAME

COPY ./pom.xml /app
COPY ./$MSVC_NAME/.mvn ./.mvn
COPY ./$MSVC_NAME/mvnw .
COPY ./$MSVC_NAME/pom.xml .

RUN ./mvnw dependency:go-offline

COPY ./$MSVC_NAME/src ./src

RUN ./mvnw clean package -DskipTests

FROM openjdk:17.0-jdk-slim-buster
ARG MSVC_NAME
WORKDIR /app
RUN mkdir ./logs

ARG TARGET_FOLDER=/app/$MSVC_NAME/target
COPY --from=builder $TARGET_FOLDER/msvc-gateway-0.0.1-SNAPSHOT.jar .
ARG PORT_APP=8090
ENV PORT $PORT_APP
EXPOSE $PORT
CMD ["java", "-jar", "msvc-gateway-0.0.1-SNAPSHOT.jar"]