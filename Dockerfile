FROM openjdk:11.0.11-jre-slim-buster as builder

# Add Dependencies for PySpark
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        vim \
        wget \
        software-properties-common \
        ssh \
        net-tools \
        ca-certificates \
        python3 \
        python3-pip \
        python3-numpy \
        python3-matplotlib \
        python3-scipy \
        python3-pandas \
        python3-simpy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV SPARK_VERSION=3.0.2 \
HADOOP_VERSION=3.2 \
SPARK_HOME=/opt/spark \
PYTHONHASHSEED=1 \
POSTGRES_VERSION=42.7.4

RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
&& mkdir -p /opt/spark \
&& tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
&& rm apache-spark.tgz


FROM builder as apache-spark

WORKDIR ${SPARK_HOME}

# Download Postgres jar
RUN curl -s https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.jar -Lo ${SPARK_HOME}/jars/postgresql-${POSTGRES_VERSION}.jar

RUN mkdir -p /home/spark /home/spark/jobs
COPY ./jobs/etl.py /home/spark/jobs/etl.py
RUN chmod u+x /home/spark/jobs/*

ENV SPARK_MASTER_PORT=7077 \
SPARK_MASTER_WEBUI_PORT=8080 \
SPARK_LOG_DIR=${SPARK_HOME}/logs \
SPARK_MASTER_LOG=${SPARK_HOME}/logs/spark-master.out \
SPARK_WORKER_LOG=${SPARK_HOME}/logs/spark-worker.out \
SPARK_WORKER_WEBUI_PORT=8080 \
SPARK_WORKER_PORT=7000 \
SPARK_MASTER="spark://spark-master:7077" \
SPARK_WORKLOAD="master"

EXPOSE 8080 7077 7000

RUN mkdir -p $SPARK_LOG_DIR && \
touch $SPARK_MASTER_LOG && \
touch $SPARK_WORKER_LOG && \
ln -sf /dev/stdout $SPARK_MASTER_LOG && \
ln -sf /dev/stdout $SPARK_WORKER_LOG

COPY start-spark.sh /

CMD ["/bin/bash", "/start-spark.sh"]