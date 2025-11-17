package org.example;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.connector.kafka.sink.KafkaRecordSerializationSchema;
import org.apache.flink.connector.kafka.sink.KafkaSink;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

public class KafkaHighValuePurchaseFilterJob {

    private static final String BROKER_URL = "host.docker.internal:9092";
    public static void main(String[] args) throws Exception {
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        final ObjectMapper mapper = new ObjectMapper();

        KafkaSource<String> source = KafkaSource.<String>builder()
                .setBootstrapServers(BROKER_URL)
                .setTopics("purchases")
                .setGroupId("flink-consumer-group")
                .setStartingOffsets(OffsetsInitializer.earliest())
                .setValueOnlyDeserializer(new SimpleStringSchema())
                .build();

        KafkaSink<String> sink = KafkaSink.<String>builder()
                .setBootstrapServers(BROKER_URL)
                .setRecordSerializer(KafkaRecordSerializationSchema.builder()
                        .setTopic("high-value-purchases")
                        .setValueSerializationSchema(new SimpleStringSchema())
                        .build())
                .build();

        DataStream<String> input = env.fromSource(
                source,
                WatermarkStrategy.noWatermarks(),
                "KafkaSource");

        DataStream<String> filtered = input
                .filter(value -> {
                    try {
                        JsonNode node = mapper.readTree(value);
                        return node.has("price") && node.get("price").asDouble() > 100;
                    } catch (Exception e) {
                        // Log and skip malformed JSON
                        return false;
                    }
                });

        filtered.sinkTo(sink);

        env.execute("High-Value Purchases Filter Job");
    }
}
