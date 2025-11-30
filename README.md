# Apache Flink Learning with Kotlin

A comprehensive learning repository focused on Apache Flink architecture and implementation using Kotlin.

## 🎯 Learning Objectives

This repository is structured to provide hands-on experience with Apache Flink's architecture, from basic concepts to advanced operational scenarios.

## 📚 Table of Contents

### 1. Introduction to Apache Flink
- What is Apache Flink?
- Stream processing fundamentals
- Batch vs. Stream processing
- Flink's position in the data processing ecosystem

### 2. Architecture Overview
- Master-Worker architecture
- JobManager and TaskManager
- Flink Runtime components
- Deployment modes (Session, Application, Per-Job)

### 3. Kubernetes Operator Fundamentals
- Flink Kubernetes Operator overview
- Custom Resource Definitions (CRDs)
- Operator lifecycle management
- Native Kubernetes integration

### 4. Cluster Management & Running on Kubernetes
- Standalone clusters
- YARN and Kubernetes deployments
- High availability configurations
- Dynamic resource allocation

### 5. Resource Management
- Resource profiles and slot sharing
- Memory management (Task, Network, Managed)
- CPU and memory allocation strategies
- Resource optimization techniques

### 6. Task Management & Execution
- Task scheduling and execution
- Operator chains and task slots
- Parallelism and task distribution
- Backpressure handling

### 7. Application Deployment & Submission
- Application modes
- Job submission workflows
- JAR packaging and dependencies
- Configuration management

### 8. Data Flow Processing Pipeline
- DataStream API fundamentals
- Table API and SQL
- Sources and sinks
- Transformations and operators

### 9. Event-Time Processing & Windowing
- Event time vs. processing time
- Watermarks and late events
- Window types (Tumbling, Sliding, Session)
- Window functions and aggregations

### 10. State Management & Fault Tolerance
- Keyed and operator state
- State backends (Memory, RocksDB, Filesystem)
- Checkpointing mechanisms
- Savepoints and recovery

### 11. Monitoring & Observability
- Metrics and monitoring
- Web UI and REST API
- Integration with Prometheus/Grafana
- Logging and debugging

### 12. Performance Tuning & Configuration
- Network buffer tuning
- Checkpoint optimization
- Memory configuration
- Parallelism tuning

### 13. Best Practices & Operational Scenarios
- Production deployment patterns
- Troubleshooting common issues
- Scaling strategies
- Upgrade and migration strategies

## 🛠️ Prerequisites

- Kotlin 1.9+
- Gradle 8+
- Docker/Colima
- kubectl (for Kubernetes examples)
- Java 11 or 17

## 🚀 Getting Started

```bash
# Clone the repository
git clone <your-repo-url>
cd flink-learning

# Build the project
./gradlew build

# Run examples
./gradlew run
```

## 📁 Project Structure

```
flink-learning/
├── examples/
│   ├── 01_basics/              # 1. Introduction examples
│   ├── 02_architecture/        # 2. Architecture components
│   ├── 03_k8s_operator/        # 3. Kubernetes Operator
│   ├── 04_cluster/             # 4. Cluster management
│   ├── 05_resources/           # 5. Resource management
│   ├── 06_tasks/               # 6. Task execution
│   ├── 07_deployment/          # 7. Deployment strategies
│   ├── 08_dataflow/            # 8. Data pipelines
│   ├── 09_eventtime/           # 9. Event-time processing
│   ├── 10_state/               # 10. State & fault tolerance
│   ├── 11_monitoring/          # 11. Observability
│   ├── 12_tuning/              # 12. Performance tuning
│   └── 13_operations/          # 13. Best practices
├── kubernetes/                 # K8s manifests
├── docker/                     # Dockerfiles
├── docs/                       # Detailed documentation
├── tests/                      # Unit tests
├── requirements.txt            # Python dependencies
└── venv/                       # Virtual environment
```

## 🎓 Learning Path

1. **Week 1-2**: Fundamentals (Modules 1-2)
2. **Week 3-4**: Deployment & Infrastructure (Modules 3-5)
3. **Week 5-6**: Core Processing (Modules 6-8)
4. **Week 7-8**: Advanced Topics (Modules 9-10)
5. **Week 9-10**: Operations (Modules 11-13)

## 📖 Resources

- [Apache Flink Documentation](https://flink.apache.org/docs/stable/)
- [Flink Kubernetes Operator](https://nightlies.apache.org/flink/flink-kubernetes-operator-docs-stable/)
- [Flink Forward Conference Talks](https://www.flink-forward.org/)

## 🤝 Contributing

This is a personal learning repository. Feel free to fork and adapt for your own learning journey.

## 📝 License

MIT License
