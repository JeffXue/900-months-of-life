---
title: apache日志配置
date: 2016-03-08 17:20:17
categories: 运维
tags: Apache
---

# 日志格式

## 配置
修改httpd.conf中的LogFormat
```
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\" %D \"%{Host}i\" " combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
```
修改extra/httpd-ssl.conf的CustomLog
```
CustomLog "/usr/local/apache/logs/ssl_request_log" \
          "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\" %D \"%{Host}i\" %{SSL_PROTOCOL}x %{SSL_CIPHER}x 
```

## LogFormat说明
上述所用到的LogFormat格式说明，[官方说明](http://httpd.apache.org/docs/current/mod/mod_log_config.html)

Format String | 描述
- | -
%h | remote hostname, Will log the IP address if HostnameLookups is set to Off, which is the default.
%l | remote logname
%u | remote user if the request was authenticated
%t | Time the request was received in the format [18/Sep/2011:19:18:28 -0400]
%r | First line of request
%s | Status, Use %>s for the final status.
%b | Size of response in bytes,excluding HTTP headers, In CLF format, i.e. a '-' rather than a 0 when no bytes are sent.
%{VARNAME}i | The contents of VARNAME: header line(s) in the request sent to the server. 
%D | The time taken to serve the request, in microseconds.

# 切割日志

## 配置
使用apache自带的rotatelogs来进行日志切割，[官方说明](https://httpd.apache.org/docs/2.4/programs/rotatelogs.html)
修改httpd.conf
```
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\" %D \"%{Host}i\" " combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "| /usr/local/apache/bin/rotatelogs -l logs/access_%Y-%m-%d.log 86400" combined
</IfModule>
```
修改extra/httpd-ssl.conf
```
CustomLog " | /usr/local/apache/bin/rotatelogs -l /usr/local/apache/logs/access_ssl_%Y-%m-%d.log 86400" \
          "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\" %D \"%{Host}i\" %{SSL_PROTOCOL}x %{SSL_CIPHER}x 
```

## rotatelogs说明

rotatelogs [ -l ] [ -L linkname ] [ -p program ] [ -f ] [ -t ] [ -v ] [ -e ] [ -c ] [ -n number-of-files ] logfile rotationtime|filesize(B|K|M|G) [ offset ]

选项 | 描述
- | -
-l | 使用本地时间代替GMT时间作为时间基准。注意：在一个改变GMT偏移量(比如夏令时)的环境中使用-l会导致不可预料的结果。
-t | 清空目标文件，而不是进行切割
logfile | 它加上基准名就是日志文件名。如果logfile中包含”%”，则它会被视为用于strftime()的格式字符串；否则它会被自动加上以秒为单位的”.nnnnnnnnnn”后缀。这两种格式都表示新的日志开始使用的时间。
rotationtime | 日志文件滚动的以秒为单位的间隔时间。
offset | 相对于UTC的时差的分钟数。如果省略，则假定为”0″并使用UTC时间。比如，要指定UTC时差为”-5小时”的地区的当地时间，则此参数应为”-300″。
filesizeM | 指定以filesizeM文件大小滚动，而不是按照时间或时差滚动。


