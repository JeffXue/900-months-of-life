---
title: 安装memcached可视化管理工具
tags:
  - memcached
date: 2016-04-27 17:53:19
categories: 运维
---

# MemAdmin

MemAdmin是一款可视化的Memcached管理与监控工具，基于 PHP5 & JQuery 开发，体积小，操作简单。

主要功能：
- 服务器参数监控：STATS、SETTINGS、ITEMS、SLABS、SIZES实时刷新
- 服务器性能监控：GET、DELETE、INCR、DECR、CAS等常用操作命中率实时监控
- 支持数据遍历，方便对存储内容进行监视
- 支持条件查询，筛选出满足条件的KEY或VALUE
- 数组、JSON等序列化字符反序列显示
- 兼容memcache协议的其他服务，如Tokyo Tyrant (遍历功能除外)
- 支持服务器连接池，多服务器管理切换方便简洁

<!-- more -->

# 安装php
详细请看[安装脚本](https://raw.githubusercontent.com/JeffXue/common_scripts/master/install_php5.6.sh)

# 安装php memcahce插件
```bash
tar xvzf memcache-2.2.7.tgz
cd memcache-2.2.7
/usr/local/php/bin/phpize
./configure --enable-memcache --with-php-config=/usr/local/php/bin/php-config --with-zlib-dir=/usr/local/zlib
make && make install
mkdir /usr/local/php/modules
#将生成的memcache.so拷贝到/usr/local/php/modules
```

# 配置php.ini
/usr/local/php/lib/php.ini
```ini
extension_dir = "/usr/local/php/modules"
extension=memcache.so
```

# 检查配置
```bash
/usr/local/php/bin/php -c /usr/local/php/lib/php.ini -m
#检查输出中是否包含有memcache
```

# 解压MemAdmin
```bash
tar xvzf memadmin-1.0.12.tar.gz -C /usr/local/apps/
mv /usr/local/apps/memadmin-1.0.12 /usr/local/apps/memadmin
```

# 配置nginx
nginx.conf
```conf
    server {
        server_name memadmin.youdomain.com;
        root    /usr/local/apps/memadmin;

        location ~ \.php$ {
            include        fastcgi.conf;
            fastcgi_pass   127.0.0.1:9000;
        }
    }
```

