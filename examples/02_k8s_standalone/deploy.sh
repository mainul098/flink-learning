#!/bin/bash
# Deployment script for Flink Word Count example with Kafka

set -e

echo "==========================================="
echo "Flink Word Count with Kafka Deployment"
echo "==========================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ docker not found. Please install docker/colima first."
    exit 1
fi

echo "📦 Building Docker image with Kafka connector..."
docker build -t flink-word-count:latest .

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed"
    exit 1
fi

echo ""
echo "🚀 Deploying infrastructure (Kafka, Zookeeper, Kafka UI)..."
kubectl apply -f deployment.yaml

echo ""
echo "⏳ Waiting for Zookeeper to be ready..."
kubectl wait --for=condition=ready pod -l app=zookeeper --timeout=120s

echo ""
echo "⏳ Waiting for Kafka to be ready..."
kubectl wait --for=condition=ready pod -l app=kafka --timeout=120s

echo ""
echo "📝 Creating Kafka topic 'input-text'..."
kubectl exec kafka-0 -- kafka-topics --create --topic input-text --bootstrap-server localhost:9092 --partitions 4 --replication-factor 1 --if-not-exists

echo ""
echo "📨 Sending test messages to Kafka..."
kubectl exec kafka-0 -- bash -c "echo -e 'hello world\nhello flink\nflink kubernetes operator\nhello kubernetes\nflink streaming\napache flink is great\nkubernetes is powerful\nhello apache flink\nstreaming data processing\nreal time analytics' | kafka-console-producer --broker-list localhost:9092 --topic input-text"

echo ""
echo "🎯 Starting Flink Word Count job..."
# Delete pod if it already exists
kubectl delete pod flink-word-count --ignore-not-found=true

# Wait a moment for cleanup
sleep 2

# Start the job
kubectl apply -f deployment.yaml

echo ""
echo "⏳ Waiting for Kafka UI to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/kafka-ui

echo ""
echo "🌐 Starting Kafka UI port-forward on port 9090..."
kubectl port-forward svc/kafka-ui 9090:8080 > /dev/null 2>&1 &
KAFKA_UI_PID=$!
echo "   Kafka UI available at: http://localhost:9090"
echo "   Port-forward PID: $KAFKA_UI_PID"

echo ""
echo "⏳ Waiting for Flink job to start (15 seconds)..."
sleep 15

echo ""
echo "✅ Deployment complete!"
echo ""
echo "==========================================="
echo "View Results:"
echo "==========================================="
echo ""
echo "1. View word count output:"
echo "   kubectl logs flink-word-count | grep '^[12]>' | sort"
echo ""
echo "2. Follow job logs in real-time:"
echo "   kubectl logs -f flink-word-count"
echo ""
echo "3. Check job status:"
echo "   kubectl get pod flink-word-count"
echo ""
echo "4. Send more test messages to Kafka:"
echo "   kubectl exec -it kafka-0 -- kafka-console-producer --broker-list localhost:9092 --topic input-text"
echo "   (Type messages and press Ctrl-D when done)"
echo ""
echo "5. Consume messages from Kafka:"
echo "   kubectl exec -it kafka-0 -- kafka-console-consumer --bootstrap-server localhost:9092 --topic input-text --from-beginning"
echo ""
echo "6. Access Kafka UI (already running):"
echo "   http://localhost:9090"
echo "   Stop port-forward: kill $KAFKA_UI_PID"
echo ""
echo "==========================================="
