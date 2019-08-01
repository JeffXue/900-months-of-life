---
title: apache使用mod_expires模块
date: 2016-03-08 18:26:56
categories: 中间件
tags: Apache
---

# mod_expires模块

mod_expires可以减少用户的重复请求，将特定的页面缓存到浏览器中，当浏览器请求特定资源时，并且该资源没有过期，将会访问浏览器缓存，不向服务器发出请求

apache默认包含了该模块，需要在httpd.conf中启用并进行配置
```bash
LoadModule expires_module modules/mod_expires.so
```

<!-- more -->

范例1：
```bash
<IfModule mod_expires.c>
    # 启用expires
    ExpiresActive On
    # 这是默认过期时间为10天后
    ExpiresDefault “access plus 10 days”
    # 按类型设置text/css过期时间为1s后
    ExpiresByType text/css “access plus 1 second“
</IfModule>
```

范例2：
```bash
<IfModule mod_expires.c>
    ExpiresActive On
    # 对不同的类型设置不同的超时时间，86400为1天，604800为7天
    ExpiresByType image/* A604800
    ExpiresByType application/x-javascript A604800
    ExpiresByType text/css A604800
    ExpiresByType text/javascript A604800
    ExpiresByType application/javascript A604800
    ExpiresByType text/plain A86400
    ExpiresByType application/x-shockwave-flash A604800
    ExpiresByType video/x-flv A604800
    ExpiresByType application/pdf A604800
</IfModule>
```

范例3：
```bash
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresDefault A0
    # 根据不同的文件后缀设置超时时间
    # 1 年
    <FilesMatch “\.(flv|ico|pdf|avi|mov|ppt|doc|mp3|wmv|wav)$”>
        ExpiresDefault A9030400
    </FilesMatch>

    # 1 星期
    <FilesMatch “\.(jpg|jpeg|png|gif|swf)$”>
        ExpiresDefault A604800
    </FilesMatch>

    # 3 小时
    <FilesMatch “\.(txt|xml|js|css)$”>
        ExpiresDefault A10800″
        </FilesMatch>
</IfModule>
```


