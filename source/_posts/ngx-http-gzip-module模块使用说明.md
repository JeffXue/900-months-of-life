---
title: ngx_http_gzip_module模块使用说明
tags:
  - Nginx
date: 2016-03-22 17:44:56
categories: 运维
---


ngx_http_gzip_module是一个使用gzip方法压缩响应内容的过滤器。这会减少一一半以上的传输内容

```
    # 开启gzip
    gzip                on;
    # 设置用于压缩的buffer数量和大小
    gzip_buffers        4 16k;
    # 设置进行压缩的请求协议
    gzip_http_version   1.1;
    # 设置压缩比率 1~9,1为最小化压缩（处理速度快），9为最大化压缩（处理速度慢）
    gzip_comp_level     6;
    # 设置需要压缩的MIME类型，text/html总是会被压缩
    gzip_types          text/plain text/php text/xml text/css text/javascript application/javascript application/xhtml+xml application/xml application/rss+xml application/atom_xml application/x-javascript application/x-httpd-php image/svg+xml;
    # 指定不需要gzip压缩的浏览器
    gzip_disable        "msie6"
    # 启用应答头Vary:Accept-Encoding
    gzip_vary           on;
```

