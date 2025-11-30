#!/usr/bin/env python3
"""
Module 1: Introduction to Apache Flink - Word Count Example

This demonstrates:
- Creating a StreamExecutionEnvironment
- Reading from a collection source
- Basic transformations (flat_map, key_by, reduce)
- Printing results

Note: PyFlink 1.20.0 doesn't support socket_text_stream in DataStream API.
For socket streaming, you would need to use Flink connectors or Table API.
"""

from pyflink.datastream import StreamExecutionEnvironment
import time


def word_count():
    # Create execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)
    
    # Sample data - simulating a stream
    lines = [
        "apache flink is great",
        "flink makes stream processing easy",
        "apache flink apache spark",
        "stream processing with flink",
        "flink flink flink"
    ]
    
    # Create stream from collection
    text = env.from_collection(lines)
    
    # Split lines into words
    def split_words(line):
        for word in line.lower().split():
            if word:
                yield (word, 1)
    
    # Process: flatMap -> keyBy -> sum
    counts = text.flat_map(split_words) \
                 .key_by(lambda x: x[0]) \
                 .reduce(lambda a, b: (a[0], a[1] + b[1]))
    
    # Print results
    counts.print()
    
    # Execute
    env.execute("PyFlink Word Count")


if __name__ == '__main__':
    print("Starting Word Count example...")
    print("Processing sample text data...")
    print("-" * 60)
    word_count()
    print("-" * 60)
    print("✅ Word count complete!")
