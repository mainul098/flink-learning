#!/usr/bin/env python3
"""
Simple PyFlink test to verify setup is working correctly.

This script:
1. Creates a StreamExecutionEnvironment
2. Generates a simple data stream
3. Performs basic transformations
4. Prints results to console

Run: python test_setup.py
"""

from pyflink.datastream import StreamExecutionEnvironment


def main():
    # Create the execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)
    
    # Create a simple data stream from a collection
    data = ["Apache Flink", "PyFlink", "Stream Processing", "Big Data", "Real-Time Analytics"]
    
    ds = env.from_collection(data)
    
    # Transform: split into words and count
    def split_words(line):
        for word in line.split():
            yield word.lower()
    
    words = ds.flat_map(split_words)
    
    # Map to (word, 1) tuples
    word_counts = words.map(lambda word: (word, 1)) \
                       .key_by(lambda x: x[0]) \
                       .reduce(lambda a, b: (a[0], a[1] + b[1]))
    
    # Print results
    word_counts.print()
    
    # Execute the job
    env.execute("PyFlink Setup Test")


if __name__ == '__main__':
    print("=" * 60)
    print("Testing PyFlink Setup")
    print("=" * 60)
    print("\nIf you see word counts below, your setup is working!\n")
    
    main()
    
    print("\n" + "=" * 60)
    print("✅ PyFlink setup test completed successfully!")
    print("=" * 60)
