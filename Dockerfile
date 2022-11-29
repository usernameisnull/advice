FROM docker.m.daocloud.io/library/openjdk:11.0.15 AS builder

WORKDIR /app/

COPY ./ ./
RUN chmod +x ./mvnw
RUN ./mvnw clean install package -DskipTests
