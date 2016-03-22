---
title: debian/ubuntu中安装配置bind9
date: 2016-02-17 22:14:18
categories: 运维
tags: 
- BIND9 
- DNS
---

# 安装bind9
```bash
sudo apt-get install bind9 -y
```
安装后修改配置文件，若需要修改本地DNS，可修改/etc/resolve.conf

# 配置文件说明
安装后配置文件默认在/etc/bind/目录下

- named.conf 
```
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
```
 设置一般的named参数，指向该服务器使用的域数据库的信息源，配置语句：
命令|用法
----|----
acl | 定义IP地址的访问控制清单
control | 定义ndc使用的控制通道
include | 把其他文件包含到配置文件中
key | 定义授权的安全密钥 
logging | 定义日志写什么，写到哪
options | 定义全局配置选项和缺省值
server | 定义远程服务器的特征
trunsted-keys | 为服务器定义DNSSEC加密密钥
zone | 定义一个区

- named.conf.options
全局选项

- named.conf.default-zones
```
// prime the server with knowledge of the root servers
zone "." {
    type hint;
    file "/etc/bind/db.root";
};

// be authoritative for the localhost forward and reverse zones, and for 
// broadcast zones as per RFC 1912

zone "localhost" {    //提供localhost正向地址解析
    type master;    //定义此区为主服务器；若为slave则是辅助域名服务器；若为hint则为互联网中根域名服务器
    file "/etc/bind/db.local";    //指定区资源文件的位置
};

zone "127.in-addr.arpa" {
    type master;
    file "/etc/bind/db.127";
};

zone "0.in-addr.arpa" {
    type master;
    file "/etc/bind/db.0";
};

zone "255.in-addr.arpa" {
    type master;
    file "/etc/bind/db.255";
};
```
- db.root
根服务器指向文件， 由Internet NIC创建和维护， 无需修改， 但是需要定期更新
- db.local
localhost正向区文件，用于将名字localhost转换为本地回送IP地址 (127.0.0.1)
- db.127
localhost反向区文件，用于将本地回送IP地址(127.0.0.1)转换为名字localhost

# 添加区和资源文件
编辑named.conf添加一下内容
```
zone "test.com" in { //提供test.com域的地址接卸
    type master;
    file "/etc/bind/db.test.com";
};

zone "1.168.192.in-addr.arpa" { //提供192.168.1.x地址段的反向映射功能
    type master;
    file "/etc/bind/db.192";
};
```

创建区资源文件/etc/bind/db.test.com，并添加一下内容
```
;
; BIND data file for domain test.com
;
$TTL	604800    ;TTL设定，生存时间记录字段。它以秒为单位定义该资源记录中的信息存放在高速缓存中的时间长度
$ORIGIN test.com.    ;说明下面记录出处，最后有一点
@	IN	SOA	test.com. root.test.com. ( ;SOA记录设定，特殊字符@为ORIGIN的意思，接在SOA后面的是授权主机和管理者信箱
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
       IN    NS     ns                ;NS表明负责这个域的name server 是test.com这台主机
       IN    MX     0  mail.test.com  ;MX标明发往test.com域的邮件由mail.test.com这台服务器接收
@      IN    A      192.168.1.101
ns     IN    A      192.168.1.101     ;A记录标明IP地址和域名之间的对应关系
www    IN    A	    192.168.1.101
webserver   IN    CNAME  www
```

创建区资源文件/etc/bind/db.192，并添加一下内容
```
$TTL	604800
@	IN	SOA	test.com. root.test.com. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@      IN    NS    test.com.
101    IN    PTR    www.test.com    ;PTR记录用来解析IP地址对应的域名
```

# 启动
- 带调试信息启动
```bash
/usr/sbin/named -g
```
- 后台启动
```bash
/usr/sbin/named -u bind
```

# nsloopup命令
```bash
nslookup www.test.com
nslookup 192.168.1.101
```

# rndc命令
- 查询状态
```bash
rndc status
```
- 重载配置
```bash
rndc reload
```


# 浅谈DNS负载均衡技术

负载均衡技术能够平衡服务器集群中所有的服务器和请求应用之间的通信负载，根据实时响应时间进行判断，将任务交由负载最轻的服务器来处理，以实现真正的智能通信管理和最佳的服务器群性能，从而使网站始终保持运行和保证其可访问性。

最早使用的负载均衡技术是通过DNS服务中的随机名字解析来实现的。这就是通常所说的DNS负载均衡技术。

DNS负载均衡技术的实现原理是在DNS服务器中为同一个主机名配置多个IP地址，在应答DNS查询时，DNS服务器对每个查询将以DNS文件中主机记录的IP地址按顺序返回不同的解析结果，将客户端的访问引导到不同的机器上去，使得不同的客户端访问不同的服务器，从而达到负载均衡的目的。

DNS负载均衡技术主要有以下优缺点：

主要优点：
1. 技术实现比较灵活，方便，简单易行，成本低，适用于大多数TCP/IP应用
2. 对于Web应用，不需要对代码进行任何的修改
3. Web服务器可以位于互联网的任意位置

主要缺点：
1. 不能够按照Web服务器的处理能力分配负载。DNS负载均衡采用的是简单的轮询负载算法，最慢的Web服务器将成为系统的瓶颈
2. 不支持高可靠性，没有考虑容错
3. 可能会造成额外的网络问题
4. 修改了DNS设置，还要等足够的时间（刷新时间）才能发挥作用

总结：
DNS负载均衡技术方案不应该算是真正意义上的负载均衡，不能够稳定、可靠、高效地满足企业对Web服务器的需求，也不能满足网络用户对网站访问的及时响应和可用性，所以现在很多Web站点方案中，已经很少采用这种方案了

