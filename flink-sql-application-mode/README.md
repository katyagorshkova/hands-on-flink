# Flink SQL Kafka Application on Kubernetes

This small example runs one predefined Flink SQL pipeline as one Kubernetes application deployment:

```text
products topic -> products table -> price >= 50 -> expensive_products table -> expensive-products topic
```

It uses Apache Flink 1.20.5 with Java 17, Flink Kubernetes Operator 1.12, and `flink-sql-connector-kafka` 3.4.0-1.20. The connector version is the release built for the Flink 1.20 line. All Kubernetes resources in the example use the `flink` namespace.

## What the Example Demonstrates

You do not create a Flink session cluster. A single `FlinkDeployment` makes a dedicated application cluster and starts `SqlRunner` as its application entry point. SQL mounted from a ConfigMap registers one Kafka source table and one Kafka sink table; its one filtering `INSERT` submits one continuously running streaming job.

The runner image is generic. Another predefined SQL application can use the same image by mounting a different SQL file and passing its path to the runner.

## Why Use a SQL Runner

A `FlinkDeployment` in application mode starts a JAR application. `SqlRunner` bridges that model to SQL stored outside the image: it reads the mounted file, executes its DDL in order, submits the final streaming insert, and waits for that job.

The runner requires one file argument and rejects missing or unreadable files. Its intentionally small parser supports multiline statements, empty statements, semicolons inside single-quoted values, and SQL-style escaped quotes (`''`). It is not a complete SQL lexer: complicated comments, quoted identifiers containing semicolons, dollar quoting, and unusual dialect-specific escaping are outside this example's scope.

## Why Store SQL in a ConfigMap

The SQL is not baked into the runner image, remains visible as Kubernetes configuration, and lets the same image run different predefined applications. [`kubernetes/sql-configmap.yaml`](kubernetes/sql-configmap.yaml) is the sole source of truth: edit the SQL directly under `data.job.sql` in that manifest.

ConfigMaps are not a complete application lifecycle mechanism. Updating one does not restart an existing Flink application or change the file already projected into the runner process. This demo uses stateless upgrades, so a redeployment starts with empty operator-managed application state.

## Kafka Connectivity

The SQL connects to `host.docker.internal:9092`. In this Docker Desktop example, Kafka runs in Docker Compose outside Kubernetes and advertises that host-reachable listener to the Flink pods. Edit the SQL in the ConfigMap if your broker has another reachable address.

`localhost:9092` normally points back to the JobManager or TaskManager pod, not to Kafka. Kafka's advertised listeners must return addresses reachable from those pods. Kubernetes Service DNS names are preferable for in-cluster Kafka. Network policies must allow Flink pod egress to the broker; restricted environments may need explicit IP-based egress rules for external Kafka.

This introductory setup has no authentication. If authentication is required, mount credentials from Kubernetes Secrets and follow the platform's existing security conventions—do not embed credentials in the SQL ConfigMap.

## Prerequisites

- Maven and Java 17 for a local build
- Docker to run Kafka, build the custom image, and host a local registry on port 5001
- Kubernetes with Apache Flink Kubernetes Operator 1.12 installed and watching the `flink` namespace
- Kafka reachable at `host.docker.internal:9092` from that namespace
- `kubectl` configured for the cluster

The `flink` namespace and the `flink` service account must already exist with the permissions required by the operator. Operator installations commonly create these resources; adapt the service account name and RBAC to your cluster when necessary.

## Build

```bash
mvn clean package
docker run -d --restart unless-stopped --name flink-blog-registry \
  -p 5001:5000 registry:2
docker build -t localhost:5001/flink-sql-runner:latest .
docker push localhost:5001/flink-sql-runner:latest
```

The Maven build creates `target/flink-sql-runner.jar` and resolves `target/connectors/flink-sql-connector-kafka-3.4.0-1.20.jar` from Maven Central. The final image places them at `/opt/flink/usrlib/flink-sql-runner.jar` and `/opt/flink/lib/flink-sql-connector-kafka-3.4.0-1.20.jar`. Flink runtime libraries remain `provided` and are not packaged into the runner JAR. The official Flink distribution supplies the JSON table format.

## Prepare Kafka

Start the external Kafka broker and create both topics from its container:

```bash
docker compose up -d kafka

docker compose exec kafka \
  kafka-topics --bootstrap-server kafka:29092 --create \
  --if-not-exists --topic products --partitions 1 --replication-factor 1

docker compose exec kafka \
  kafka-topics --bootstrap-server kafka:29092 --create \
  --if-not-exists --topic expensive-products --partitions 1 --replication-factor 1
```

Produce sample JSON values:

```bash
docker compose exec -T kafka \
  kafka-console-producer --bootstrap-server kafka:29092 --topic products <<'EOF'
{"product_id":1,"product_name":"apple","price":20.00}
{"product_id":2,"product_name":"coffee-machine","price":120.00}
{"product_id":3,"product_name":"book","price":45.00}
{"product_id":4,"product_name":"monitor","price":250.00}
EOF
```

## Deploy

After pushing the image to `localhost:5001`, apply the resources:

```bash
kubectl -n flink apply -f kubernetes/sql-configmap.yaml
kubectl -n flink apply -f kubernetes/flink-deployment.yaml
```

There is one `FlinkDeployment`, one application cluster, and one streaming job. There is no session cluster or SQL Gateway.

## Verify

```bash
kubectl -n flink get flinkdeployments
kubectl -n flink get pods
kubectl -n flink describe flinkdeployment products-filter

kubectl -n flink exec <jobmanager-pod> -- \
  cat /opt/flink/sql/job.sql
kubectl -n flink logs <jobmanager-pod>
kubectl -n flink logs <taskmanager-pod>
```

The primary functional check is the output topic:

```bash
docker compose exec kafka \
  kafka-console-consumer --bootstrap-server kafka:29092 \
  --topic expensive-products --from-beginning
```

Ignoring JSON field order, the output should contain only:

```json
{"product_id":2,"product_name":"coffee-machine","price":120.00}
{"product_id":4,"product_name":"monitor","price":250.00}
```

## Known Limitations

- The runner is designed for setup statements followed by one final streaming `INSERT`; it is not an interactive SQL client.
- The small SQL splitter has the quoting and comment limitations described above.
- SQL embedded in YAML must retain valid block indentation under `data.job.sql`.
- The sample assumes an unauthenticated `kafka` Service in the `flink` namespace and a single-broker replication factor of one.
- A real production application usually needs checkpointing, stateful upgrades, stronger RBAC, immutable image tags, security configuration, and operational monitoring; those are deliberately outside this deployment-model demonstration.
