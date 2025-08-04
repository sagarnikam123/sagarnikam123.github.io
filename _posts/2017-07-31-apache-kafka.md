---
layout: post
title: "Apache Kafka - getting started"
description: "a distributed streaming platform"
date: 2017-07-31 12.00.00 +0530
categories: [apache]
tags: [kafka, messaging]
---

#### download

* download [Apache Kafka](https://kafka.apache.org/downloads)

* untar

```
tar -xvzf kafka_2.11-0.11.0.0.tgz
cd kafka_2.11-0.11.0.0
```

#### Zookeeper & Kafka

* starting Zookeeper server

```
bin/zookeeper-server-start.sh config/zookeeper.properties
```

* starting Kafka

```
bin/kafka-server-start.sh config/server.properties
```

* checking zookeeper's starting
```
netstat -ant | grep :2181
```

#### Topics

* create a topic

```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
```

* check list of topics created

```
bin/kafka-topics.sh --list --zookeeper localhost:2181
```

#### Producer & Consumer

* creating your own topic (producer)

```
bin/kafka-console-producer.sh -broker-list localhost:9092 -topic test
```

* creating a consumer

```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```

---
