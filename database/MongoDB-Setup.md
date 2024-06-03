# Setup MongoDB on Ubuntu 22.04

![MongoDB-logo](/assets/MongoDB-logo.jpg)

## Introduction

In MongoDB, a replica set is a group of mongod processes that maintain the same data set.<br>
Replica sets are the basis for all production deployments as they provide data redundancy and high availability.

![structure](/assets/MongoDB-structure.jpg)

## Prerequisites

For this task you will need 3 ubuntu servers.

| Hostname | IP              |
| -------- | --------------- |
| node1    | 192.168.211.101 |
| node2    | 192.168.211.102 |
| node3    | 192.168.211.103 |

Run this command on all servers:

```bash
vim /etc/hosts

192.168.211.101 node1
192.168.211.102 node2
192.168.211.103 node3
```

![etc-hosts](/assets/MongoDB-etc-hosts.jpg)

## Install MongoDB

Run these commands on all three servers:

```bash
apt update

## Import MongoDB public GPG Key
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-6.gpg

## Add the repository
echo "deb https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

apt update

## Install MongoDB packages
apt install mongodb-org
```

> **NOTE:** If you face 403 error, do this:
>
> ```bash
> vim /etc/resolv.conf
> 
> nameserver 185.51.200.2
> ```
>
> and the try again running `apt update`


## Configure MongoDB Replica set

Now that we have everything needed ready, let’s proceed to configure MongoDB replica set.

```bash
vim /etc/mongod.conf

############################
## Write this on node1
net:
  port: 27017
  bindIp: 127.0.0.1, node1

## Write this on node2
net:
  port: 27017
  bindIp: 127.0.0.1, node2

## Write this on node3
net:
  port: 27017
  bindIp: 127.0.0.1, node3
############################
```

One of the MongoDB nodes run as the `PRIMARY`, and all other nodes will work as `SECONDARY`.<br>
Data is always to the `PRIMARY` node and the data sets are then replicated to all other `SECONDARY` nodes.

```bash
vim /etc/mongod.conf

############################
## Write this on all nodes
replication:
  replSetName: "replica01"
############################
```

![config](/assets/MongoDB-config.jpg)

After making these changes to each server’s `mongod.conf` file, save and close each file.<br>
Then, restart the mongod service on all three servers:

```bash
systemctl enable mongod
systemctl restart mongod
systemctl status mongod

ss -ntlp | grep -i mongo
```

![status](/assets/MongoDB-status.jpg)

## Initiate MongoDB Replica Set

Our MongoDB `node1` will be the **`PRIMARY`** and the other two will act as **`SECONDARY`**.

Login to the `node1` server and start the mongo shell.

```sql
mongosh

-- rs.initiate(
--   {
--     _id: "replica01",
--     members: [
--       { _id: 0, host: "node1" },
--       { _id: 1, host: "node2" },
--       { _id: 2, host: "node3" },
--     ]
--   }
-- )

rs.initiate()
rs.add("node2")
rs.add("node3")
rs.status()
rs.isMaster()

exit
```

![initiate](/assets/MongoDB-initiate.jpg)

## Test DataBase Replication

Login to the `node1` server by `mongosh` command.

```sql
use test_db

db.createCollection("students")
db.students.insertOne({"title": "Sanaz"})
db.students.insertOne({"title": "Radin"})

show dbs
show collections
```

![create-database](/assets/MongoDB-create-database.jpg)

Now login to other two servers by `mongosh` command, then run these commands:

```sql
show dbs
use test_db
show collections
```

Check dbs in other nodes:

![test-replication-db](/assets/MongoDB-test-replication-db.jpg)

Check collections info in all nodes:

![test-replication-detail](/assets/MongoDB-test-replication-detail.jpg)

Now everything is <span style="color: green">**DONE**</span>!

## Source of content

[Configure MongoDB Replication On Ubuntu 22.04](https://computingforgeeks.com/configure-mongodb-replica-set-on-ubuntu/) <br>
[How To Configure a MongoDB Replica Set on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-configure-a-mongodb-replica-set-on-ubuntu-20-04) <br>