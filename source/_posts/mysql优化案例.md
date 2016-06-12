---
title: mysql优化案例
tags:
  - mysql
date: 2016-06-12 09:28:27
categories: 性能优化
---
# 索引
## 无索引案例
问题描述：用户系统打开缓慢，数据库 CPU 100%
问题排查：发现数据库中大量的慢sql， 执行时间超过了2s
慢SQL：SELECT uid FROM user WHERE mo=13772556391 LIMIT 0,1;
执行计划
```
mysql > explain SELECT uid FROM user WHERE mo=13772556391 LIMIT 0,1
************************** 1. row *********************************
id: 1
select_type: SIMPLE
table: user
type: ALL
possible_keys: NULL
key: NULL
key_len: NULL
ref: NULL
rows: 70725
Extra: Using where
```

表结构：
```
CREATE TABLE `user`(
    `uid` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `pid` int(11) unsigned NOT NULL DEFALUT '0',
    `email` char(60) NOT NULL,
    `name` char(32) NOT NULL DEFALUT '',
    `mo` char(11) NOT NULL DEFALUT '',
    PRIMARY KEY(`uid`),
    UNIQUE KEY `email`(`email`),
    KEY `pid` (`pid`)
)ENGINE=InnoDB AUTO_INCREMENT=97260 DEFALUT CHARSET=utf-8;

```

优化方案：
添加索引
```
mysql> alter table user add index ind_mo(mo);
```

执行时间：
```
mysql> SELECT uid FROM user WHERE mo=13772556391 LIMIT 0,1;
Empty set(0.05 sec)
```

执行计划：
```
mysql > explain SELECT uid FROM user WHERE mo=13772556391 LIMIT 0,1
************************** 1. row *********************************
id: 1
select_type: SIMPLE
table: user
type: index
possible_keys: ind_mo
key: ind_mo
key_len: 33
ref: NULL
rows: 70725
Extra: Using where; Using index
```

## 隐式转换案例
**为什么索引的过滤性这么差**
```
mysql> explain extended SELECT uid FROM user WHERE mo=13772556391 LIMIT 0,1
mysql> show warnings;
Warning1: cannot use index 'ind_mo' due to type or collation conversion on field 'mo'
```

优化方案：
调整sql mo字段类型
```
SELECT uid FROM user WHERE mo=‘13772556391’ LIMIT 0,1
```

执行时间：
```
myql> SELECT uid FROM user WHERE mo=‘13772556391’ LIMIT 0,1;
Empty set(0.00 sec)
```

执行计划：
```
mysql > explain SELECT uid FROM user WHERE mo=‘13772556391’ LIMIT 0,1
************************** 1. row *********************************
id: 1
select_type: SIMPLE
table: user
type: ref
possible_keys: ind_mo
key: ind_mo
key_len: 33
ref: NULL
rows:1
Extra: Using where; Using index
```

## 索引最佳事件
- 通过explain查看sql执行计划：判断是否使用了索引以及隐式转换
- 常见的隐式转换：包括字段数据类型以及字符集定义不当导致
- 设计开发阶段：避免数据库字段定义与应用程序参数定义出现不一致，不支持函数索引，避免在查询条件加入函数date(a.gmt_create)
- SQL审核：所有上线的sql都要经过严格的审核，创建合适的索引


# SQL优化

## 分页优化案例
普通写法：
```
select * from buyer where sellerid=100 limit 100000,20 
```
普通limit M, N 的翻页写法，在越往后翻页的过程中速度越慢，原因mysql会读取表中前M+N条数据，M越大，性能就越差

优化写法：
```
select t1.* from buyer t1, (select id from buyer where sellerid=100 limit 100000,20 ) t2 where t1.id=t2.id
```
需要在t表中的sellerid字段中创建索引，id为表的主键

## 子查询优化
典型子查询：
```
SELECT first_name FROM employees WHERE emp_no IN (SELECT emp_no FROM salaries_2000 WHERE salary=5000);
```
mysql的处理逻辑是遍历employees表中的每一条就，代入子查询中去

改成子查询：
```
SELECT first_name FROM employees emp, (SELECT emp_no FROM salaries_2000 WHERE salary=5000) sal WHERE emp.emp_no = sal.emp_mo
```

## SQL优化最佳实践
- 分页优化：采用高效的limit写法，避免分页查询给数据库带来的性能影响
- 子查询优化：子查询在5.1，5.5版本中存在较大风险，将子查询改为关联，使用mysql5.6版本，可以避免麻烦的子查询改写

# 锁

## 表级锁

Innodb与Myisam
引擎     | 支持事务 | 并发             | 索引损坏 | 锁级别 | 在线备份
-          | -            | -                  | -            | -         | - 
Myisam | 不支持    | 查询堵塞更新 | 索引损坏 | 表       | 不支持
Innodb  | 支持       | 不堵塞          | 不损坏    | 行       | 支持

myisam 查询会堵塞数据更新操作，同时在DDL过程中注意数据库中大长事务，大查询

## 锁问题最佳实践
- 设计开发阶段
    - 避免使用myisam存储引擎，改用innodb引擎
    - 避免大事务，长事务导致事务在数据库中运行时间加长
    - 选择升级到mysql5.6版本，支持online ddl

- 管理运维阶段
    - 在业务低峰期执行上述操作，比如创建索引，添加字段
    - 在结构变更前，观察数据库中是否存在长SQL，大事务
    - 结构变更期间，监控数据库的线程状态是否存在lock wait

# 延迟

阿里云RDS：只读实例架构（数据库需要升级到5.6版本，最多支持5个节点，采用mysql复制原理实现数据同步）
- DDL导致延迟，常见DDL：create index, repair, optimze table, alter table add column
- 大事务：create ...as select , insert...select , load ...data , delete ...from, update...from
- MDL锁导致延迟：通过执行show processlist查看链接状态；锁会阻塞复制线程导致复制延迟
- 资源问题导致延迟：压力（同步压力+只读业务压力），效率（CPU+IOPS）

## 延迟问题最佳实践
- 排查思路
    - 一看资源是否达到瓶颈
    - 二看线程状态是否有锁
    - 三判断是否存在大事务
- 最佳实践
    - 使用innodb存储引擎
    - 只读实例规格不低于主实例
    - 大事务拆分为小事务
    - DDL变更期间观察是否有大查询

# 参数优化
背景介绍: 某客户正在将本地的业务系统迁移上云，在rds上运行时间明显要比线下自建数据库运行时间要慢一倍，导致客户系统割接延期风险

经验分析：
- 数据库是否跨平台迁移
- 是否跨版本升级
- 检查执行计划、优化器、参数配置，硬件配置

确定参数配置：
用户配置：
join_buffer_size = 128m
read_rnd_buffer_size =128m
tmp_table_size = 128m

RDS配置：
join_buffer_size = 1m
read_rnd_buffer_size =1m
tmp_table_size = 256k

验证阶段：将tmp_table_size调整为128M

## 参数最佳实践
- 排查思路
    - 查看sql执行计划
    - 查看数据库版本和优化器规则
    - 对比参数设置
    - 对比硬件配置
- 最佳实践
    - query_cache_size
    - tmp_table_size
    - tokudb_buffer_pool_ratio
    - back_log

# cpu 100%
三大因素： 慢sql，锁，资源

- 慢sql问题: 通过优化索引，子查询，隐式转换，分页改写等优化
- 锁等待问题: 通过设计开发和管理运维优化锁等待
- 资源问题： 通过参数优化，弹性升级，读写分离，数据库拆分等

# conn 100%

- 慢sql问题: 通过优化索引，子查询，隐式转换，分页改写等优化
- 锁等待问题: 通过设计开发和管理运维优化锁等待
- 配置问题： 客户端连接池参数配置超出实际最大连接数，弹性升级RDS的规格配置

# iops 100%

- 慢sql问题: 通过优化索引，子查询，隐式转换，分页改写等优化
- DDL: create index, optimze table, alter table add column
- 配置问题：内存规格不足，弹性升级RDS规格配置

# disk 100%
磁盘空间组成：数据文件，日志文件，临时文件

- 数据空间问题
    - 采用optimize table收缩表空间
    - 删除不必要的索引
    - 使用tokudb压缩引擎
- 日志空间问题
    - 减少大字段的使用
    - 使用truncate替代delete from
- 临时空间问题
    - 适当调大sort_buffer_size
    - 创建合适索引避免排序

# mem 100%

- buffer pool size
    - 创建合适的索引，避免大量的数据扫描
    - 去除不必要的索引，降低内存的消耗
- thread cost memory
    - 创建合适的索引避免排序
    - 只查询应用所需要的数据
- dictionary memory
    - 不要过度分表

