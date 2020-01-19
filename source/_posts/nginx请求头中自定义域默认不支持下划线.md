---
title: nginx请求头中自定义域默认不支持下划线
tags:
  - Nginx
date: 2016-03-29 16:50:02
categories: 运维
---
生产环境更换nginx之后，sdk发起的请求返回了一个内部定义的401错误，导致用户投诉，跟踪后发现请求中缺失了部分域内容access_token，最终发现nginx会屏蔽掉不合法的请求头，而默认情况下请求头是不支持下划线的。

可以通过使用underscores_in_headers指令开启支持下划线：
>Syntax:    underscores_in_headers on | off;
Default:    underscores_in_headers off;
Context:    http, server

同样可以使用ignore_invalid_headers指令把忽略无效的头限制关闭掉，有效的头可以有英文字母，数字，连接符，下划线（受underscores_in_headers指令控制）
>Syntax:    ignore_invalid_headers on | off;
Default:    ignore_invalid_headers on;
Context:    http, server
