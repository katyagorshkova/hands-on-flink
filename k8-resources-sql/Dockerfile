FROM flink:1.20-java17

USER root 

# Add Kafka connector
ADD https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/4.0.0-2.0/flink-connector-kafka-4.0.0-2.0.jar /opt/flink/lib/

# Add JSON format
ADD https://repo1.maven.org/maven2/org/apache/flink/flink-json/2.0.0/flink-json-2.0.0.jar /opt/flink/lib/

ADD https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.9.0/kafka-clients-3.9.0.jar /opt/flink/lib/

RUN chown flink:flink /opt/flink/lib/*.jar

USER flink 