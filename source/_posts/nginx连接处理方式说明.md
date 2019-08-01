---
title: nginx连接处理方式说明
tags:
  - Nginx
date: 2016-03-22 15:24:16
categories: 中间件
---

# 连接处理方式

nginx支持多种连接处理方式，具体使用哪一种由当前平台决定。如果当前平台支持多种方式，nginx会自动选择最佳的方式。然而，在有需要的情况下，可以通过use命令来指定连接处理方式。

以下为所支持的连接处理方式：
- select
> standard method. The supporting module is built automatically on platforms that lack more efficient methods. The --with-select_module and --without-select_module configuration parameters can be used to forcibly enable or disable the build of this module.

- poll
> standard method. The supporting module is built automatically on platforms that lack more efficient methods. The --with-poll_module and --without-poll_module configuration parameters can be used to forcibly enable or disable the build of this module.

- kqueue
> efficient method used on FreeBSD 4.1+, OpenBSD 2.9+, NetBSD 2.0, and Mac OS X.

- epoll
> efficient method used on Linux 2.6+.
> Some older distributions like SuSE 8.2 provide patches that add epoll support to 2.4 kernels.

- /dev/poll
> efficient method used on Solaris 7 11/99+, HP/UX 11.22+ (eventport), IRIX 6.5.15+, and Tru64 UNIX 5.1A+.

- eventport
> event ports, efficient method used on Solaris 10.
