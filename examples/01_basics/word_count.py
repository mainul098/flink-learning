#!/usr/bin/env python3
"""
Module 1: Introduction to Apache Flink - Word Count Example

This demonstrates:
- Creating a StreamExecutionEnvironment
- Reading from a socket source
- Basic transformations (flat_map, key_by, reduce)
- Printing results

To test:
1. Terminal 1: nc -lk 9999
2. Terminal 2: python examples/01_basics/word_count.py
3. Type words in Terminal 1
"""

from pyflink.datastream import StreamExecutionEnvironment


def word_count():
    # Create execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)
    
    # Read text from socket
    # Start a socket server: nc -lk 9999
    text = env.socket_text_stream("localhost", 9999)
    
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
    print("Make sure to run: nc -lk 9999 in another terminal")
    print("-" * 60)
    word_count()
