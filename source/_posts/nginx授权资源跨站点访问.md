---
title: nginx授权资源跨站点访问
tags:
  - Nginx
date: 2016-03-22 17:19:26
categories: 运维
---

Access-Control-Allow-Origin 是html5 添加的新功能。基本上, 这是一个http的header, 用在返回资源的时候, 指定这个资源可以被哪些网域跨站访问。

比方说, 你的图片都放在 res.byneil.com 这个域下, 如果在返回的头中没有设置Access-Control-Allow-Origin , 那么别的域是不能外链你的图片的。当然这要取决于浏览器的实现是否遵守规范。所以导致一些网站资源加载不进来.

解决方法就是 在资源的头中 加入 Access-Control-Allow-Origin 指定你授权的域. 这里指定星号 * , 任何域都可以访问我的资源.
```bash
Access-Control-Allow-Origin: *
```

<!-- more -->

具体操作方法, 就是在nginx的conf文件中加入以下内容：
```bash
location / {
    add_header Access-Control-Allow-Origin *;
    ......
}
```

只授权指定后缀的资源，可以这样配置：
```bash
location ~* \.(eot|ttf|woff|woff2|json)$ {
    add_header  Access-Control-Allow-Origin *;
    ......
}

```

ps：在apache中可使用.htaccess在特定的目录中来进行配置

