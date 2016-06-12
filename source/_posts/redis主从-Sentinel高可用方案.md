---
title: redis主从+Sentinel高可用方案
tags:
  - redis
date: 2016-06-12 15:12:12
categories: 运维
---

生产环境redis一直处于单节点运行模式，如果出现故障，则会无法提供服务，因此需要提高redis服务的高可用性，因为本身访问量并不是十分大，另外并无运维人力投入进行维护，因此并不考虑集群方案。通过综合考虑研究采用redis主从，加上redis sentinel组件搭建高可用的redis方案。

redis主从保证了数据的可靠性，而redis sentinel可以提升其可用性。redis sentinel为redis主从集群提供了：1)master存活检测、2)集群主从服务监控、3) 自动故障转移
一般情况下,最小redis主从集群单元由一个maste和slave组成,当master失效后,sentinel可以帮助我们自动将slave提升为master；有了sentinel组件,可以减少系统管理员的人工切换slave的操作过程。

但是一般情况下，主从分别部署在不同的服务器上，对外服务IP不同，当sentinel进行了主从切换后，应用程序如何切换访问新的master。而实际上应用程序可以通过访问sentinel获取最新master，从而达到无缝的切换（Jedis提供了JedisSentinelPool，但在主从切换后需主动重新获取新的连接；而spring-data-redis中使用RedisTemplates进行调用不会有该问题，具体见后面章节）

# redis 主从
redis的主从配置十分简单，只需要在slave中设置slaveof <masterip> <masterport>即可

例如：
master配置redis_6380.conf：
```
################################ GENERAL  #####################################
daemonize yes
pidfile "/jeffxue/log/redis/redis_6380.pid"
port 6380
tcp-backlog 511
bind 192.168.1.100
# unixsocket /tmp/redis.sock
# unixsocketperm 700
timeout 300
tcp-keepalive 0
loglevel notice
logfile "/jeffxue/log/redis/redis_6380.log"
# syslog-enabled no
# syslog-ident redis
# syslog-facility local0
databases 16

################################ SNAPSHOTTING  ################################
# save ""
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename "dump_6380.rdb"
dir "/jeffxue/redis-data"

################################# REPLICATION #################################
# slaveof <masterip> <masterport>
masterauth "123456"
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
# repl-ping-slave-period 10
# repl-timeout 60
repl-disable-tcp-nodelay no
# repl-backlog-size 1mb
# repl-backlog-ttl 3600
slave-priority 100
# min-slaves-to-write 3
# min-slaves-max-lag 10

################################## SECURITY ###################################
requirepass "123456"
# rename-command CONFIG ""

################################### LIMITS ####################################
maxclients 10000
maxmemory 1gb
maxmemory-policy volatile-lru
# maxmemory-samples 3

############################## APPEND ONLY MODE ###############################
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes

################################ LUA SCRIPTING  ###############################
lua-time-limit 5000

################################## SLOW LOG ###################################
slowlog-log-slower-than 10000
slowlog-max-len 128

################################ LATENCY MONITOR ##############################
latency-monitor-threshold 0

############################# Event notification ##############################
notify-keyspace-events ""

############################### ADVANCED CONFIG ###############################
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-entries 512
list-max-ziplist-value 64
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
```

slave配置redis_6381.conf:
```
################################ GENERAL  #####################################
daemonize yes
pidfile "/jeffxue/log/redis/redis_6381.pid"
port 6381
tcp-backlog 511
bind 192.168.1.101
# unixsocket /tmp/redis.sock
# unixsocketperm 700
timeout 300
tcp-keepalive 0
loglevel notice
logfile "/jeffxue/log/redis/redis_6381.log"
# syslog-enabled no
# syslog-ident redis
# syslog-facility local0
databases 16

################################ SNAPSHOTTING  ################################
# save ""
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename "dump_6381.rdb"
dir "/jeffxue/redis-data"

################################# REPLICATION #################################
slaveof 192.168.1.100 6380
masterauth "123456"
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
# repl-ping-slave-period 10
# repl-timeout 60
repl-disable-tcp-nodelay no
# repl-backlog-size 1mb
# repl-backlog-ttl 3600
slave-priority 100
# min-slaves-to-write 3
# min-slaves-max-lag 10

################################## SECURITY ###################################
requirepass "123456"
# rename-command CONFIG ""

################################### LIMITS ####################################
maxclients 10000
maxmemory 3gb
# maxmemory-policy volatile-lru
# maxmemory-samples 3

############################## APPEND ONLY MODE ###############################
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes

################################ LUA SCRIPTING  ###############################
lua-time-limit 5000

################################## SLOW LOG ###################################
slowlog-log-slower-than 10000
slowlog-max-len 128

################################ LATENCY MONITOR ##############################
latency-monitor-threshold 0

############################# Event notification ##############################
notify-keyspace-events ""

############################### ADVANCED CONFIG ###############################
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-entries 512
list-max-ziplist-value 64
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
```

启动master和slave：
```
./redis-server redis_6380.conf
./redis-server redis_6381.conf
```

观察对应的日志看见主从连接正常，slave配置为只读，手工从master中进行set操作后，可以在slave中get得到相应数据

它们各自的redis.conf配置项中,除了port不同外,要求其他的配置完全一样(包括aof/snap,memory,rename以及授权密码等);原因是基于sentinel做故障转移,所有的server运行机制都必须一样,它们只不过在运行时"角色"不同,而且它们的角色可能在故障时会被转换;slave在某些时刻也会成为master,尽管在一般情况下,slave的数据持久方式经常采取snapshot,而master为aof,不过基于sentinel之后,slave和master均要采取aof(通过bgsave,手动触发snapshot备份)

# redis sentinel
## sentinel工作基本原理

首先解释2个名词:SDOWN和ODOWN.
- SDOWN:subjectively down,直接翻译的为"主观"失效,即当前sentinel实例认为某个redis服务为"不可用"状态.
- ODOWN:objectively down,直接翻译为"客观"失效,即多个sentinel实例都认为master处于"SDOWN"状态,那么此时master将处于ODOWN,ODOWN可以简单理解为master已经被集群确定为"不可用",将会开启failover.
SDOWN适合于master和slave,但是ODOWN只会使用于master;当slave失效超过"down-after-milliseconds"后,那么所有sentinel实例都会将其标记为"SDOWN".

### SDOWN与ODOWN转换过程

1. 每个sentinel实例在启动后,都会和已知的slaves/master以及其他sentinels建立TCP连接,并周期性发送PING(默认为1秒)
2. 在交互中,如果redis-server无法在"down-after-milliseconds"时间内响应或者响应错误信息,都会被认为此redis-server处于SDOWN状态.
3. 如果步骤2中SDOWN的server为master,那么此时sentinel实例将会向其他sentinel间歇性(一秒)发送"is-master-down-by-addr <ip> <port>"指令并获取响应信息,如果足够多的sentinel实例检测到master处于SDOWN,那么此时当前sentinel实例标记master为ODOWN...其他sentinel实例做同样的交互操作.配置项"sentinel monitor <mastername> <masterip> <masterport> <quorum>",如果检测到master处于SDOWN状态的sentinel个数达到<quorum>,那么此时此sentinel实例将会认为master处于ODOWN.
4. 每个sentinel实例将会间歇性(10秒)向master和slaves发送"INFO"指令,如果master失效且没有新master选出时,每1秒发送一次"INFO";"INFO"的主要目的就是获取并确认当前集群环境中slaves和master的存活情况.
经过上述过程后,所有的sentinel对master失效达成一致后,开始failover.

### sentinel与slaves"自动发现"机制

在sentinel的配置文件中,都指定了port,此port就是sentinel实例侦听其他sentinel实例建立链接的端口.在集群稳定后,最终会每个sentinel实例之间都会建立一个tcp链接,此链接中发送"PING"以及类似于"is-master-down-by-addr"指令集,可用用来检测其他sentinel实例的有效性以及"ODOWN"和"failover"过程中信息的交互.

在sentinel之间建立连接之前,sentinel将会尽力和配置文件中指定的master建立连接.sentinel与master的连接中的通信主要是基于pub/sub来发布和接收信息,发布的信息内容包括当前sentinel实例的侦听端口:
```
sentinel sentinel 127.0.0.1:26579 127.0.0.1 26579 ....  
```

发布的主题名称为"__sentinel__:hello";同时sentinel实例也是"订阅"此主题,以获得其他sentinel实例的信息.由此可见,环境首次构建时,在默认master存活的情况下,所有的sentinel实例可以通过pub/sub即可获得所有的sentinel信息,此后每个sentinel实例即可以根据+sentinel信息中的"ip+port"和其他sentinel逐个建立tcp连接即可.不过需要提醒的是,每个sentinel实例均会间歇性(5秒)向"__sentinel__:hello"主题中发布自己的ip+port,目的就是让后续加入集群的sentinel实例也能或得到自己的信息.

根据上文,我们知道在master有效的情况下,即可通过"INFO"指令获得当前master中已有的slave列表;此后任何slave加入集群,master都会向"主题中"发布"+slave 127.0.0.1:6579 ..",那么所有的sentinel也将立即获得slave信息,并和slave建立链接并通过PING检测其存活性.

补充一下,每个sentinel实例都会保存其他sentinel实例的列表以及现存的master/slaves列表,各自的列表中不会有重复的信息(不可能出现多个tcp连接),对于sentinel将使用ip+port做唯一性标记,对于master/slaver将使用runid做唯一性标记,其中redis-server的runid在每次启动时都不同.

### Leader选举

其实在sentinels故障转移中，仍然需要一个“Leader”来调度整个过程：master的选举以及slave的重配置和同步。当集群中有多个sentinel实例时，如何选举其中一个sentinel为leader呢？

在配置文件中“can-failover” “quorum”参数，以及“is-master-down-by-addr”指令配合来完成整个过程。
1.  “can-failover”用来表明当前sentinel是否可以参与“failover”过程，如果为“YES”则表明它将有能力参与“Leader”的选举，否则它将作为“Observer”，observer参与leader选举投票但不能被选举；
2.  “quorum”不仅用来控制master ODOWN状态确认，同时还用来选举leader时最小“赞同票”数；
3. “is-master-down-by-addr”，在上文中以及提到，它可以用来检测“ip + port”的master是否已经处于SDOWN状态，不过此指令不仅能够获得master是否处于SDOWN，同时它还额外的返回当前sentinel本地“投票选举”的Leader信息(runid);

每个sentinel实例都持有其他的sentinels信息，在Leader选举过程中(当为leader的sentinel实例失效时，有可能master server并没失效，注意分开理解)，sentinel实例将从所有的sentinels集合中去除“can-failover = no”和状态为SDOWN的sentinels，在剩余的sentinels列表中按照runid按照“字典”顺序排序后，取出runid最小的sentinel实例，并将它“投票选举”为Leader，并在其他sentinel发送的“is-master-down-by-addr”指令时将推选的runid追加到响应中。每个sentinel实例都会检测“is-master-down-by-addr”的响应结果，如果“投票选举”的leader为自己，且状态正常的sentinels实例中，“赞同者”的自己的sentinel个数不小于(>=) 50% + 1,且不小与<quorum>，那么此sentinel就会认为选举成功且leader为自己。

在sentinel.conf文件中，我们期望有足够多的sentinel实例配置“can-failover yes”，这样能够确保当leader失效时，能够选举某个sentinel为leader，以便进行failover。如果leader无法产生，比如较少的sentinels实例有效，那么failover过程将无法继续.

### failover过程:

在Leader触发failover之前，首先wait数秒(随即0~5)，以便让其他sentinel实例准备和调整(有可能多个leader??),如果一切正常，那么leader就需要开始将一个salve提升为master，此slave必须为状态良好(不能处于SDOWN/ODOWN状态)且权重值最低(redis.conf中)的，当master身份被确认后，开始failover

    A）“+failover-triggered”： Leader开始进行failover，此后紧跟着“+failover-state-wait-start”，wait数秒。
    B）“+failover-state-select-slave”： Leader开始查找合适的slave
    C）“+selected-slave”： 已经找到合适的slave
    D）“+failover-state-sen-slaveof-noone”： Leader向slave发送“slaveof no one”指令，此时slave已经完成角色转换，此slave即为master
    E）“+failover-state-wait-promotition”： 等待其他sentinel确认slave
    F）“+promoted-slave”：确认成功
    G）“+failover-state-reconf-slaves”： 开始对slaves进行reconfig操作。
    H）“+slave-reconf-sent”：向指定的slave发送“slaveof”指令，告知此slave跟随新的master
    I）“+slave-reconf-inprog”：此slave正在执行slaveof + SYNC过程，如过slave收到“+slave-reconf-sent”之后将会执行slaveof操作。
    J）“+slave-reconf-done”：此slave同步完成，此后leader可以继续下一个slave的reconfig操作。循环G）
    K）“+failover-end”：故障转移结束
    L）“+switch-master”：故障转移成功后，各个sentinel实例开始监控新的master。

## 配置
根据声明Leader选举规则可知，sentinel的数量应为奇数，次数配置3个sentinel

sentinel_26379.conf
```
daemonize yes
port 26379
dir "/tmp"
logfile "/jeffxue/log/redis/sentinel_26379.log"
# sentinel announce-ip 1.2.3.4
sentinel monitor mymaster 192.168.1.100 6380 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel auth-pass mymaster 123456
```

sentinel_26380.conf
```
daemonize yes
port 26380
dir "/tmp"
logfile "/jeffxue/log/redis/sentinel_26380.log"
# sentinel announce-ip 1.2.3.4
sentinel monitor mymaster 192.168.1.100 6380 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel auth-pass mymaster 123456
```

sentinel_26381.conf
```
daemonize yes
port 26381
dir "/tmp"
logfile "/jeffxue/log/redis/sentinel_26381.log"
# sentinel announce-ip 1.2.3.4
sentinel monitor mymaster 192.168.1.100 6380 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel auth-pass mymaster 123456
```

启动sentinel：
```
./redis-sentinel sentinel_26379.conf --sentinel
./redis-sentinel sentinel_26380.conf --sentinel
./redis-sentinel sentinel_26381.conf --sentinel
```

# 应用程序访问



## jedis
```
package cn.jeffxue.test;

import org.apache.commons.pool2.impl.GenericObjectPoolConfig;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisSentinelPool;

import java.util.HashSet;
import java.util.Set;

public class JedisTest {

    public static void main(String[] args) throws InterruptedException {

        Set<String> sentinels = new HashSet<String>();

        GenericObjectPoolConfig poolConfig = new GenericObjectPoolConfig();
        poolConfig.setMaxTotal(100);

        sentinels.add("192.168.1.102:26379");
        sentinels.add("192.168.1.103:26380");
        sentinels.add("192.168.1.104:26381");

        JedisSentinelPool sentinelPool = new JedisSentinelPool("mymaster", sentinels, poolConfig, 300, "123456");

        Jedis jedis = sentinelPool.getResource();

        System.out.println("current Host:" + sentinelPool.getCurrentHostMaster());

        String key = "mykey";

        String cacheData = jedis.get(key);

        if (cacheData == null) {
            jedis.del(key);
        }

        // 写入
        jedis.set(key, "first write");

        // 读取
        System.out.println(jedis.get(key));

        // down掉master，观察slave是否被提升为master
        System.out.println("current Host:" + sentinelPool.getCurrentHostMaster());

        // 测试新master的写入，此处将抛出异常
        try {
            jedis.set(key, "second write");
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 观察读取是否正常，此处将抛出异常
        try {
            System.out.println(jedis.get(key));
        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("current Host:" + sentinelPool.getCurrentHostMaster());

        //重新获取
        jedis = sentinelPool.getResource();

        // 观察读取是否正常
        jedis.set(key, "third write");

        // 观察读取是否正常
        System.out.println(jedis.get(key));

        sentinelPool.close();
        jedis.close();

    }

}

```

## spring-data-redis
具体见：http://www.cnblogs.com/yjmyzz/p/integrate-redis-with-spring.html

