#!/usr/bin/env python3
"""
Simple Word Count Flink Application for Kubernetes Operator
This application demonstrates a basic streaming word count pipeline
that can be deployed using the Flink Kubernetes Operator.
"""

from pyflink.datastream import StreamExecutionEnvironment
from pyflink.common import Types, WatermarkStrategy, SimpleStringSchema
from pyflink.datastream.connectors.kafka import KafkaSource, KafkaOffsetsInitializer
import os


def word_count():
    """
    Simple word count application that:
    1. Reads text from Kafka
    2. Splits into words
    3. Counts occurrences
    4. Prints results
    """
    # Create the execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    
    # Configure for Kubernetes deployment
    env.set_parallelism(4)  # 4 parallel tasks
    
    # Enable checkpointing for fault tolerance
    env.enable_checkpointing(60000)  # Checkpoint every 60 seconds
    
    # Configure Kafka source
    kafka_brokers = os.getenv('KAFKA_BROKERS', 'kafka:9092')
    kafka_topic = os.getenv('KAFKA_TOPIC', 'input-text')
    
    kafka_source = KafkaSource.builder() \
        .set_bootstrap_servers(kafka_brokers) \
        .set_topics(kafka_topic) \
        .set_group_id("flink-word-count") \
        .set_starting_offsets(KafkaOffsetsInitializer.earliest()) \
        .set_value_only_deserializer(SimpleStringSchema()) \
        .build()
    
    # Create the data stream from Kafka
    text_stream = env.from_source(
        kafka_source,
        WatermarkStrategy.no_watermarks(),
        "Kafka Source"
    )
    
    # Process: split lines into words, count them
    word_counts = text_stream \
        .flat_map(lambda line: line.lower().split(), output_type=Types.STRING()) \
        .map(lambda word: (word, 1), output_type=Types.TUPLE([Types.STRING(), Types.INT()])) \
        .key_by(lambda x: x[0]) \
        .reduce(lambda a, b: (a[0], a[1] + b[1]))
    
    # Print results (in production, use a proper sink like Kafka or database)
    word_counts.print()
    
    # Execute the job
    env.execute("Simple Word Count")


if __name__ == '__main__':
    word_count()
