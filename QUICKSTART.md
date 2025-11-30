# Quick Start

## ✅ Verified Setup (Working!)

- **Python Version**: 3.10
- **PyFlink Version**: 1.20.0
- **Status**: All tests passing ✅

## Installation

```bash
# 1. Create virtual environment with Python 3.10
python3.10 -m venv venv

# 2. Activate it
source venv/bin/activate

# 3. Install PyFlink
pip install -r requirements.txt

# 4. Verify installation
python test_setup.py
```

## Run Your First Example

```bash
# Activate environment
source venv/bin/activate

# Run simple stream example (no external dependencies)
python examples/01_basics/simple_stream.py
```

Expected output:
```
============================================================
Simple Stream Processing Example
============================================================

Original numbers: 1-10
After doubling and filtering (> 10):

12
14
16
18
20

============================================================
✅ Complete!
============================================================
```

## What's Next?

1. ✅ **Setup complete** - PyFlink is working!
2. Explore examples in `examples/01_basics/`
3. Read architecture docs in `docs/`
4. Try Docker setup: `cd docker && docker-compose up`
5. Deploy to Kubernetes (see `kubernetes/`)

## Troubleshooting

### Wrong Python version?
```bash
# Check available versions
ls -la /opt/homebrew/bin/python*

# Use Python 3.10 explicitly
/opt/homebrew/bin/python3.10 -m venv venv
```

### Module not found?
```bash
# Make sure venv is activated
source venv/bin/activate
which python  # Should show venv path
```

## Deactivate Environment

```bash
deactivate
```
