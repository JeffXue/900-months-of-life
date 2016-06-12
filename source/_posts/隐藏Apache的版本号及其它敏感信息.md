---
title: 隐藏Apache的版本号及其它敏感信息
tags:
  - Apache
date: 2016-03-25 11:41:25
categories: 运维
---

- 主配置中启动httpd-default.conf
```conf
Include conf/extra/httpd-default.conf
```

- 修改httpd-default.conf
```conf
ServerTokens Prod
ServerSignature off
```
