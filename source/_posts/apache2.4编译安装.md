---
title: apache2.4编译安装
date: 2016-03-07 16:09:27
categories: 运维
tags: apache
---

# 概述

The Apache HTTP Server Project is an effort to develop and maintain an open-source HTTP server for modern operating systems including UNIX and Windows. The goal of this project is to provide a secure, efficient and extensible server that provides HTTP services in sync with the current HTTP standards.

编译安装httpd需要先安装以下包：
- apr (Apache portable Run-time libraries，Apache可移植运行库)的目的如其名称一样，主要为上层的应用程序提供一个可以跨越多操作系统平台使用的底层支持接口库。apr对于Tomcat最大的作用就是socket调度
- apr-util
- pcre  (Perl Compatible Regular Expressions)是一个Perl库，包括 perl 兼容的正则表达式库
- zlib  提供数据压缩用的函式库
- openssl   是一个强大的安全套接字层密码库，囊括主要的密码算法、常用的密钥和证书封装管理功能及SSL协议，并提供丰富的应用程序供测试或其它目的使用

# 安装

完整安装脚本可查看[github脚本]( https://raw.githubusercontent.com/JeffXue/common_scripts/master/install_apache2.4.sh)

## apr
```
tar xvzf apr-1.4.5.tar.gz -C /usr/local/
cd /usr/local/apr-1.4.5
./configure --prefix=/usr/local/apr
make && make install
```

## apr-util
```
tar xvzf apr-util-1.3.12.tar.gz -C /usr/local/
cd /usr/local/apr-util-1.3.12
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
make && make install
```

## pcre
```
tar xvzf pcre-8.10.tar.gz -C /usr/local/
cd /usr/local/pcre-8.10
./configure --prefix=/usr/local/pcre
make && make install
```

## zlib
```
tar xvzf zlib-1.2.7.tar.gz -C /usr/local/
cd /usr/local/zlib-1.2.7
./configure --prefix=/usr/local/zlib
make && make install
```

## openssl
```
tar xvzf openssl-1.0.1p.tar.gz -C /usr/local/
cd /usr/local/openssl-1.0.1p
./config --prefix=/usr/local/openssl  -fPIC no-gost
make depend
make && make install
```

## httpd
```
tar xvzf httpd-2.4.3.tar.gz -C /usr/local/
cd /usr/local/httpd-2.4.3
./configure --prefix=/usr/local/apache  --enable-mods-shared=all --enable-ssl --enable-proxy-http --enable-expires --enable-deflate --enable-dav --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --with-z=/usr/local/zlib --with-pcre=/usr/local/pcre --with-ssl=/usr/local/openssl --with-mpm=event
make && make install
```

# 基本操作
版本查看
```
/usr/local/apache/bin/apachectl -V
```

启动
```
/usr/local/apache/bin/apachectl start
```

停止
```
/usr/local/apache/bin/apachectl stop
```

重启
```
/usr/local/apache/bin/apachectl restart
``` 
