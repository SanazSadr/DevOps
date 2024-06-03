# Redis Cluster Replication and Redis Sentinel Failover (HA) with Endpoint Route HAProxy

## Prerequisites

Starting with 4 vm ubuntu 
 1. redis-a 192.168.211.101
 2. redis-b 192.168.211.102
 3. redis-c 192.168.211.103
 4. haproxy 192.168.211.105

## Things to do

1. implement redis cluster master/slave replication
   1. master node: redis-a 192.168.211.101 [ad joined, read/write]
      1. AD joined
      2. install redis-server
         1. update and upgrade
         2. install redis-server
         3. test redis
      3. install redis-sentinel
         1. install redis-sentinel
         2. stop sentinel service
      4. set permission for user: 'redis'
         1. sentinel conf
         2. sentinel log
      5. allow ports 6379, 26379, 22
      6. configure redis-server
         1. bind
         2. port
         3. protected-mode no
         4. restart redis-server
   2. slave node 1: redis-b 192.168.211.102 [ad joined, read only]
      1. AD joined
      2. install redis-server
         1. update and upgrade
         2. install redis-server
         3. test redis
      3. install redis-sentinel
         1. install redis-sentinel
         2. stop sentinel service
      4. set permission for user: 'redis'
         1. sentinel conf
         2. sentinel log
      5. allow ports main[6379, 26379], [for app test 22 not required]
      6. configure redis-server
         1. bind
         2. port
         3. protected-mode no
         4. slaveof master [redis-a 192.168.211.101]
         5. restart redis-server
   3. slave node 2: redis-c 192.168.211.103 [ad joined, read only]
      1. AD joined
      2. install redis-server
         1. update and upgrade
         2. install redis-server
         3. test redis
      3. install redis-sentinel
         1. install redis-sentinel
         2. stop sentinel service
      4. set permission for user: 'redis'
         1. sentinel conf
         2. sentinel log
      5. allow ports main[6379, 26379], [for app test 22 not required]
      6. configure redis-server
         1. bind
         2. port
         3. protected-mode no
         4. slaveof master [redis-a 192.168.211.101]
         5. restart redis-server
   4. replication test
2. implement redis failover using sentinel
   1. master node: redis-a 192.168.211.101
      1. configure sentinel.conf
         1. bind
         2. protected-mode no
         3. port
         4. monitor mymaster 192.168.211.101
         5. down time
         6. failover time
      2. configure sentinel.service
         1. start with redis-server
      3. reload daemon
      4. restart sentinel
      5. the change by sentinel in sentinel.conf
   2. slave node 1: redis-b 192.168.211.102
      1. configure sentinel.conf
         1. bind
         2. protected-mode no
         3. port
         4. monitor mymaster 192.168.211.101
         5. down time
         6. failover time
      2. configure sentinel.service
         1. start with redis-server
      3. reload daemon
      4. restart sentinel
      5. the change by sentinel in sentinel.conf
   3. slave node 2: redis-c 192.168.211.103
      1. configure sentinel.conf
         1. bind
         2. protected-mode no
         3. port
         4. monitor mymaster 192.168.211.101
         5. down time
         6. failover time
      2. configure sentinel.service
         1. start with redis-server
      3. reload daemon
      4. restart sentinel
      5. the change by sentinel in sentinel.conf
3. implement haproxy for redis [to identify master]
   1. already deployed haproxy
   2. add block for tcp mode for redis with send and expect rules
4. test from client
   when redis-b is down --> redis-a promote to master
   when redis-a is down --> redis-c promote to master

## First step (implement redis cluster master/slave replication)

### redis-a

```bash
apt update
apt upgrade
apt install redis-server -y

apt install redis-sentinel -y
systemctl stop sentinel

chown redis:redis /etc/redis/sentinel.conf
chown redis:redis /var/log/redis/redis-sentinel.log

ufw allow 6379
ufw allow 26379
ufw allow 22

vim /etc/redis/redis.conf
####
bind 192.168.211.101 127.0.0.1
protected-mode no
####
systemctl restart redis-server
redis-cli
ping
set name Sanaz
get name
info replication

apt update
apt upgrade
```

### redis-b

```bash
apt update
apt upgrade
apt install redis-server -y
redis-cli
ping
info replication

apt install redis-sentinel
systemctl stop  sentinel

chown redis:redis /etc/redis/sentinel.conf
chown redis:redis /var/log/redis/redis-sentinel.log

ufw allow 6379
ufw allow 26379
ufw allow 22

vim /etc/redis/redis.conf
###
bind 192.168.211.102 127.0.0.1
protected-mode no
slaveof 192.168.211.101 6379
###
systemctl restart redis-server

redis-cli
get name

apt update
apt upgrade
```

Run these commands on `server-a` and check the output. One slave node should have been added.

```bash
redis-cli
info replication
```

### redis-c

```bash
apt update
apt upgrade
apt install redis-server -y
redis-cli
ping
info replication

apt install redis-sentinel
systemctl stop  sentinel

chown redis:redis /etc/redis/sentinel.conf
chown redis:redis /var/log/redis/redis-sentinel.log

ufw allow 6379
ufw allow 26379
ufw allow 22

vim /etc/redis/redis.conf
###
bind 192.168.211.103 127.0.0.1
protected-mode no
slaveof 192.168.211.101 6379
###
systemctl restart redis-server

redis-cli
get name
```

## Second step (implement redis failover using sentinel)

### redis-a

```bash
vim /etc/redis/sentinel.conf
###
# bind 127.0.0.1 192.168.1.1
bind 192.168.211.101 127.0.0.1
protected-mode no
sentinel monitor mymaster 192.168.211.101 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 7000
###

vim /etc/systemd/system/sentinel.service
###
ExecStart=/usr/bin/redis-server /etc/redis/sentinel.conf --sentinel
###

systemctl daemon-reload 
systemctl start sentinel
systemctl restart sentinel

redis-cli -p 26379
info sentinel

vim /etc/redis/sentinel.conf
###
sentinel know-slave mymaster 192.168.211.102 6379
sentinel know-slave mymaster 192.168.211.103 6379
sentinel current-epoch 0
###
```

### redis-b

```bash
vim /etc/redis/sentinel.conf
###
# bind 127.0.0.1 192.168.1.1
bind 192.168.211.102 127.0.0.1
protected-mode no
sentinel monitor mymaster 192.168.211.101 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 7000
###

vim /etc/systemd/system/sentinel.service
###
ExecStart=/usr/bin/redis-server /etc/redis/sentinel.conf --sentinel
###

systemctl daemon-reload 
systemctl start sentinel
systemctl restart sentinel
```

Run these commands on `server-a` and check the output:

```bash
redis-cli -p 26379
info sentinel
```

Continue on `server-b`:

```bash
vim /etc/redis/sentinel.conf
###
sentinel know-slave mymaster 192.168.211.103 6379
sentinel know-slave mymaster 192.168.211.102 6379
sentinel know-sentinel mymaster 192.168.211.101 6379 ...
sentinel current-epoch 0
###
```

### redis-c

```bash
vim /etc/redis/sentinel.conf
###
# bind 127.0.0.1 192.168.1.1
bind 192.168.211.103 127.0.0.1
protected-mode no
sentinel monitor mymaster 192.168.211.101 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 7000
###

vim /etc/systemd/system/sentinel.service
###
ExecStart=/usr/bin/redis-server /etc/redis/sentinel.conf --sentinel
###

systemctl daemon-reload 
systemctl start sentinel
systemctl restart sentinel
```

Run these commands on `server-a` and check the output:

```bash
redis-cli -p 26379
info sentinel
```

Continue on `server-c`:

```bash
vim /etc/redis/sentinel.conf
###
sentinel know-slave mymaster 192.168.211.103 6379
sentinel know-slave mymaster 192.168.211.102 6379
sentinel know-sentinel mymaster 192.168.211.101 6379 ...
sentinel know-sentinel mymaster 192.168.211.102 6379 ...
sentinel current-epoch 0
###
```

## Third step (implement haproxy for redis [to identify master])

### HAProxy

```bash
apt update
apt upgrade
apt install haproxy
systemctl start haproxy
systemctl enable haproxy

vim /etc/haproxy/haproxy.cfg
###

listen stats
      bind *:1936
      stats enable
      stats hide-version
      stats refresh 30s
      stats show-node
      stats uri /stats

# redis block start

defaults REDIS
        mode tcp
        timeout connect 4s
        timeout server 30s
        timeout client 30s

frontend front_redis
        bind 192.168.211.105:6379 name redis
        default_backend back_redis

backend back_redis
        option tcp-check
        tcp-check send PING\r\n
        tcp-check expect string +PONG
        tcp-check send info\ replication\r\n
        tcp-check expect string role:master
        tcp-check send QUIT\r\n
        tcp-check expect string +OK

        server redis-a 192.168.211.101:6379 check inter 1s
        server redis-b 192.168.211.102:6379 check inter 1s
        server redis-c 192.168.211.103:6379 check inter 1s

# redis block end
###

systemctl restart haproxy
```

On browser check this ip `192.168.211.105:1936/stats`<br/>
`redis-a` in master now, and as check policy its online.


## Fourth step (test from client)

Shutdown `server-a` or stop redis on it with this command `systemctl stop redis-server`, then check `haproxy` server browser for new master.

Turn `server-a` back on or start redis on it with this command `systemctl start redis-server` and check `haproxy` for changes.

## Reference

[Redis Cluster Replication and Redis Sentinel Failover (HA) with Endpoint Route HAProxy](https://www.youtube.com/watch?v=J27AcaVuAPM)