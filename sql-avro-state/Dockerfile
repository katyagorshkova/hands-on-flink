FROM flink:1.20-java17

USER root 

# Kafka connector
ADD https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/4.0.0-2.0/flink-connector-kafka-4.0.0-2.0.jar /opt/flink/lib/

ADD https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.9.0/kafka-clients-3.9.0.jar /opt/flink/lib/

# Avro + Schema Registry
ADD https://repo1.maven.org/maven2/org/apache/flink/flink-sql-avro-confluent-registry/1.20.3/flink-sql-avro-confluent-registry-1.20.3.jar \
    /opt/flink/lib/

# Fix ownership
RUN chown flink:flink /opt/flink/lib/*.jar

# S3 plugin
RUN mkdir -p /opt/flink/plugins/s3 && \
    cp /opt/flink/opt/flink-s3-fs-hadoop-*.jar /opt/flink/plugins/s3/ && \
    chown -R flink:flink /opt/flink/plugins

USER flink

