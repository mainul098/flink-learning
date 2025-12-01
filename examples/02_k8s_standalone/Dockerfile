FROM flink:1.18-java11

# Install Python and PyFlink
USER root
RUN apt-get update && apt-get install -y python3 python3-pip python3-dev openjdk-11-jdk build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for PyFlink build
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64

# Install PyFlink
RUN pip3 install --no-cache-dir apache-flink==1.18.1

# Download Kafka connector JARs for PyFlink
RUN wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.0.2-1.18/flink-sql-connector-kafka-3.0.2-1.18.jar

# Create python symlink
RUN ln -s /usr/bin/python3 /usr/bin/python

USER flink

# Copy the application code
COPY simple_word_count.py /opt/flink/usrlib/

# Set working directory
WORKDIR /opt/flink/usrlib

# The operator will execute: python3 simple_word_count.py
