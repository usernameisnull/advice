#FROM docker.m.daocloud.io/library/openjdk:11.0.15 AS builder
FROM registry.cn-hangzhou.aliyuncs.com/mabing/adservice:v1.0 AS builder

WORKDIR /app/

COPY ./ ./
RUN chmod +x ./mvnw
RUN ./mvnw clean install package -DskipTests

# -----------------------------------------------------------------------------

FROM docker.m.daocloud.io/library/openjdk:11.0.15-jre

WORKDIR /app/

COPY --from=builder /app/target/adservice-springcloud-1.0-SNAPSHOT.jar ./
COPY --from=builder /app/jmx_prometheus_javaagent-0.17.0.jar ./
COPY --from=builder /app/prometheus-jmx-config.yaml ./

RUN set -ex; \
    curl -L -O https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.19.2/opentelemetry-javaagent.jar;

ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317 \
    OTEL_RESOURCE_ATTRIBUTES=service.name=adservice-springcloud \
    JAVA_TOOL_OPTIONS=-javaagent:opentelemetry-javaagent.jar

EXPOSE 8081 8999 8080 8888

ENTRYPOINT java $JAVA_OPTS -jar adservice-springcloud-1.0-SNAPSHOT.jar
