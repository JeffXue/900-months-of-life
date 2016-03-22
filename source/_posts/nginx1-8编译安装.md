---
title: nginx1.8编译安装
tags:
  - nginx
date: 2016-03-22 12:01:33
updated: 2016-03-22 15:01:33
categories: 运维
---
# 概述

nginx [engine x] 是一个HTTP反向代理服务器，一个邮件代理服务器，一个通用的TCP/UDP代理服务器
[官方文档](http://nginx.org/en/docs/)

# 编译安装
```
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_realip_module --with-pcre=/usr/local/pcre-8.10 --with-openssl=/usr/local/openssl-1.0.1p --with-zlib=/usr/local/zlib-1.2.7

make && make install
```
--with-http_ssl_module #支持ssl
--with-http_stub_status_module #支持status
--with-http_gzip_static_module #支持gzip
--with-http_realip_module #用于获取使用代理之后的真实IP，如CDN等
--with-pcre=/usr/local/pcre-8.10 #设置pcre源目录
--with-openssl=/usr/local/openssl-1.0.1p #设置openssl源目录
--with-zlib=/usr/local/zlib-1.2.7 #设置zlib源目录

# 基本操作

nginx 帮助说明
```
/usr/local/nginx/sbin/nginx -h

nginx version: nginx/1.8.1
Usage: nginx [-?hvVtq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
  -?,-h         : this help
  -v            : show version and exit
  -V            : show version and configure options then exit
  -t            : test configuration and exit
  -q            : suppress non-error messages during configuration testing
  -s signal     : send signal to a master process: stop, quit, reopen, reload
  -p prefix     : set prefix path (default: /usr/local/nginx/)
  -c filename   : set configuration file (default: conf/nginx.conf)
  -g directives : set global directives out of configuration file
```

启动
```
/usr/local/nginx/sbin/nginx
```

快速停止
```
/usr/local/nginx/sbin/nginx -s stop
```

优雅停止
```
/usr/local/nginx/sbin/nginx -s quit
```

重载
```
/usr/local/nginx/sbin/nginx -s reload
```

重新打开日志文件
```
/usr/local/nginx/sbin/nginx -s reopen
```

