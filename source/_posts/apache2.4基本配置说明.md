---
title: apache2.4基本配置说明
date: 2016-03-08 15:15:31
categories: 运维
tags: apache
---

# httpd.conf

```
# httpd HOME目录
ServerRoot "/usr/local/apache"
# server name
ServerName localhost

# 监听端口
Listen 80

# 默认启用的模块，注释的为较为重要的一些模块，后续会需要使用时开启
# 详细模块说明：https://httpd.apache.org/docs/2.4/mod/
LoadModule authn_file_module modules/mod_authn_file.so
LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule authz_groupfile_module modules/mod_authz_groupfile.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule access_compat_module modules/mod_access_compat.so
LoadModule auth_basic_module modules/mod_auth_basic.so
# cache模块
#LoadModule cache_module modules/mod_cache.so
#LoadModule cache_disk_module modules/mod_cache_disk.so
#LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
#LoadModule socache_dbm_module modules/mod_socache_dbm.so
#LoadModule socache_memcache_module modules/mod_socache_memcache.so
LoadModule reqtimeout_module modules/mod_reqtimeout.so
LoadModule filter_module modules/mod_filter.so
# 压缩模块
#LoadModule deflate_module modules/mod_deflate.so
LoadModule mime_module modules/mod_mime.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule env_module modules/mod_env.so
# expires模块
#LoadModule expires_module modules/mod_expires.so
LoadModule headers_module modules/mod_headers.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule version_module modules/mod_version.so
#LoadModule remoteip_module modules/mod_remoteip.so
# proxy模块
#LoadModule proxy_module modules/mod_proxy.so
#LoadModule proxy_connect_module modules/mod_proxy_connect.so
#LoadModule proxy_ftp_module modules/mod_proxy_ftp.so
#LoadModule proxy_http_module modules/mod_proxy_http.so
#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
#LoadModule proxy_scgi_module modules/mod_proxy_scgi.so
#LoadModule proxy_fdpass_module modules/mod_proxy_fdpass.so
#LoadModule proxy_ajp_module modules/mod_proxy_ajp.so
#LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
#LoadModule proxy_express_module modules/mod_proxy_express.so
# ssl模块
#LoadModule slotmem_shm_module modules/mod_slotmem_shm.so
#LoadModule slotmem_plain_module modules/mod_slotmem_plain.so
#LoadModule ssl_module modules/mod_ssl.so
# 负载均衡策略模块
#LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so
#LoadModule lbmethod_bytraffic_module modules/mod_lbmethod_bytraffic.so
#LoadModule lbmethod_bybusyness_module modules/mod_lbmethod_bybusyness.so
#LoadModule lbmethod_heartbeat_module modules/mod_lbmethod_heartbeat.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule status_module modules/mod_status.so
LoadModule autoindex_module modules/mod_autoindex.so
# info模块
#LoadModule info_module modules/mod_info.so
LoadModule dir_module modules/mod_dir.so
LoadModule alias_module modules/mod_alias.so
# rewrite模块
#LoadModule rewrite_module modules/mod_rewrite.so
# 支持PHP，需要手工编译安装PHP时指定apxs来生成改so
#LoadModule php5_module        modules/libphp5.so
# 指定libz.so
#LoadFile /usr/local/zlib/lib/libz.so

# 设置用户及用户组
<IfModule unixd_module>
User daemon
Group daemon
</IfModule>

# 管理员邮箱
ServerAdmin you@example.com

# 禁止对系统文件系统进行访问
<Directory />
    AllowOverride none
    Require all denied
</Directory>

# 主站点的路径
DocumentRoot "/usr/local/apache/htdocs"

# 主站点的访问控制
<Directory "/usr/local/apache/htdocs">
    # Options 配置在特定目录使用哪些特性，详情可看https://httpd.apache.org/docs/2.4/mod/core.html#options
    # indexes 为允许目录浏览，应移除掉
    # FollowSymLinks 允许文件系统使用符号连接
    Options Indexes FollowSymLinks

    # 定义对于每个目录下的 .htaccess 文件中的指含类型，根据实际情况进行开启或者禁用
    AllowOverride None

    # 允许所有请求
    Require all granted
</Directory>

<IfModule dir_module>
    # 设置主页
    DirectoryIndex index.html
</IfModule>

# 禁止直接访问.htaccess
<Files ".ht*">
    Require all denied
</Files>

# 错误日志
ErrorLog "logs/error_log"

# 日志级别
LogLevel warn

<IfModule log_config_module>
    # 日志格式，详细说明见http://httpd.apache.org/docs/current/mod/mod_log_config.html
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    # 日志，应使用rotatelogs进行日志切割
    CustomLog "logs/access_log" common
</IfModule>

<IfModule alias_module>
    # 设置cgi脚本目录
    ScriptAlias /cgi-bin/ "/usr/local/apache/cgi-bin/"
</IfModule>

<IfModule cgid_module>
</IfModule>

# cgi访问控制
<Directory "/usr/local/apache/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    # 设置mime（Content-Type头，它将告诉浏览器如何呈现内容）
    TypesConfig conf/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz

    # 支持shtml
    # Filters allow you to process content before it is sent to the client
    # To parse .shtml files for server-side includes (SSI):
    # (You will also need to add "Includes" to the "Options" directive.)
    #AddType text/html .shtml
    #AddOutputFilter INCLUDES .shtml
</IfModule>

# 定制Error Page
#ErrorDocument 500 "The server made a boo boo."
#ErrorDocument 404 /missing.html
#ErrorDocument 402 http://www.example.com/subscription_info.html

# MPM配置
#Include conf/extra/httpd-mpm.conf

# 状态配置
#Include conf/extra/httpd-info.conf

# 虚拟主机配置
#Include conf/extra/httpd-vhosts.conf

# Configure mod_proxy_html to understand HTML4/XHTML1
<IfModule proxy_html_module>
Include conf/extra/proxy-html.conf
</IfModule>

# SSL配置
#Include conf/extra/httpd-ssl.conf
# Note: The following must must be present to support
<IfModule ssl_module>
SSLRandomSeed startup builtin
SSLRandomSeed connect builtin
</IfModule>

# Deal with user agents that deliberately violate open standards
<IfModule setenvif_module>
BrowserMatch "MSIE 10.0;" bad_DNT
</IfModule>
<IfModule headers_module>
RequestHeader unset DNT env=bad_DNT
</IfModule>
```

# extra/httpd-vhosts.conf

若需要使用代理，需要在httpd.conf中开启代理模块
```
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_connect_module modules/mod_proxy_connect.so
LoadModule proxy_ftp_module modules/mod_proxy_ftp.so
LoadModule proxy_http_module modules/mod_proxy_http.so
```

httpd-vhosts.conf
```
<VirtualHost *:80>
    # 该虚拟主机的管理员
    ServerAdmin webmaster@dummy-host.example.com
    # 站点的主目录
    DocumentRoot "/usr/local/apache/docs/dummy-host.example.com"
    # 站点的域名
    ServerName dummy-host.example.com
    # 站点的别名
    ServerAlias www.dummy-host.example.com
    ErrorLog "logs/dummy-host.example.com-error_log"
    CustomLog "logs/dummy-host.example.com-access_log" common
    
    # 关闭正向代理
    ProxyRequests Off
    # 设置代理允许所有请求
    <Proxy *>
        Order deny,allow
        Allow from all
    </Proxy>
    # 设置反向代理
    ProxyPass / http://127.0.0.1:8080/
    # 当请求中包含重定向的情况下，会修改重定向目标URL
    ProxyPassReverse / http://127.0.0.1:8080/
</VirtualHost>

<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host2.example.com
    DocumentRoot "/usr/local/apache/docs/dummy-host2.example.com"
    ServerName dummy-host2.example.com
    ErrorLog "logs/dummy-host2.example.com-error_log"
    CustomLog "logs/dummy-host2.example.com-access_log" common
</VirtualHost>
```

# extra/httpd-ssl.conf

若需要启动ssl，需要修改httpd.conf配置
```
LoadModule slotmem_shm_module modules/mod_slotmem_shm.so
LoadModule slotmem_plain_module modules/mod_slotmem_plain.so
LoadModule ssl_module modules/mod_ssl.so

Include conf/extra/httpd-ssl.conf
```

httpd-ssl.conf
```
# 监听端口
Listen 443

# 允许客户端使用哪些加密算法套件
SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5

# Apache在启动时获取用于解密私钥文件密语的方式
SSLPassPhraseDialog  builtin

# 指定SSL会话缓存的类型
SSLSessionCache        "shmcb:/usr/local/apache/logs/ssl_scache(512000)"

# 指定SSL会话缓存的有效期
SSLSessionCacheTimeout  300

<VirtualHost _default_:443>
# 主目录
DocumentRoot "/usr/local/apache/htdocs"
# 域名
ServerName www.example.com:443
# 管理员邮箱
ServerAdmin you@example.com
# 错误日志
ErrorLog "/usr/local/apache/logs/error_log"
# 转存日志
TransferLog "/usr/local/apache/logs/access_log"

# 开启SSL
SSLEngine on
# 服务器证书 （相关说明请查看https://httpd.apache.org/docs/2.4/mod/mod_ssl.html）
SSLCertificateFile "/usr/local/apache/conf/server.crt"
# 服务器私钥
SSLCertificateKeyFile "/usr/local/apache/conf/server.key"
# 服务器CA证书
SSLCertificateChainFile "/usr/local/apache/conf/server_ca.crt"

# 添加mime类型
#AddType application/x-x509-ca-cert .crt
#AddType application/x-pkcs7-crl    .crl

# Set various options for the SSL engine
<FilesMatch "\.(cgi|shtml|phtml|php)$">
    SSLOptions +StdEnvVars
</FilesMatch>
<Directory "/usr/local/apache/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>

# SSL Protocol Adjustments
BrowserMatch "MSIE [2-5]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0

# 日志
CustomLog "/usr/local/apache/logs/ssl_request_log" \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"

# 代理设置
ProxyRequests Off
<Proxy *>
    Order deny,allow
    Allow from all
</Proxy>
ProxyPass / http://127.0.0.1:8080/
ProxyPassReverse / http://127.0.0.1:8080/

</VirtualHost>
```

# extra/httpd-mpm.conf
详细可参考：[apache的MPMs详解](http://www.jeffxue.cn/2016/03/10/apache%E7%9A%84MPMs%E8%AF%A6%E8%A7%A3/)
```
<IfModule !mpm_netware_module>
    PidFile "logs/httpd.pid"
</IfModule>

# perfork 模式配置
<IfModule mpm_prefork_module>
    # 启动进程数量
    StartServers             5
    # 最小空闲进程数量
    MinSpareServers          5
    # 最大空闲进程数量
    MaxSpareServers         10
    # 最大进程数量
    MaxRequestWorkers      250
    # 每个进程处理的最大请求数，0为无限制
    MaxConnectionsPerChild   0
</IfModule>

# worker 模式配置
<IfModule mpm_worker_module>
    # 启动进程数量
    StartServers             3
    # 最小空闲线程数量
    MinSpareThreads         75
    # 最大空闲线程数量
    MaxSpareThreads        250
    # 每个进程的线程数量 
    ThreadsPerChild         25
    # 最大线程数量
    MaxRequestWorkers      400
    # 每个进程处理的最大请求数，0为无限制
    MaxConnectionsPerChild   0
</IfModule>

# event 模式配置
<IfModule mpm_event_module>
    # 启动进程数量
    StartServers             3
    # 最小空闲线程数量
    MinSpareThreads         75
    # 最大空闲线程数量
    MaxSpareThreads        250
    # 每个进程的线程数量 
    ThreadsPerChild         25
    # 最大线程数量
    MaxRequestWorkers      400
    # 每个进程处理的最大请求数，0为无限制
    MaxConnectionsPerChild   0
</IfModule>

<IfModule mpm_netware_module>
    ThreadStackSize      65536
    StartThreads           250
    MinSpareThreads         25
    MaxSpareThreads        250
    MaxThreads            1000
    MaxConnectionsPerChild   0
</IfModule>

<IfModule mpm_mpmt_os2_module>
    StartServers             2
    MinSpareThreads          5
    MaxSpareThreads         10
    MaxConnectionsPerChild   0
</IfModule>

<IfModule mpm_winnt_module>
    ThreadsPerChild        150
    MaxConnectionsPerChild   0
</IfModule>

<IfModule !mpm_netware_module>
    MaxMemFree            2048
</IfModule>
<IfModule mpm_netware_module>
    MaxMemFree             100
</IfModule>

```

# extra/httpd-info.conf

需要在httpd.conf启动info模块才能查看info信息
```
LoadModule info_module modules/mod_info.so
```

httpd-info.conf
```
<Location /server-status>
    SetHandler server-status
    # 允许访问的host
    Require host.example.com
    # 允许访问的IP
    Require ip 127
</Location>

# 开启额外状态
# 开启后对性能会有所影响
# 每个请求均会调度两次gettimeofday(2)/times(2)和多次额外的time(2)
# 上述调度为了在status report中包含了消耗时间
# 为了得到更高的性能，应设置为off
#ExtendedStatus On

<Location /server-info>
    SetHandler server-info
    Require host.example.com
    Require ip 127
</Location>
```

