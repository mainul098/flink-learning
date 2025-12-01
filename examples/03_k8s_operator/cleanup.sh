#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}========================================${NC}"
echo -e "${RED}Cleaning up Flink Operator Deployment${NC}"
echo -e "${RED}========================================${NC}"
echo ""

# Stop port-forwards
echo -e "${YELLOW}Stopping port-forwards...${NC}"
pkill -f "kubectl port-forward" 2>/dev/null || true
echo ""

# Delete FlinkDeployment
echo -e "${YELLOW}[1/4] Deleting FlinkDeployment...${NC}"
kubectl delete -f flink-deployment.yaml --ignore-not-found=true
echo ""

# Wait for Flink resources to be cleaned up
echo -e "${YELLOW}Waiting for Flink resources to be removed...${NC}"
sleep 10
echo ""

# Delete infrastructure
echo -e "${YELLOW}[2/4] Deleting infrastructure (Kafka, Zookeeper)...${NC}"
kubectl delete -f infrastructure.yaml --ignore-not-found=true
echo ""

# Delete operator
echo -e "${YELLOW}[3/4] Deleting Flink Kubernetes Operator...${NC}"
kubectl delete -f operator-install.yaml --ignore-not-found=true
echo ""

# Delete CRDs (optional - commented out by default to avoid issues)
echo -e "${YELLOW}[4/4] Deleting Flink CRDs (optional)...${NC}"
read -p "Do you want to delete Flink CRDs? This will remove all FlinkDeployment definitions (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete crd flinkdeployments.flink.apache.org --ignore-not-found=true
    kubectl delete crd flinksessionjobs.flink.apache.org --ignore-not-found=true
    echo -e "${GREEN}✓ CRDs deleted${NC}"
else
    echo -e "${YELLOW}Skipping CRD deletion${NC}"
fi
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}All resources have been removed.${NC}"
echo ""
