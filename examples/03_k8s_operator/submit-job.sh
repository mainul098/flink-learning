#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Submit PyFlink Job to Session Cluster${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get the JobManager pod
JM_POD=$(kubectl get pods -l app=word-count-app,component=jobmanager -o jsonpath='{.items[0].metadata.name}')

if [ -z "$JM_POD" ]; then
    echo -e "${YELLOW}⚠️  No JobManager pod found. Is the cluster running?${NC}"
    exit 1
fi

echo -e "${GREEN}Found JobManager pod: ${JM_POD}${NC}"
echo ""

# Submit the PyFlink job
echo -e "${YELLOW}Submitting PyFlink word count job...${NC}"
kubectl exec -it $JM_POD -- /bin/bash -c "
    cd /opt/flink/usrlib && \
    python3 simple_word_count.py
"

echo ""
echo -e "${GREEN}✓ Job submitted successfully!${NC}"
echo ""
echo -e "${YELLOW}Check job status:${NC}"
echo "  kubectl logs -l app=word-count-app,component=taskmanager -f"
echo ""
echo -e "${YELLOW}View Flink UI:${NC}"
echo "  http://localhost:8082"
echo ""
