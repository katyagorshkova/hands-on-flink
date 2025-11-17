FROM flink:2.0.0-scala_2.12-java21

# Add the required Flink dependencies
RUN wget -P /opt/flink/lib https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-kafka/4.0.0-2.0/flink-connector-kafka-4.0.0-2.0.jar && \ 
    wget -P /opt/flink/lib https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.9.0/kafka-clients-3.9.0.jar

# RUN wget -P /opt/flink/lib https://jdbc.postgresql.org/download/postgresql-42.7.4.jar && \
#     wget -P /opt/flink/lib https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-jdbc/3.3.0-1.20/flink-connector-jdbc-3.3.0-1.20.jar
RUN echo "classloader.resolve-order: parent-first" >> /opt/flink/conf/config.yaml
