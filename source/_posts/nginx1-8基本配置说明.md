---
title: nginx1.8基本配置说明
categories: 运维
tags:
  - Nginx
date: 2016-03-22 16:03:04
---


# nginx.conf
nginx主要的配置文件为nginx.conf，以下配置主要针对该配置文件进行说明
```bash
# 配置运行用户
#user  nobody;
# 设置启动进程数量
worker_processes  1;

# 全局错误日志及pid文件
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;

# Provides the configuration file context in which the directives that affect connection processing are specified.
events {
    # 指定使用的连接处理方式，详情见：http://nginx.org/en/docs/events.html
    # use epoll;
    # 每个进程的最大并发连接数
    worker_connections  1024;
}


http {
    # 设置mime类型
    include       mime.types;
    # 设置默认的mime类型
    default_type  application/octet-stream;
    
    # 日志格式
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    # 设置日志
    #access_log  logs/access.log  main;

    # 配置是否运行使用sendfile()
    sendfile        on;
    # Enables or disables the use of the TCP_NOPUSH socket option on FreeBSD or the TCP_CORK socket option on Linux.
    #tcp_nopush     on;

    # 设置keepalive超时时间
    #keepalive_timeout  0;
    keepalive_timeout  65;
    
    # 是否开启gzip压缩
    #gzip  on;

    # 虚拟主机配置
    server {
        # 监听端口
        listen       80;
        # 访问域名
        server_name  localhost;

        # 添加指定字符集到“Content-Type”头中
        #charset koi8-r;

        # 设置本虚拟主机日志
        #access_log  logs/host.access.log  main;

        # 默认请求处理
        location / {
            # 主目录
            root   html;
            # 主页类型
            index  index.html index.htm;
        }
        
        # 定制404页面
        #error_page  404              /404.html;

        # 重定向50x错误到定制页面
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # 转发php脚本到apache进行解析
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # 转发php脚本到fastcgi服务进行解析
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # 禁止访问.htaccess
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # 另一个虚拟主机配置，设置混合的IP，名称和端口
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

    # HTTPS 服务
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}


```
