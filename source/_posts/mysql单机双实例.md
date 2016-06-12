---
title: mysql单机双实例
tags:
  - mysql
date: 2016-06-12 16:43:38
categories: 运维
---
由于后续进行数据库读写分离，需要在开发环境中部署主从数据库，为了节省资源，主从数据库将部署在同一台服务器中，因此针对单机双实例场景配置进行说明。

此处并不对如何安装mysql进行说明，具体可见[github脚本](https://raw.githubusercontent.com/JeffXue/common_scripts/master/install_mysql5.6.sh)

实际上单机多实例，只需要对配置进行修改即可轻松实现：

- 创建主从数据库数据目录
```
mkdir /usr/local/mysql/data
mkdir /usr/local/mysql/data_slave
chown -R mysql:mysql /usr/local/mysql/data
chown -R mysql:mysql /usr/local/mysql/data_slave
```

- 配置my.cnf
```
[mysqld_multi]
mysqld = /opt/mysql/server-5.6/bin/mysqld_safe
mysqladmin = /opt/mysql/server-5.6/bin/mysqladmin
log = /opt/mysql/server-5.6/mysqld_multi.log

[mysqld1]
socket          = /tmp/mysqld_master.sock
port            = 3306
pid-file        = /opt/mysql/server-5.6/data/mysql_master.pid
datadir         = /opt/mysql/server-5.6/data

character_set_server=utf8

log-bin=/opt/mysql/server-5.6/data/mysql-bin-master
server-id       = 1
......
......

[mysqld2]
socket          = /tmp/mysqld_slave.sock
port            = 3307
pid-file        = /opt/mysql/server-5.6/data_slave/mysql_slave.pid
datadir         = /opt/mysql/server-5.6/data_slave

character_set_server=utf8

log-bin=/opt/mysql/server-5.6/data_slave/mysql-bin-slave
server-id       = 2
......
......

```

- 初始化数据库
```
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data_slave
```

- 修改path
相关操作前需要将相应的mysql bin路径添加到path中
```
#临时添加到path中
export PATH=/usr/local/mysql/bin:$PATH
```

- 启动/停止数据库

直接启动多实例：
```
/usr/local/mysql/bin/mysqld_multi --defaults-file=/usr/local/mysql/my.cnf start 
```

指定实例启动
```
/usr/local/mysql/bin/mysqld_multi --defaults-file=/usr/local/mysql/my.cnf start 1
```

直接停止多实例
```
/usr/local/mysql/bin/mysqld_multi --defaults-file=/usr/local/mysql/my.cnf stop
```

指定实例停止
```
/usr/local/mysql/bin/mysqld_multi --defaults-file=/usr/local/mysql/my.cnf stop 1
```

- 登录到各自实例
```
/usr/local/mysql/bin/mysql --socket=/tmp/mysqld_slave.sock

/usr/local/mysql/bin/mysql --socket=/tmp/mysqld_master.sock
```

- 主从配置

```
# 配置主库root和slave账号，在主库中操作
grant all  privileges on  *.* to 'root'@'%' identified by 'yourRootPassword' with grant option;
create user 'slave'
grant replication slave on *.* to 'slave'@'%' identified by 'yourSlavePassword';
flush tables with read lock;

# 查看master信息，在主库中操作，记录下对应的File和Position
show master status

# 导出主库数据，在主库中操作
/usr/local/bin/mysql/mysqldump -uroot -pyourRootPassword -R --all-databases --socket=/tmp/mysqld_master.sock > master.sql

# 解锁，在主库中操作
unlock tables

# 导入数据到从库，在从库中操作
/usr/local/mysql/bin/mysql --socket=/tmp/mysqld_slave.sock < master.sql

# 从库配置主库信息，在从库中操作，master_log_file和master_log_pos填写之前master的File和Position
change master to master_host='192.168.1.100', master_user='slave', master_password='yourSlavePassword', master_port=3306, master_log_file='mysql-bin-ptest-master.000002',master_log_pos=151;

# 查看从库状态，在从库中操作，对应的Slave_IO_Running和Slave_SQL_Running状态应为yes
show slave status

```
