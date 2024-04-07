# Setup ELK Stack on Ubuntu 22.04

![ELK-logo](/assets/ELK-logo.jpg)

## Introduction

ELK stands for Elasticsearch, Logstash, and Kibana.<br>
The Elastic Stack — formerly known as the ELK Stack — is a collection of open-source software produced by Elastic which allows you to search, analyze, and visualize logs generated from any source in any format, a practice known as centralized logging.

The Elastic Stack has four main components:

- **Elasticsearch**: A distributed RESTful search engine which stores all of the collected data.
- **Logstash**: The data processing component of the Elastic Stack which sends incoming data to Elasticsearch.
- **Kibana**: A web interface for searching and visualizing logs.
- **Beats**: Lightweight, single-purpose data shippers that can send data from hundreds or thousands of machines to either Logstash or Elasticsearch.

![ELK-structure](/assets/ELK-structure.jpg)

## Prerequisites

- Ubuntu Server with 22.04 LTS
- Java 8 or higher version
- 2 CPU and 4 GB RAM

```bash
apt update
## to access repository over HTTPS
apt install apt-transport-https
```

## Install Java

```bash
apt install openjdk-11-jdk
java -version
```

Setting the `JAVA_HOME` Environment Variables

```bash
vim /etc/environment

###################
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
###################

## Load the environment variable
source /etc/environment
echo $JAVA_HOME
## Output should be
/usr/lib/jvm/java-11-openjdk-amd64s
```

![env-var](/assets/ELK-env-var.jpg)

## Add apt repository

Download and install the public signing key and then save the repository definition to `/etc/apt/sources.list.d/elastic-8.x.list`

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
```

## ElasticSearch

### Install

```bash
apt update
apt install elasticsearch

systemctl start elasticsearch
systemctl enable elasticsearch
systemctl status elasticsearch
```

![elasticsearch-status](/assets/ELK-elasticsearch-status.jpg)

### Configure

```bash
vim /etc/elasticsearch/elasticsearch.yml

## Network section
network.host: localhost

## Discovery section
discovery.seed_hosts: []

## BEGIN SECURITY AUTO CONFIGURATION section
xpack.security.enabled: false


systemctl restart elasticsearch
```

![elasticsearch-config](/assets/ELK-elasticsearch-config.jpg)

### Test

You can access using browser with this: `http://192.168.211.101:9200` or

```bash
curl -X GET "localhost:9200"
```

The output should be like this

```json
{
  "name" : "ip-172-31-4-2",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "5WWxXV59TUiwsLWmb1lTDg",
  "version" : {
    "number" : "8.1.3",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "39afaa3c0fe7db4869a161985e240bd7182d7a07",
    "build_date" : "2023-01-30T08:13:25.444693396Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}

```

![elasticsearch-test](/assets/ELK-elasticsearch-test.jpg)

## Logstash

Logstash is a tool that collects data from different sources. The data it collects is parsed by Kibana and stored in Elasticsearch.

### Install

```bash
apt install logstash

systemctl start logstash
systemctl enable logstash
systemctl status logstash
```

![logstash-status](/assets/ELK-logstash-status.jpg)

### Configure

```bash
vim /etc/logstash/logstash.yml
```

## Kibana

### Install

```bash
apt install kibana

systemctl start kibana
systemctl enable kibana
systemctl status kibana
```

![kibana-status](/assets/ELK-kibana-status.jpg)

### Configure

Uncomment following lines in `/etc/kibana/kibana.yml`

```bash
vim /etc/kibana/kibana.yml

server.port: 5601
server.host: "localhost"
elasticsearch.hosts: ["http://localhost:9200"]


systemctl restart kibana
```

![kibana-config](/assets/ELK-kibana-config.jpg)

### Test 

Open `http://192.168.211.101:5601` in your browser

![kibana-test](/assets/ELK-kibana-test.jpg)

## Filebeat

Filebeat is a lightweight plugin used to collect and ship log files. It is the most commonly used Beats module. One of Filebeat’s major advantages is that it slows down its pace if the Logstash service is overwhelmed with data.

### Install

```bash
apt install filebeat
```

### Configure

Filebeat, by default, sends data to Elasticsearch. Filebeat can also be configured to send event data to Logstash.

```bash
vim /etc/filebeat/filebeat.yml

## Elasticsearch output section - comment following lines
# output.elasticsearch:
# Array of hosts to connect to.
# hosts: ["localhost:9200"]

## Logstash output section - uncomment following lines
output.logstash
hosts: ["localhost:5044"]
```

Enable the Filebeat system module and Load the index template:

```bash
filebeat modules enable system
filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["0.0.0.0:9200"]'

## Output
Overwriting ILM policy is disabled. Set `setup.ilm.overwrite: true` for enabling.
Index setup finished.
```

![filebeat-module-enable](/assets/ELK-filebeat-module-enable.jpg)

Start and enable service

```bash
systemctl start filebeat
systemctl enable filebeat
```

### Test

```bash
curl -XGET http://localhost:9200/_cat/indices?v

## Output
health status index                                uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   .ds-filebeat-8.1.3-2022.04.22-000001 sXxRSgL6QZSyti8uK9RC3w   1   1          0            0       225b           225b

curl -XGET 'http://localhost:9200/filebeat-*/_search?pretty'
```

![filebeat-console-test](/assets/ELK-filebeat-console-test.jpg)

Open `http://192.168.211.101:9200/_cat/indices?v` in your browser.

![filebeat-browser-test](/assets/ELK-filebeat-browser-test.jpg)

Now everything is <span style="color: green">**DONE**</span>!

## Source of content

[How to Install Elastic Stack on Ubuntu 22.04 LTS](https://www.fosstechnix.com/how-to-install-elastic-stack-on-ubuntu-22-04/) <br>
[How To Install Elasticsearch, Logstash, and Kibana (Elastic Stack) on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-22-04) <br>
[ELK Stack: What It Is And What It Is Used For](https://flowygo.com/en/blog/elk-stack-what-it-is-and-what-it-is-used-for/#google_vignette) <br>