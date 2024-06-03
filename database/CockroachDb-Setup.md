# Setup CockroachDB on Ubuntu 22.04

![cockroach-logo](/assets/cockroach-logo.jpg)

## Prerequisites

For this task you will need 3 ubuntu servers.

| Hostname | IP              |
| -------- | --------------- |
| node1    | 192.168.211.101 |
| node2    | 192.168.211.102 |
| node3    | 192.168.211.103 |

## Setup Time Synchronization

Time synchronization is crucial for the proper functioning of a CockroachDB cluster. We will use `chrony` to synchronize the time between all nodes.

Run these commands on all three servers:

```bash
apt update
apt upgrade
apt install -y chrony
vim /etc/chrony/chrony.conf

# Locate the default pool lines in the configuration file and replace them with the following lines
##########################################
pool 0.id.pool.ntp.org iburst maxsources 4
pool 1.id.pool.ntp.org iburst maxsources 1
pool 2.id.pool.ntp.org iburst maxsources 1
pool 3.id.pool.ntp.org iburst maxsources 2
##########################################
```
![chrony-config](/assets/cockroach-chrony-conf.jpg)

```bash
systemctl restart chrony
systemctl enable chrony
systemctl status chrony
```

![chrony-status](/assets/cockroach-chrony-status.jpg)

## Install CockroachDB

Run these commands on all three servers:

```bash
wget https://binaries.cockroachdb.com/cockroach-v23.2.2.linux-amd64.tgz
```

After running this command in Iran, you will get <span style="color: red">**403**</span> error :)

![403](/assets/cockroach-403.jpg)

To resolve this pleasant issue do this and try again:

```bash
vim /etc/resolv.conf

nameserver 185.51.200.2
```
Now go on and continue what you were doing:

```bash
tar -xvzf cockroach-v23.2.2.linux-amd64.tgz
```

![tar-file](/assets/cockroach-tar-file.jpg)

```bash
cp cockroach-*/cockroach /bin

cockroach version
```

If you saw the version after the last command, it means that you have done everything good so far.

![version](/assets/cockroach-version.jpg)


## Create Certificates

CockroachDB requires server and client certificates for secure communication. In this step, we will create the necessary certificates.

Run these commands on all three servers:

```bash
mkdir ~/certs
```

Create a CA certificate on `node1` and copy the generated CA certificate to both `node2` and `node3` using the following command:

```bash
cockroach cert create-ca --certs-dir=certs --ca-key=certs/ca.key

scp ~/certs/ca.crt ~/certs/ca.key root@192.168.211.102:~/certs/
scp ~/certs/ca.crt ~/certs/ca.key root@192.168.211.103:~/certs/
```

You may face an error like this while running `scp` command:

![access-denied](/assets/cockroach-access-denied.jpg)

For fixing this issue, run these command on `node2` and `node3`

```bash
vim /etc/ssh/sshd_config

# write the following line in config file
PermitRootLogin yes

systemctl restart ssh

# set password for root user
sudo passwd
```

Now run `scp` command again, the result should be like this:

![scp](/assets/cockroach-scp.jpg)

Check destination servers for this:

![certs](/assets/cockroach-certs.jpg)

Run this command on all three servers to generate a client certificate:

```bash
cockroach cert create-client root --certs-dir=certs --ca-key=certs/ca.key
```

And then run this on each server separately:

```bash
cockroach cert create-node localhost $(hostname) 192.168.211.101 --certs-dir=certs --ca-key=certs/ca.key
cockroach cert create-node localhost $(hostname) 192.168.211.102 --certs-dir=certs --ca-key=certs/ca.key
cockroach cert create-node localhost $(hostname) 192.168.211.103 --certs-dir=certs --ca-key=certs/ca.key
```

![create-node](/assets/cockroach-create-node.jpg)

## Start CockroachDB Cluster

On `node1`, run the following command

```bash
cockroach start --background --certs-dir=certs --advertise-host=192.168.211.101 --join=192.168.211.101,192.168.211.102,192.168.211.103
cockroach init --certs-dir=certs --host=192.168.211.101
cockroach node status --certs-dir=certs --host=192.168.211.101
```
![start-cockroachDB-cluster](/assets/cockroach-start-cockroachDB-cluster.jpg)

## Add Remaining Nodes to the Cluster

Now that the first node is running, we can add the remaining nodes to the CockroachDB cluster.

```bash
## run this command on node2
cockroach start --background --certs-dir=certs --advertise-host=192.168.211.102 --listen-addr=192.168.211.102 --join=192.168.211.101:26257

## run this command on node3
cockroach start --background --certs-dir=certs --advertise-host=192.168.211.103 --listen-addr=192.168.211.103 --join=192.168.211.101:26257
```
![add-remaining-nodes](/assets/cockroach-add-remaining-nodes.jpg)

Go back to `node1` and check the status of the CockroachDB cluster by running the following command

```bash
cockroach node status --certs-dir=certs --host=192.168.211.101
```

![node-status](/assets/cockroach-node-status.jpg)

## Access CockroachDB Dashboard

CockroachDB provides a web-based dashboard that allows you to monitor and manage the cluster. <br>
Run these commands on `node1`

```bash
## Log into the CockroachDB SQL shell
cockroach sql --certs-dir=certs --host=192.168.211.101

## Create an admin user and set a password
CREATE USER user1 WITH PASSWORD 'securepassword';
```

Exit the SQL shell <br>
Open your web browser and enter the URL https://192.168.211.101:8080 <br>
Enter your admin username and password, then click on the “LOG IN” button.

![login](/assets/cockroach-login.jpg)

## Verify Database Replication

In this step, we will verify whether the database is replicated across all nodes in the CockroachDB cluster.

```bash
## Log into the CockroachDB SQL shell on node1
cockroach sql --certs-dir=certs --host=192.168.211.101

## Create two databases named test1 and test2
CREATE DATABASE test1;
CREATE DATABASE test2;

## Verify the databases
SHOW DATABASES;
```
![create-database](/assets/cockroach-create-database.jpg)

Now you should log into the CockroachDB SQL shell on `node2` and `node3`

```bash
## on node2
cockroach sql --certs-dir=certs --host=192.168.211.102

## on node3
cockroach sql --certs-dir=certs --host=192.168.211.103

## on both nodes
SHOW DATABASES;
```

After the last command you should see `test1` and `test2` on both servers.

![show-databases](/assets/cockroach-show-databases-srv3.jpg)

Now everything is <span style="color: green">**Done**</span>, you can enjoy your replicated database.

## Keep you database up after reboot

After rebooting or powering off your server, your database goes down and it should be started manually.<br>
For fixing this issue, do this:

### node1

```bash
vim /usr/local/sbin/start_cockroachdb
###############################################
#!/bin/bash

sleep 10
cockroach start --background --certs-dir=certs --advertise-host=192.168.211.101 --join=192.168.211.101,192.168.211.102,192.168.211.103
###############################################

chmod +x /usr/local/sbin/start_cockroachdb

vim /etc/crontab
###############################################
@reboot         root    /usr/local/sbin/start_cockroachdb
###############################################
```

### node2

```bash
vim /usr/local/sbin/start_cockroachdb
###############################################
#!/bin/bash

sleep 30
cockroach start --background --certs-dir=certs --advertise-host=192.168.211.102 --listen-addr=192.168.211.102 --join=192.168.211.101:26257
###############################################

chmod +x /usr/local/sbin/start_cockroachdb

vim /etc/crontab
###############################################
@reboot         root    /usr/local/sbin/start_cockroachdb
###############################################
```

### node3

```bash
vim /usr/local/sbin/start_cockroachdb
###############################################
#!/bin/bash

sleep 50
cockroach start --background --certs-dir=certs --advertise-host=192.168.211.103 --listen-addr=192.168.211.103 --join=192.168.211.101:26257
###############################################

chmod +x /usr/local/sbin/start_cockroachdb

vim /etc/crontab
###############################################
@reboot         root    /usr/local/sbin/start_cockroachdb
###############################################
```

Now everything is <span style="color: green">**REALLY DONE**</span>!

## Source of content

[How to Install a CockroachDB Cluster on Ubuntu 22.04](https://www.howtoforge.com/how-to-install-cockroachdb-on-ubuntu-22-04/) <br>
[Allow SSH root login on Ubuntu 22.04 Jammy Jellyfish Linux](https://linuxconfig.org/allow-ssh-root-login-on-ubuntu-22-04-jammy-jellyfish-linux) <br>
[How to Securely Copy Files in Linux | scp Command](https://www.geeksforgeeks.org/scp-command-in-linux-with-examples/) <br>