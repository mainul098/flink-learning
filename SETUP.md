# Setup Guide

## Installation

### 1. Prerequisites

Ensure you have the following installed:

```bash
# Check Python version (3.8+ required)
python3 --version

# Check Java version (11 or 17 required for Flink)
java -version
```

If Java is not installed:
```bash
# macOS
brew install openjdk@11

# Add to PATH
echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 2. Create Virtual Environment

```bash
cd flink-learning

# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Verify activation (should show venv path)
which python
```

### 3. Install PyFlink

```bash
# Install dependencies
pip install -r requirements.txt

# Verify installation
python -c "import pyflink; print(f'PyFlink version: {pyflink.__version__}')"
```

### 4. Test Setup

Run the simple test script:

```bash
python test_setup.py
```

Expected output:
```
============================================================
Testing PyFlink Setup
============================================================

If you see word counts below, your setup is working!

('apache', 1)
('flink', 1)
('pyflink', 1)
...

============================================================
✅ PyFlink setup test completed successfully!
============================================================
```

## Running Examples

### Example 1: Word Count (Socket)

Terminal 1 - Start netcat server:
```bash
nc -lk 9999
```

Terminal 2 - Run Flink job:
```bash
source venv/bin/activate
python examples/01_basics/word_count.py
```

Type words in Terminal 1 and see counts in Terminal 2!

## Local Flink Cluster (Docker)

For more advanced examples, run a local Flink cluster:

```bash
# Start Colima (Docker alternative)
colima start --cpu 4 --memory 8

# Start Flink cluster
cd docker
docker-compose up -d

# Check status
docker ps
```

Access Flink Web UI: http://localhost:8081

## Troubleshooting

### Issue: "No module named 'pyflink'"
```bash
# Make sure virtual environment is activated
source venv/bin/activate

# Reinstall
pip install apache-flink==1.18.1
```

### Issue: Java not found
```bash
# Install Java 11
brew install openjdk@11

# Set JAVA_HOME
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
```

### Issue: Port 9999 already in use
```bash
# Kill process on port
lsof -ti:9999 | xargs kill -9
```

### Issue: Permission denied on test_setup.py
```bash
chmod +x test_setup.py
```

## Next Steps

1. ✅ Complete setup verification
2. Run basic examples in `examples/01_basics/`
3. Read architecture documentation in `docs/`
4. Deploy to Kubernetes (see `kubernetes/`)
5. Explore event-time processing examples

## Deactivating Virtual Environment

When done:
```bash
deactivate
```
