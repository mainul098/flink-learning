# Flink Word Count with Kafka on Kubernetes

This example demonstrates a PyFlink streaming application that reads from Kafka and performs real-time word counting.

## 📁 Files

- **`simple_word_count.py`** - PyFlink application that reads from Kafka and counts words
- **`Dockerfile`** - Container image with PyFlink and Kafka connector JAR
- **`deployment.yaml`** - Complete deployment manifest (Kafka + Zookeeper + Kafka UI + Flink job)
- **`deploy.sh`** - Automated deployment script

## 🚀 Quick Start

### Deploy Everything
```bash
./deploy.sh
```

This script will:
1. Build the Docker image with PyFlink and Kafka connector
2. Deploy Zookeeper, Kafka, and Kafka UI
3. Create the `input-text` Kafka topic
4. Send test messages to Kafka
5. Start Kafka UI port-forward on port 9090
6. Start the Flink word count job

### View Results
```bash
# View word count output
kubectl logs flink-word-count | grep '^[1-4]>' | tail -20

# Follow logs in real-time
kubectl logs -f flink-word-count

# Check pod status
kubectl get pods
```

## 📊 What It Does

The application:
1. **Reads** messages from Kafka topic `input-text`
2. **Splits** text into individual words
3. **Counts** word occurrences in real-time
4. **Prints** results to stdout (visible in pod logs)

**Data Flow:**
```
Kafka Topic "input-text"
    ↓
  Source (4 parallel tasks)
    ↓
  FlatMap (split words)
    ↓
  Map (word, 1)
    ↓
  KeyBy (partition by word)
    ↓
  Reduce (count per word)
    ↓
  Print (to logs)
```

## 🧪 Testing

### Send Custom Messages to Kafka
```bash
kubectl exec -it kafka-0 -- kafka-console-producer \
  --broker-list localhost:9092 \
  --topic input-text
```
Type your messages and press Ctrl-D when done.

### Consume Messages from Kafka
```bash
kubectl exec -it kafka-0 -- kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic input-text \
  --from-beginning
```

### View Kafka Topics
```bash
kubectl exec kafka-0 -- kafka-topics \
  --list \
  --bootstrap-server localhost:9092
```

### Access Kafka UI
The deploy script automatically starts Kafka UI on http://localhost:9090

Manually start port-forward:
```bash
kubectl port-forward svc/kafka-ui 9090:8080 &
```

## 📝 Example Output

```
Flink Word Count Job Starting
===================================
Kafka Brokers: kafka:9092
Kafka Topic: input-text

3> (hello,1)
1> (flink,1)
3> (hello,2)
1> (flink,2)
3> (kubernetes,1)
1> (flink,3)
3> (hello,3)
1> (apache,1)
1> (flink,4)
...
```

The numbers (1>, 2>, 3>, 4>) indicate which parallel task processed each word.

## 🛠️ Configuration

**Kafka Settings** (in `simple_word_count.py`):
- Bootstrap servers: `kafka:9092`
- Topic: `input-text`
- Consumer group: `flink-word-count`
- Partitions: 4

**Flink Settings**:
- Parallelism: 4
- Checkpointing: Every 60 seconds
- State backend: RocksDB

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete -f deployment.yaml

# Or delete individually
kubectl delete pod flink-word-count
kubectl delete deployment kafka-ui
kubectl delete statefulset kafka zookeeper
kubectl delete service kafka kafka-ui zookeeper

# Stop Kafka UI port-forward (check PID with: jobs)
kill %1  # or use specific PID
```

## 📚 Architecture

**Components:**
- **Zookeeper**: Coordination service for Kafka
- **Kafka**: Message broker with 1 broker, 1 topic (4 partitions)
- **Kafka UI**: Web-based UI for monitoring Kafka (http://localhost:9090)
- **Flink Job**: PyFlink application running in a pod

**Why this architecture?**
- **Stateless Flink**: Job runs in a simple pod (not using Flink Kubernetes Operator for simplicity)
- **Direct execution**: PyFlink runs directly with embedded Flink runtime
- **Kafka connector**: JAR loaded at build time for Kafka integration

## 🔍 Troubleshooting

**Pod not starting:**
```bash
kubectl describe pod flink-word-count
kubectl logs flink-word-count
```

**Kafka connection issues:**
```bash
# Check if Kafka is ready
kubectl get pods -l app=kafka

# Test Kafka connectivity
kubectl exec flink-word-count -- nc -zv kafka 9092
```

**No word counts appearing:**
```bash
# Verify messages are in Kafka
kubectl exec kafka-0 -- kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic input-text \
  --from-beginning \
  --max-messages 10
```
