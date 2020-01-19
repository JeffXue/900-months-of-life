---
title: nginx_ssl配置说明
categories: 运维
tags:
  - Nginx
  - HTTPS
date: 2016-03-22 16:26:40
---


# HTTPS

本文主要针对nginx支持HTTPS配置进行说明，详情见[官方文档](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_protocols)

nginx.conf
```bash
    # 服务器证书， nginx无法设置CA证书，导致手机端无法通过ssl握手，把CA证书合并到该文件中即可
    ssl_certificate             /usr/local/nginx/conf/newssl/nginx_domain.crt;
    # 服务器秘钥
    ssl_certificate_key         /usr/local/nginx/conf/newssl/your.key;
    # 设置加密算法套件，不同的加密算法可能会导致不同的漏洞，根据https://linux.cn/article-5374-1.html  修改而来的ciphers
    ssl_ciphers                 ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4;
    # 当使用SSLv3和TLS协议时，首选服务器的加密套件
    ssl_prefer_server_ciphers   on;
    # 设置支持的协议，SSLv2 是不安全的，所以我们需要禁用它。我们也禁用 SSLv3，因为 TLS 1.0 在遭受到降级攻击时，会允许攻击者强制连接使用 SSLv3
    ssl_protocols               TLSv1 TLSv1.1 TLSv1.2;
    # 不存储session到cache
    ssl_session_cache           none;
    # 关闭session tickets
    ssl_session_tickets         off;
    # 关闭验证客户端证书
    ssl_verify_client           off;

    server {
        # 监听端口443 https协议
        listen             443 ssl;
        # 访问域名
        server_name  example.com;
        # 启用https
        ssl                on;
        # 日志文件
        access_log     log/access_ssl.log  main;
        # 默认访问
        location / {
            proxy_pass   http://127.0.0.1:8080;
        }
    }



```
