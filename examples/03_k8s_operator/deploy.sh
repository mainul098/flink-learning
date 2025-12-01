#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Flink Kubernetes Operator Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Install CRDs for Flink Operator
echo -e "${GREEN}[1/7] Installing Flink Operator CRDs...${NC}"
kubectl apply -f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-1.7/helm/flink-kubernetes-operator/crds/flinkdeployments.flink.apache.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-1.7/helm/flink-kubernetes-operator/crds/flinksessionjobs.flink.apache.org-v1.yml
echo ""

# Step 2: Install Flink Operator
echo -e "${GREEN}[2/7] Installing Flink Kubernetes Operator...${NC}"
kubectl apply -f operator-install.yaml
echo ""

# Wait for operator to be ready
echo -e "${YELLOW}Waiting for operator to be ready...${NC}"
kubectl wait --for=condition=available --timeout=120s deployment/flink-kubernetes-operator -n flink-operator-system
echo ""

# Step 3: Deploy infrastructure (Kafka, Zookeeper, etc.)
echo -e "${GREEN}[3/7] Deploying infrastructure (Kafka, Zookeeper, Kafka UI)...${NC}"
kubectl apply -f infrastructure.yaml
echo ""

# Wait for Zookeeper
echo -e "${YELLOW}Waiting for Zookeeper to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=zookeeper --timeout=120s
echo ""

# Wait for Kafka
echo -e "${YELLOW}Waiting for Kafka to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=kafka --timeout=120s
echo ""

# Step 4: Build Docker image
echo -e "${GREEN}[4/7] Building Docker image...${NC}"
docker build -t flink-word-count:latest .
echo ""

# Load image into colima (if using colima)
if command -v colima &> /dev/null; then
    echo -e "${YELLOW}Image available in colima context${NC}"
else
    echo -e "${YELLOW}Loading image into kind/minikube (if needed)...${NC}"
    # For kind: kind load docker-image flink-word-count:latest
    # For minikube: minikube image load flink-word-count:latest
fi
echo ""

# Step 5: Create Kafka topic and seed data
echo -e "${GREEN}[5/7] Creating Kafka topic and sending test messages...${NC}"
sleep 5  # Give Kafka a moment to fully initialize

# Create topic
kubectl exec kafka-0 -- kafka-topics \
  --create \
  --if-not-exists \
  --topic input-text \
  --partitions 4 \
  --replication-factor 1 \
  --bootstrap-server localhost:9092 2>/dev/null || echo "Topic may already exist"

# Send test messages
echo -e "${YELLOW}Sending test messages to Kafka...${NC}"
kubectl exec -i kafka-0 -- kafka-console-producer \
  --broker-list localhost:9092 \
  --topic input-text << EOF
Hello Flink Kubernetes Operator
Apache Flink is a powerful stream processing framework
Kubernetes makes deployment and scaling easy
Flink Operator manages Flink clusters automatically
This is a production ready deployment
Hello again from the Flink world
Streaming data processing with Flink
Real time analytics with Apache Flink
EOF
echo ""

# Step 6: Deploy FlinkDeployment
echo -e "${GREEN}[6/7] Deploying Flink application...${NC}"
kubectl apply -f flink-deployment.yaml
echo ""

# Wait for Flink deployment to start
echo -e "${YELLOW}Waiting for Flink JobManager to be ready...${NC}"
sleep 10
kubectl wait --for=condition=ready pod -l app=word-count-app,component=jobmanager --timeout=180s 2>/dev/null || echo "Deployment in progress..."
echo ""

# Step 7: Submit PyFlink Job
echo -e "${GREEN}[7/9] Submitting PyFlink job to Flink cluster...${NC}"
JM_POD=$(kubectl get pods -l app=word-count-app,component=jobmanager -o jsonpath='{.items[0].metadata.name}')
if [ -n "$JM_POD" ]; then
    kubectl exec $JM_POD -- /opt/flink/bin/flink run \
        --python /opt/flink/usrlib/simple_word_count.py \
        --target remote \
        --jobmanager localhost:8082 2>&1 | grep -E "Job has been submitted|JobID"
    echo -e "${GREEN}✓ Job submitted successfully${NC}"
else
    echo -e "${RED}✗ JobManager pod not found${NC}"
fi
echo ""

# Step 8: Wait for TaskManagers
echo -e "${GREEN}[8/9] Waiting for TaskManagers to be created...${NC}"
sleep 10
kubectl wait --for=condition=ready pod -l app=word-count-app,component=taskmanager --timeout=60s 2>/dev/null || echo "TaskManagers starting..."
echo ""

# Step 9: Start port-forwards
echo -e "${GREEN}[9/9] Starting port-forwards...${NC}"
kubectl port-forward svc/kafka-ui 9092:8080 > /dev/null 2>&1 &
KAFKA_UI_PID=$!
echo -e "${GREEN}✓ Kafka UI available at http://localhost:9092${NC}"

kubectl port-forward svc/word-count-app-rest 9091:8082 > /dev/null 2>&1 &
FLINK_UI_PID=$!
echo -e "${GREEN}✓ Flink UI available at http://localhost:9091${NC}"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Resources deployed:${NC}"
echo "  • Flink Kubernetes Operator (flink-operator-system namespace)"
echo "  • Flink JobManager + TaskManagers (default namespace)"
echo "  • PyFlink Word Count Job (running)"
echo "  • Kafka + Zookeeper"
echo "  • Kafka UI (http://localhost:9092)"
echo "  • Flink UI (http://localhost:9091)"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo ""
echo -e "${BLUE}Check FlinkDeployment status:${NC}"
echo "  kubectl get flinkdeployment word-count-app"
echo "  kubectl describe flinkdeployment word-count-app"
echo ""
echo -e "${BLUE}View TaskManager logs (word count output):${NC}"
echo "  kubectl logs -l app=word-count-app,component=taskmanager -f"
echo ""
echo -e "${BLUE}View JobManager logs:${NC}"
echo "  kubectl logs -l app=word-count-app,component=jobmanager -f"
echo ""
echo -e "${BLUE}Check Flink pods:${NC}"
echo "  kubectl get pods -l app=word-count-app"
echo ""
echo -e "${BLUE}Check running jobs:${NC}"
echo "  kubectl exec -l component=jobmanager,app=word-count-app -- curl -s http://localhost:8082/jobs"
echo ""
echo -e "${BLUE}Send more messages to Kafka:${NC}"
echo "  kubectl exec -it kafka-0 -- kafka-console-producer \\"
echo "    --broker-list localhost:9092 \\"
echo "    --topic input-text"
echo ""
echo -e "${BLUE}Access UIs:${NC}"
echo "  Flink UI:  http://localhost:9091"
echo "  Kafka UI:  http://localhost:9092"
echo ""
echo -e "${BLUE}Monitor operator logs:${NC}"
echo "  kubectl logs -n flink-operator-system deployment/flink-kubernetes-operator -f"
echo ""
echo -e "${RED}Cleanup:${NC}"
echo "  ./cleanup.sh"
echo ""
