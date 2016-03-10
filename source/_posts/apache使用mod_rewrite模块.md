---
title: apache使用mod_rewrite模块
date: 2016-03-10 15:54:06
updated: 2016-03-10 15:54:06
categories: 运维
tags: apache
---

# mod_rewrite
mod_rewrite使用基于规则的重写引擎，基于PCRE正则表达式解析器，动态重写请求的URLs。默认的情况下，mod_write只是映射一个URL到文件系统路径。然而，它可以将一个URL重定向到另一个URL，或者调用一个内部代理。

修改httpd.conf以开启mod_rewrite模块，并在对应的目录中进行配置，详细可看[官方文档](http://httpd.apache.org/docs/current/mod/mod_rewrite.html)

```
LoadModule rewrite_module modules/mod_rewrite.so

<Directory "/usr/local/apache/htdocs">
    # 要支持每个目录的rewrites，需要支持FollowSymLinks
    Options Indexes FollowSymLinks
    # 开启动态重写
    RewriteEngine On
    # 可以在.htaccess中为每个目录设置rewrite规则，需将AllowOverride配置为All
    AllowOverride All
    Require all granted
</Directory>
```

# 例子
将一个域名下的访问永久重定向（301）到另外一个域名下,在网站域名迁移时会使用上
```
<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host.example.com
    ServerName www.oldDomain.cn
    Options +FollowSymLinks
    RewriteEngine on
    RewriteRule ^(.*)$ http://www.newDomain.com$1 [R=301,L]
</VirtualHost>
```
