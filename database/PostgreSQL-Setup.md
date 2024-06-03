# Setup PostgreSQL on Ubuntu 22.04

![PostgreSQL-logo](/assets/PostgreSQL-logo.jpg)

## Introduction

PostgreSQL is an open-source database management system focusing on extensibility and SQL compliance. PostgreSQL is an advanced and enterprise-class RDBMS (Relational Database Management System) that supports both SQL (relational) and JSON (non-relational) querying.

## Prerequisites

For this task you will need 3 ubuntu servers.

| Hostname | IP              |
| -------- | --------------- |
| node1    | 192.168.211.101 |
| node2    | 192.168.211.102 |

Run this command on all servers:

```bash
vim /etc/hosts

192.168.211.101 node1
192.168.211.102 node2
```

![etc-hosts](/assets/PostgreSQL-etc-hosts.jpg)

## Installing PostgreSQL Server

Run these commands on both servers:

```bash
apt update

## Install some basic dependencies
apt install wget gnupg2 lsb-release curl apt-transport-https ca-certificates

## Download the PostgreSQL repository GPG key, convert the .asc file to .gpg
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc| gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

## Add the PostgreSQL repository
sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

apt update

## Install PostgreSQL package
apt install postgresql
```

Once installed, start and enable the service and check if the service is running:

```bash
systemctl start postgresql
systemctl enable postgresql
systemctl status postgresql

## check version
psql --version
```

![status](/assets/PostgreSQL-status.jpg)

## 	Configure Primary Node

```bash
vim /etc/postgresql/16/main/postgresql.conf

# line 60 : uncomment and change
listen_addresses = '*'
# line 211 : uncomment
wal_level = replica
# line 216 : uncomment
synchronous_commit = on
# line 314 : uncomment (max number of concurrent connections from streaming clients)
max_wal_senders = 10
# line 328 : uncomment and change
synchronous_standby_names = '*'
```

![primary-config1](/assets/PostgreSQL-primary-config1.jpg)
![primary-config2](/assets/PostgreSQL-primary-config2.jpg)
![primary-config3](/assets/PostgreSQL-primary-config3.jpg)

```bash
vim /etc/postgresql/16/main/pg_hba.conf

# add to the end
# host  replication  [replication user]   [allowed network]  [authentication method]
host    replication     replica_user     192.168.211.101/32      scram-sha-256
host    replication     replica_user     192.168.211.102/32      scram-sha-256
```

![primary-config4](/assets/PostgreSQL-primary-config4.jpg)


Now we need to create a user for replication

```bash
sudo - postgres
createuser --replication -P replica_user
## enter your password. exm: P@ssw0rd
exit

systemctl restart postgresql
```

## Configure Replica Node

```bash
## stop PostgreSQL and remove existing data
systemctl stop postgresql
rm -rf /var/lib/postgresql/16/main/*

## get backup from Primary Node
sudo - postgres
pg_basebackup -R -h node1 -U replica_user -D /var/lib/postgresql/16/main -P
## enter the password you set in primary node
exit

vim /etc/postgresql/16/main/postgresql.conf

## line 60 : uncomment and change
listen_addresses = '*'
## line 339 : uncomment
hot_standby = on

systemctl start postgresql
systemctl status postgresql
```

![replica-config](/assets/PostgreSQL-replica-config.jpg)

## Test The Replication Setup

Now `node1` will be the **`PRIMARY`** and `node2` will act as **`REPLICA`**.

### node1

To verify that the replica is connected to the primary node and that the primary is streaming,<br>
log into the primary server (`node1`) and switch to the postgres user.

```bash
sudo -u postgres psql
```

```sql
-- query the pg_stat_replication table which contains vital information about the replication
SELECT client_addr, state FROM pg_stat_replication;
```

![pg-stat](/assets/PostgreSQL-pg-stat.jpg)

```sql
-- Create a database
CREATE DATABASE students_db;

-- switch to the database
\c students_db;

-- create a table
CREATE TABLE student_details (first_name VARCHAR(15), last_name VARCHAR(15));

-- insert data into the table
INSERT INTO  student_details (first_name, last_name) VALUES  ('Sanaz', 'Sadr');
INSERT INTO  student_details (first_name, last_name) VALUES  ('Radin', 'Pirouz');

-- query the table to confirm the inserted records
SELECT * FROM student_details;
```

![primary-create-db](/assets/PostgreSQL-primary-create-db.jpg)

### node2

Now head over to the replica node (`node2`) and switch to the postgres user.

```bash
sudo -u postgres psql
```

```sql
-- verify the existence of the database
\l

-- switch to the database
\c students_db;

-- query the table for all the records stored
SELECT * FROM student_details;
```

![replica-test](/assets/PostgreSQL-replica-test.jpg)

Now everything is <span style="color: green">**DONE**</span>!

## Source of content

[PostgreSQL 14 : Streaming Replication](https://www.server-world.info/en/note?os=Ubuntu_22.04&p=postgresql&f=3) <br>
[Install and Configure PostgreSQL 16 on Ubuntu 22.04](https://computingforgeeks.com/install-and-configure-postgresql-on-ubuntu/) <br>
[How to Set up PostgreSQL Database Replication](https://www.cherryservers.com/blog/how-to-set-up-postgresql-database-replication#setup-physical-postgresql-replication-on-ubuntu-2204) <br>
[How to Set Up Multi-Master PostgreSQL Replication on Ubuntu 22.04](https://www.howtoforge.com/how-to-set-up-multi-master-postgresql-replication-on-ubuntu-22-04/) <br>