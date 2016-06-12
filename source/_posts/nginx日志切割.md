---
title: nginx日志切割
tags:
  - Nginx
date: 2016-03-22 17:05:26
categories: 运维
---


由于nginx没有像apache一样自带日志切割工具（rotatelogs），但可以使用linux系统自带的工具logrotate，并配置定时任务即可实现定时日志切割

# logrotate日志管理工具

logrotate是一个日志文件管理工具。用来把旧文件轮转、压缩、删除，并且创建新的日志文件。我们可以根据日志文件的大小、天数等来转储，便于对日志文件管理，一般都是通过cron计划任务来完成的。

## 命令参数说明

logrotate --help
```bash
Usage: logrotate [OPTION...] <configfile>
  -d, --debug               Don't do anything, just test (implies -v)
  -f, --force               Force file rotation
  -m, --mail=command        Command to send mail (instead of `/usr/bin/mail')
  -s, --state=statefile     Path of state file
  -v, --verbose             Display messages during rotation

Help options:
  -?, --help                Show this help message
      --usage               Display brief usage message
```

## 配置日志切割策略文件

nginx-log-rotate
```bash
/log/nginx/*.log {
    nocompress
    daily
    copytruncate
    create
    notifempty
    rotate 3
    noolddir
    missingok
    dateext
}
```

## 配置选项说明
字段 | 说明
- | -
compress | 通过gzip 压缩转储旧的日志
nocompress | 不需要压缩时，用这个参数
copytruncate | 用于还在打开中的日志文件，把当前日志备份并截断
nocopytruncate | 备份日志文件但是不截断
create mode owner group | 使用指定的文件模式创建新的日志文件
nocreate | 不建立新的日志文件
delaycompress | 和 compress 一起使用时，转储的日志文件到下一次转储时才压缩
nodelaycompress | 覆盖 delaycompress 选项，转储同时压缩。
errors address | 专储时的错误信息发送到指定的Email 地址
ifempty | 即使是空文件也转储，这个是 logrotate 的缺省选项。
notifempty | 如果是空文件的话，不转储
mail address | 把转储的日志文件发送到指定的E-mail 地址
nomail | 转储时不发送日志文件
olddir directory | 转储后的日志文件放入指定的目录，必须和当前日志文件在同一个文件系统
noolddir | 转储后的日志文件和当前日志文件放在同一个目录下
prerotate/endscript | 在转储以前需要执行的命令可以放入这个对，这两个关键字必须单独成行
postrotate/endscript | 在转储以后需要执行的命令可以放入这个对，这两个关键字必须单独成行
sharedscripts | 所有的日志文件都轮转完毕后统一执行一次脚本
daily | 指定转储周期为每天
weekly | 指定转储周期为每周
monthly | 指定转储周期为每月
rotate count | 指定日志文件删除之前转储的次数，0 指没有备份，5 指保留5 个备份
size size | 当日志文件到达指定的大小时才转储，Size 可以指定 bytes (缺省)以及KB (sizek)或者MB

# 配置定时任务
配置每天23点59分运行一次
crontab -e
```bash
59 23   * * *   /usr/sbin/logrotate -f /usr/local/nginx/conf/nginx-log-rotate
```
