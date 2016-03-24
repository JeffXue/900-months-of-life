---
title: Loadrunner发送https请求报错GENERAL_MSG_CAT_SSL_ERROR
tags:
  - Loadrunner
  - HTTPS
date: 2016-03-24 10:10:36
categories: 性能测试
---

Loadrunner默认情况下使用ssl2/3，一般情况下后端反向代理会禁用SSLv2和SSLv3，因为SSLv2是不安全的，TLS 1.0在遭受到降级攻击时，会允许攻击者强制连接使用SSLv3，因此Loadrunner采用默认配置发送https的情况下会出现握手失败的情况

可以通过修改所采用的协议来解决
```
web_set_sockets_option("SSL_VERSION","TLS");
```
