#!/usr/bin/env python3
"""
Simple streaming example - generates numbers and processes them.

This is the simplest possible Flink program to verify everything works.
No external dependencies needed (no socket, no Kafka, etc.)

Run: python examples/01_basics/simple_stream.py
"""

from pyflink.datastream import StreamExecutionEnvironment


def simple_stream():
    # Create execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)
    
    # Create a stream from a collection
    numbers = list(range(1, 11))  # [1, 2, 3, ..., 10]
    
    ds = env.from_collection(numbers)
    
    # Transform: multiply by 2
    doubled = ds.map(lambda x: x * 2)
    
    # Filter: only numbers > 10
    filtered = doubled.filter(lambda x: x > 10)
    
    # Print results
    print("\nOriginal numbers: 1-10")
    print("After doubling and filtering (> 10):\n")
    filtered.print()
    
    # Execute
    env.execute("Simple Stream Processing")


if __name__ == '__main__':
    print("=" * 60)
    print("Simple Stream Processing Example")
    print("=" * 60)
    
    simple_stream()
    
    print("\n" + "=" * 60)
    print("✅ Complete!")
    print("=" * 60)
