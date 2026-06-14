FROM flink:2.1.2-java17

USER root

ARG FLINK_VERSION=2.1.2
ARG KAFKA_CONNECTOR_VERSION=4.0.1-2.0
ARG KAFKA_CLIENTS_VERSION=3.9.0

# Kafka connector
ADD https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/${KAFKA_CONNECTOR_VERSION}/flink-connector-kafka-${KAFKA_CONNECTOR_VERSION}.jar /opt/flink/lib/

ADD https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/${KAFKA_CLIENTS_VERSION}/kafka-clients-${KAFKA_CLIENTS_VERSION}.jar /opt/flink/lib/

# Flink AI / OpenAI model connector for CREATE MODEL + ML_PREDICT
ADD https://repo1.maven.org/maven2/org/apache/flink/flink-model-openai/${FLINK_VERSION}/flink-model-openai-${FLINK_VERSION}.jar /opt/flink/lib/

# Fix ownership
RUN chown flink:flink /opt/flink/lib/*.jar

USER flink