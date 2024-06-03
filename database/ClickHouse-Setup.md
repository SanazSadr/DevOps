# Setup ClickHouse Cluster Replication with Zookeeper on Ubuntu 22.04

![cockroach-logo](/assets/ClickHouse-logo.jpg)

## Introduction

Apache ZooKeeper is a distributed coordination service often used in distributed systems. The role of ZooKeeper in ClickHouse replication involves managing the coordination and synchronization of distributed ClickHouse instances for replication purposes and Failover Handling. It stores and manages configuration information for ClickHouse replicas, such as replica metadata, replica status, and replica configuration settings. ClickHouse replicas can use this information to determine the state of the replication setup and make decisions accordingly.

![clickhouse-server-connection](/assets/clickhouse-servers-connection.jpg)

For this task you will need 3 ubuntu servers.

| Hostname  | IP              |
| --------- | --------------- |
| node1     | 192.168.211.101 |
| node2     | 192.168.211.102 |
| zookeeper | 192.168.211.103 |

Run this command on `zookeeper` server:

```bash
vim /etc/hosts

192.168.211.103 zookeeper1
```

Run this command on `node1` and `node2` server:

```bash
vim /etc/hosts

192.168.211.101 node1
192.168.211.102 node2
192.168.211.103 zookeeper1
```

![clickhouse-etc-hosts](/assets/clickhouse-etc-hosts.jpg)

## Install and Configure Zookeeper

Run these command on your zookeeper server

```bash
apt update
apt install zookeeper netcat
vim /etc/zookeeper/conf/myid

##########
1
##########

vim /etc/zookeeper/conf/zoo.cfg

##########
tickTime=2000
initLimit=20
syncLimit=10
dataDir=/var/lib/zookeeper
clientPort=2181
maxSessionTimeout=60000000
maxClientCnxns=2000
server.1=zookeeper1:2888:3888
autopurge.purgeInterval=1
autopurge.snapRetainCount=10
4lw.commands.whitelist=*
preAllocSize=131072
snapCount=3000000
##########

sudo -u zookeeper /usr/share/zookeeper/bin/zkServer.sh start
```

![start-zookeeper](/assets/clickhouse-start-zookeeper.jpg)

To verify that Zookeeper is running, run one one these commands:

```bash
echo ruok | nc localhost 2181
echo mntr | nc localhost 2181
echo stat | nc 192.168.211.103 2181
```

![verify-zookeeper](/assets/clickhouse-verify-zookeeper.jpg)

## Update system

Run these commands on both `node1` and `node2`

```bash
apt update
apt install -y apt-transport-https ca-certificates dirmngr software-properties-common curl
```

## Import ClickHouse GPG Key

The packages of ClickHouse (analytic DBMS for big data) are signed using a public key by its developers and we need that on our system. It is because then only our system could verify the packages we are getting, are from the source as they were released by its developers. And have not been modified by anyone in between. This allows the system to install the packages only associated with the GPG key identified repository, not from other unknown sources.

```bash
mktemp -dmktemp -d
GNUPGHOME=$(mktemp -d)
GNUPGHOME="$GNUPGHOME" gpg --no-default-keyring --keyring /usr/share/keyrings/clickhouse-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8919F6BD2B48D754
rm -r "$GNUPGHOME"
chmod +r /usr/share/keyrings/clickhouse-keyring.gpg
```

![import-key](/assets/clickhouse-import-key.jpg)

## Add apt repository

In this step, we add the officially issued repository by the ClickHouse developers for Debian-based Linux. We are doing this because the packages to install this DBMS are not present through the system repo of Ubuntu.

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | sudo tee \
    /etc/apt/sources.list.d/clickhouse.list

apt update
```

![clickhouse-packages](/assets/clickhouse-packages.jpg)

> **NOTE:** If you face an error while running `apt update` add `nameserver 178.22.122.100` to `/etc/resolve.conf`

## Installing ClickHouse Server & Client

Once you have followed the above steps correctly, your Linux system becomes eligible to install the ClickHouse packages.

> **NOTE:** DO NOT ENTER DEFAULT USER PASSWORD

```bash
apt install -y clickhouse-server clickhouse-client
```

## Start the Server and check the status

The ClickHouse server will be installed with a background service. Now it's time to start its service.

```bash
systemctl start clickhouse-server
systemctl enable clickhouse-server
systemctl status clickhouse-server

clickhouse-client
```

![clickhouse-status](/assets/clickhouse-status.jpg)

> **NOTE:** If you have entered the default password already, follow the below steps to clean this out.
> 
> ```
> rm /etc/clickhouse-server/users.d/default-password.xml
> systemctl start clickhouse-server
> ```

## Configure Zookeeper for node1 and node2

Run these commands on both nodes

```bash
vim /etc/clickhouse-server/config.d/zookeeper.xml
```

```xml
<yandex>
    <zookeeper>
        <node>
            <host>zookeeper1</host>
            <port>2181</port>
        </node>
        <session_timeout_ms>30000</session_timeout_ms>
        <operation_timeout_ms>10000</operation_timeout_ms>
        <!-- Optional. Chroot suffix. Should exist. -->
        <!-- <root>/path/to/zookeeper/node</root> -->
        <!-- Optional. ZooKeeper digest ACL string. -->
        <!-- <identity>user:password</identity> -->
    </zookeeper>
    <!-- Allow to execute distributed DDL queries (CREATE, DROP, ALTER, RENAME) on cluster. -->
    <!-- Works only if ZooKeeper is enabled. Comment it out if such functionality isn't required. -->
    <distributed_ddl>
        <!-- Path in ZooKeeper to queue with DDL queries -->
        <path>/clickhouse/task_queue/ddl</path>
        <!-- Settings from this profile will be used to execute DDL queries -->
        <!-- <profile>default</profile> -->
    </distributed_ddl>
</yandex>
```

## Macro Settings for node1 and node2 Servers

Define the macro configuration by creating the file for macros in the file `/etc/clickhouse-server/config.d/macros.xml`.<br>
This sets how the shards and tables will set the paths of where they store the replicated tables.<br>
We have three values we care about

- **Cluster**: the name of our cluster will be **cluster_demo_ash**.
- **Shard**: We have just one shard, so we’ll make that number **1**.
- **Replica**: This value is **unique per node** and will be the node’s hostname.

```bash
vim /etc/clickhouse-server/config.d/macros.xml
```

```xml
<!-- write this in node1 -->
<yandex>
    <macros>
       <cluster>cluster_demo_ash</cluster>
        <shard>1</shard>
        <replica>node1</replica>
    </macros>
</yandex>

<!-- write this on node2 -->
<yandex>
    <macros>
       <cluster>cluster_demo_ash</cluster>
        <shard>1</shard>
        <replica>node2</replica>
    </macros>
</yandex>
```

![macros](/assets/clickhouse-macros.jpg)

## Define Cluster for node1 and node2 Servers

Create new file `cluster.xml` and define cluster with nodes in shard and replica on both nodes.

```bash
vim /etc/clickhouse-server/config.d/clusters.xml
```

```xml
<yandex>
    <remote_servers>
        <cluster_demo_ash>
            <shard>
                <replica>
                    <host>node1</host>
                    <port>9000</port>
                </replica>
                <replica>
                    <host>node2</host>
                    <port>9000</port>
                </replica>
            </shard>
        </cluster_demo_ash>
    </remote_servers>
</yandex>
```

![cluster](/assets/clickhouse-cluster.jpg)

## Open the remote connection

To enable internode communication within the cluster, make changes to the `listen_host` configuration to allow network access.<br>
Create a new file named `listen_host.xml` and make the following changes.<br>
After that, attempt to establish a remote connection from one ClickHouse node to another.

> **Note:** Restarting the ClickHouse service is required for the `listen_host` changes to take effect.

```bash
vim /etc/clickhouse-server/config.d/listen_host.xml
```

```xml
<clickhouse>
    <listen_host>::</listen_host>
</clickhouse>
```

```bash
systemctl restart clickhouse-server

# run this in node1
clickhouse-client --host=node2

# run this in node2
clickhouse-client --host=node1
```

![host-node](/assets/clickhouse-host-node.jpg)

## Verify ClickHouse Cluster

Check the status of the cluster by using the system tables `system.cluster`, which should display entries for all nodes that are part of the specified cluster.

```bash
clickhouse-client -q "SELECT * FROM system.clusters WHERE cluster='cluster_demo_ash' FORMAT Vertical;"
clickhouse-client -q "SELECT * FROM system.zookeeper WHERE path='/clickhouse/task_queue/'"
```

![system-cluster](/assets/clickhouse-system-clusters.jpg)

## Time to test

Create a sample Database and Replicated table for Cluster. Run these commands on `node1`

```bash
clickhouse-client --password your-password --user default

CREATE DATABASE IF NOT EXISTS test1 ON CLUSTER '{cluster}'
CREATE DATABASE IF NOT EXISTS test2 ON CLUSTER '{cluster}'

SHOW DATABASES

CREATE TABLE test1.students ON CLUSTER '{cluster}'
(
 user_id UInt32,
 name String
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/test1/students', '{replica}')
PRIMARY KEY (user_id)

INSERT INTO test1.students (user_id, name) VALUES
(101, 'Sanaz'),
(102, 'Radin')

SELECT * FROM test1.students
```

![create-table](/assets/clickhouse-create-table.jpg)

Go to `node2` and run these commands, you should see databases that you created in `node1`

```bash
clickhouse-client --password your-password --user default

SHOW DATABASES
```

![show-databases](/assets/clickhouse-show-databases.jpg)

Now everything is <span style="color: green">**DONE**</span>!

## Source of content

[Setup ClickHouse Cluster Replication with Zookeeper](https://chistadata.com/setup-clickhouse-cluster-replication-with-zookeeper/#Verify_Clickhouse_Cluster) <br>
[How to Install ClickHouse on Ubuntu 22.04 LTS Linux](https://www.how2shout.com/linux/how-to-install-clickhouse-on-ubuntu-22-04-lts-linux/) <br>