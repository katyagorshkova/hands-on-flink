# Hands-On with Flink – Part 1: Filtering Data from Kafka

This repository contains the code and setup for the first post in the **Hands-On with Flink** series.

The article is [here](https://medium.com/@katyagorshkova/hands-on-with-flink-part-1-filtering-data-from-kafka-7bd3754f0233)

We build a simple Flink job that:
- reads purchase events from a Kafka topic (`purchases`),
- filters out high-value purchases (`price > 100`),
- and writes them to another Kafka topic (`high-value-purchases`).

No theory, just a working pipeline using Flink + Kafka + Docker Compose.

---

## Project Structure

 - docker-compose.yml         # Flink + Kafka + AKHQ setu
 -  src/main/java/…            # Java code for the Flink job
 -  pom.xml                    # Maven config with dependencies

## 🚀 How to Run

### 1. Build the shaded JAR

Make sure you have Java + Maven installed.

`mvn clean package`

This creates target/flink-filter.jar

### 2. Bring the stack up

`docker compose up`

This brings up:
	•	Kafka
	•	Flink JobManager & TaskManager
	•	AKHQ (Kafka UI)

### 3. Access UIs
	•	Flink Web UI: http://localhost:8082
	•	AKHQ (Kafka UI): http://localhost:8087

## 🚀 How to Run on k8s
The article is [here](https://medium.com/@katyagorshkova/hands-on-with-flink-part-2-running-on-kubernetes-with-the-operator-cb8fc9737f5b)

Enable the kubernetes cluster.
### 1. Build the image and push to the local registry

`docker build -t localhost:5001/flink-job:latest .`

`docker push localhost:5001/flink-job:latest`

### 2. Install k8s operator

`helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-1.13.0`

`kubectl create ns flink`

`helm install flink-kubernetes-operator flink-operator-repo/flink-kubernetes-operator -n flink`

### 3. Run Flink cluster as application

`kubectl apply -f flink-filter-deployment.yaml -n flink`



