---
title: tomcat-native编译安装
tags:
  - tomcat native
date: 2016-04-18 20:09:03
categories: 运维
---

# Tomcat Native概述
The Apache Tomcat Native Library is an optional component for use with Apache Tomcat that allows Tomcat to use certain native resources for performance, compatibility, etc.

Specifically, the Apache Tomcat Native Library gives Tomcat access to the Apache Portable Runtime (APR) library's network connection (socket) implementation and random-number generator. See the Apache Tomcat documentation for more information on how to configure Tomcat to use the APR connector.

Features of the APR connector:
- Non-blocking I/O for Keep-Alive requests (between requests)
- Uses OpenSSL for TLS/SSL capabilities (if supported by linked APR library)
- FIPS 140-2 support for TLS/SSL (if supported by linked OpenSSL library)

可见以下[安装脚本](https://raw.githubusercontent.com/JeffXue/common_scripts/master/install_tomcat_native1.2.5.sh)

<!-- more -->

# 安装依赖

## 系统依赖
debian based linux
```bash
apt-get install libapr1-dev libssl-dev
```

rpm based linux
```bash
yum install apr-devel openssl-devel
```

## apr
```bash
tar xvzf apr-1.4.5.tar.gz -C /usr/local/
cd /usr/local/apr-1.4.5
./configure --prefix=/usr/local/apr
make && make install
```


## openssl
```bash
tar xvzf openssl-1.0.2g.tar.gz -C /usr/local/
cd /usr/local/openssl-1.0.2g
./config --prefix=/usr/local/openssl102g  -fPIC no-gost
make depend
make && make install
```


## jdk
```bash
tar xvzf jdk-7u79-linux-x64.tar.gz  -C /usr/local/
```


# 安装native
官方地址：https://tomcat.apache.org/download-native.cgi
```bash
tar xvzf tomcat-native-1.2.5-src.tar.gz -C /usr/local/
cd /usr/local/tomcat-native-1.2.5-src/native
./configure --with-apr=/usr/local/apr --with-ssl=/usr/local/openssl102g --with-java-home=/usr/local/jdk1.7.0_79 --prefix=/usr/local/apache-tomcat-7.0.68
make && make install

cp /usr/local/apache-tomcat-7.0.68/libtcnative-1.* /usr/lib/
```


