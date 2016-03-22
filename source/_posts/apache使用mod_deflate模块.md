---
title: apache使用mod_deflate模块
date: 2016-03-08 18:27:10
categories: 运维
tags: Apache
---

# mod_deflate模块

[apache2.4编译安装](http://www.jeffxue.cn/2016/03/07/apache2.4%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85/)时加入--enable-deflate，然后在httpd.conf模块中启用该模块，并添加配置
```
LoadModule deflate_module modules/mod_deflate.so
......
<IfModule mod_deflate.c>
    # 压缩的程度，取值范围在1（最低压缩率）到9（最高压缩率）
    DeflateCompressionLevel 6

    # 添加需要压缩的MIME类型
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/php
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE text/javascript
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/atom_xml
    AddOutputFilterByType DEFLATE application/x-javascript
    AddOutputFilterByType DEFLATE application/x-httpd-php
    AddOutputFilterByType DEFLATE image/svg+xml
    AddOutputFilterByType DEFLATE image/gif image/png  image/jpe image/swf image/jpeg image/bmp

    # 使用BrwoserMatch指令针对特定的浏览器设置no-gzip标记以取消压缩
    BrowserMatch ^Mozilla/4 gzip-only-text/html
    BrowserMatch ^Mozilla/4\.0[678] no-gzip
    BrowserMatch \bMSIE !no-gzip !gzip-only-text/html

    # 不压缩以下格式后缀文件
    SetEnvIfNoCase Request_URI .(?:html|htm)$ no-gzip dont-varySetEnvIfNoCase
    SetEnvIfNoCase Request_URI .(?:gif|jpe?g|png)$ no-gzip dont-vary
    SetEnvIfNoCase Request_URI .(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
    SetEnvIfNoCase Request_URI .(?:pdf|doc)$ no-gzip dont-vary
</IfModule>
```


