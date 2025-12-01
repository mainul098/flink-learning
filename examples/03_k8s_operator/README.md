# Flink Kubernetes Operator - Production Deployment

This example demonstrates a production-ready deployment using the **Flink Kubernetes Operator** to manage Flink applications declaratively through Kubernetes CRDs (Custom Resource Definitions).

## 🎯 What's Different from 03_k8s_operator?

| Aspect | 03_k8s_operator | 04_cluster (This) |
|--------|-----------------|-------------------|
| **Deployment** | Simple Pod | FlinkDeployment CRD |
| **Management** | Manual | Operator-managed |
| **High Availability** | No | Yes (Kubernetes HA) |
| **Auto Recovery** | No | Yes |
| **Scaling** | Manual | Declarative |
| **Savepoints** | Manual | Automated |
| **Upgrades** | Restart | Rolling with savepoints |
| **Production Ready** | No | Yes |

## 📁 Files

- **`flink-deployment.yaml`** - FlinkDeployment CRD manifest for the word count application
- **`infrastructure.yaml`** - Supporting resources (Kafka, Zookeeper, Kafka UI, RBAC)
- **`operator-install.yaml`** - Flink Kubernetes Operator installation
- **`deploy.sh`** - Automated deployment script
- **`cleanup.sh`** - Cleanup script to remove all resources
- **`README.md`** - This file

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (minikube, kind, or colima)
- kubectl configured
- Docker for building images

### Deploy Everything
```bash
chmod +x deploy.sh cleanup.sh
./deploy.sh
```

This script will:
1. Install Flink Operator CRDs
2. Deploy the Flink Kubernetes Operator
3. Deploy infrastructure (Kafka, Zookeeper, Kafka UI)
4. Build the Docker image
5. Create Kafka topic and send test messages
6. Deploy the Flink application via FlinkDeployment CRD
7. Start Kafka UI port-forward on port 9090

## 📊 Architecture

### Components

```
┌─────────────────────────────────────────────────┐
│         Kubernetes Cluster                       │
│                                                   │
│  ┌──────────────────────────────────────────┐   │
│  │  Flink Operator (flink-operator-system)  │   │
│  │  - Watches FlinkDeployment CRDs          │   │
│  │  - Manages Flink cluster lifecycle       │   │
│  │  - Handles savepoints & upgrades         │   │
│  └──────────────────────────────────────────┘   │
│              ↓ manages                            │
│  ┌──────────────────────────────────────────┐   │
│  │  Flink Cluster (default namespace)       │   │
│  │                                           │   │
│  │  ┌─────────────┐                         │   │
│  │  │ JobManager  │  (1 replica)            │   │
│  │  │  - REST API │                         │   │
│  │  │  - Web UI   │                         │   │
│  │  └─────────────┘                         │   │
│  │                                           │   │
│  │  ┌─────────────┐  ┌─────────────┐       │   │
│  │  │TaskManager1 │  │TaskManager2 │       │   │
│  │  │ (2 slots)   │  │ (2 slots)   │       │   │
│  │  └─────────────┘  └─────────────┘       │   │
│  └──────────────────────────────────────────┘   │
│              ↓ consumes                           │
│  ┌──────────────────────────────────────────┐   │
│  │  Kafka + Zookeeper                       │   │
│  │  - Topic: input-text (4 partitions)      │   │
│  │  - Kafka UI on port 9090                 │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### Data Flow
```
Kafka Topic "input-text"
    ↓
Flink Source (4 parallel tasks)
    ↓
FlatMap (split into words)
    ↓
Map (word → (word, 1))
    ↓
KeyBy (partition by word)
    ↓
Reduce (count occurrences)
    ↓
Print (to TaskManager logs)
```

## 🔍 Monitoring & Operations

### Check FlinkDeployment Status
```bash
# Get deployment status
kubectl get flinkdeployment word-count-app

# Detailed status
kubectl describe flinkdeployment word-count-app

# Watch status changes
kubectl get flinkdeployment word-count-app -w
```

### View Logs
```bash
# JobManager logs
kubectl logs -l component=jobmanager,app=word-count-app -f

# TaskManager logs (word count output)
kubectl logs -l component=taskmanager,app=word-count-app -f

# Operator logs
kubectl logs -n flink-operator-system deployment/flink-kubernetes-operator -f
```

### Access Flink Web UI
```bash
# Port-forward to Flink REST service
kubectl port-forward svc/word-count-app-rest 8081:8081

# Open in browser
open http://localhost:8081
```

The Flink UI shows:
- Job details and metrics
- TaskManager status
- Checkpoint statistics
- Backpressure monitoring
- Job graph visualization

### Access Kafka UI
The deploy script automatically starts Kafka UI at http://localhost:9090

Manually start:
```bash
kubectl port-forward svc/kafka-ui 9090:8080
```

## 🧪 Testing

### Send Messages to Kafka
```bash
kubectl exec -it kafka-0 -- kafka-console-producer \
  --broker-list localhost:9092 \
  --topic input-text
```
Type messages and press Ctrl-D when done.

### View Word Count Results
```bash
# Filter TaskManager logs for word counts
kubectl logs -l component=taskmanager,app=word-count-app --tail=50 | grep "^[1-4]>"

# Follow in real-time
kubectl logs -l component=taskmanager,app=word-count-app -f | grep "^[1-4]>"
```

### Check Pods
```bash
kubectl get pods -l app=word-count-app
```

Expected output:
```
NAME                                    READY   STATUS    RESTARTS   AGE
word-count-app-<hash>                   1/1     Running   0          2m
word-count-app-taskmanager-1-1          1/1     Running   0          2m
word-count-app-taskmanager-2-1          1/1     Running   0          2m
```

## 🔧 Configuration

### FlinkDeployment Spec

Key configuration in `flink-deployment.yaml`:

```yaml
spec:
  # Flink version
  flinkVersion: v1_18
  
  # JobManager resources
  jobManager:
    replicas: 1
    resource:
      memory: "1024m"
      cpu: 0.5
  
  # TaskManager resources
  taskManager:
    replicas: 2
    resource:
      memory: "1024m"
      cpu: 0.5
  
  # Job configuration
  job:
    parallelism: 4
    upgradeMode: savepoint  # Use savepoints for upgrades
    state: running
```

### Modify Resources

Edit the FlinkDeployment:
```bash
kubectl edit flinkdeployment word-count-app
```

Or update the YAML and apply:
```bash
kubectl apply -f flink-deployment.yaml
```

The operator will handle the upgrade automatically!

## 🔄 Lifecycle Operations

### Scaling

**Scale TaskManagers:**
```bash
# Edit flink-deployment.yaml
# Change: taskManager.replicas: 3

kubectl apply -f flink-deployment.yaml
```

The operator will:
1. Trigger a savepoint
2. Stop the job
3. Scale resources
4. Restore from savepoint
5. Resume the job

### Upgrades

**Update application code:**
```bash
# Rebuild image with new version
cd ../03_k8s_operator
docker build -t flink-word-count:v2 .

# Update flink-deployment.yaml
# Change: spec.image: flink-word-count:v2

cd ../04_cluster
kubectl apply -f flink-deployment.yaml
```

The operator handles the upgrade with savepoints automatically!

### Savepoints

**Trigger manual savepoint:**
```bash
# Edit flink-deployment.yaml
# Increment: job.savepointTriggerNonce: 1

kubectl apply -f flink-deployment.yaml
```

**View savepoint history:**
```bash
kubectl describe flinkdeployment word-count-app | grep -A 10 Savepoint
```

### Suspend & Resume

**Suspend the job:**
```bash
# Edit flink-deployment.yaml
# Change: job.state: suspended

kubectl apply -f flink-deployment.yaml
```

**Resume the job:**
```bash
# Edit flink-deployment.yaml
# Change: job.state: running

kubectl apply -f flink-deployment.yaml
```

## 🎛️ High Availability

The deployment includes Kubernetes-based HA:

```yaml
flinkConfiguration:
  high-availability: org.apache.flink.kubernetes.highavailability.KubernetesHaServicesFactory
  high-availability.storageDir: file:///tmp/flink-ha
```

**Test HA:**
```bash
# Delete JobManager pod
kubectl delete pod -l component=jobmanager,app=word-count-app

# Watch recovery
kubectl get pods -l app=word-count-app -w
```

The operator will automatically recreate the JobManager and restore from the latest checkpoint!

## 📈 Production Features

### Checkpointing
- **Interval**: 60 seconds
- **Mode**: EXACTLY_ONCE
- **Backend**: RocksDB
- **Storage**: Local filesystem (use S3/HDFS in production)

### Restart Strategy
- **Type**: Fixed delay
- **Attempts**: 3
- **Delay**: 10 seconds

### Resource Limits
- JobManager: 1GB memory, 0.5 CPU
- TaskManager: 1GB memory, 0.5 CPU (×2 replicas)
- Kafka: 2GB memory, 1 CPU
- Zookeeper: 1GB memory, 0.5 CPU

## 🐛 Troubleshooting

### FlinkDeployment not starting

```bash
# Check operator logs
kubectl logs -n flink-operator-system deployment/flink-kubernetes-operator --tail=100

# Check FlinkDeployment events
kubectl describe flinkdeployment word-count-app

# Check RBAC permissions
kubectl auth can-i create pods --as=system:serviceaccount:default:flink
```

### Job failing repeatedly

```bash
# Check JobManager logs
kubectl logs -l component=jobmanager,app=word-count-app

# Check TaskManager logs
kubectl logs -l component=taskmanager,app=word-count-app

# Verify Kafka connectivity
kubectl exec -l component=jobmanager,app=word-count-app -- nc -zv kafka 9092
```

### Image pull errors

```bash
# For colima
docker ps  # Verify image exists

# For kind
kind load docker-image flink-word-count:latest

# For minikube
minikube image load flink-word-count:latest
```

### Operator not reconciling

```bash
# Check operator is running
kubectl get pods -n flink-operator-system

# Check CRDs are installed
kubectl get crd | grep flink

# Restart operator
kubectl rollout restart deployment/flink-kubernetes-operator -n flink-operator-system
```

## 🧹 Cleanup

```bash
./cleanup.sh
```

This will remove:
- FlinkDeployment and all Flink resources
- Infrastructure (Kafka, Zookeeper, Kafka UI)
- Flink Kubernetes Operator
- Optionally: CRDs

## 📚 Further Reading

- [Flink Kubernetes Operator Documentation](https://nightlies.apache.org/flink/flink-kubernetes-operator-docs-stable/)
- [FlinkDeployment CRD Reference](https://nightlies.apache.org/flink/flink-kubernetes-operator-docs-stable/docs/custom-resource/reference/)
- [Operator Configuration](https://nightlies.apache.org/flink/flink-kubernetes-operator-docs-stable/docs/operations/configuration/)
- [Production Readiness Checklist](https://nightlies.apache.org/flink/flink-kubernetes-operator-docs-stable/docs/operations/production-ready/)

## 🆚 Comparison: Pod vs FlinkDeployment

### Simple Pod (03_k8s_operator)
✅ Simple to understand  
✅ Quick to deploy  
❌ No auto-recovery  
❌ Manual scaling  
❌ No savepoint management  
❌ Manual upgrades  

### FlinkDeployment (04_cluster)
✅ Production-ready  
✅ Auto-recovery  
✅ Declarative scaling  
✅ Automated savepoints  
✅ Rolling upgrades  
✅ High availability  
✅ Kubernetes-native  
❌ More complex setup  

## 💡 Next Steps

1. **Persistent Storage**: Configure S3/HDFS for checkpoints and savepoints
2. **Metrics**: Integrate with Prometheus and Grafana
3. **Multiple Environments**: Use namespaces for dev/staging/prod
4. **CI/CD**: Automate deployments with GitOps (ArgoCD/Flux)
5. **Advanced Patterns**: Session clusters, application clusters, job pools
