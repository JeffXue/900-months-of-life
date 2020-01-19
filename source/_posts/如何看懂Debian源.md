---
title: 如何看懂Debian源
tags:
  - Debian
  - Linux
date: 2016-07-21 23:14:46
categories: 运维
---

# /etc/apt/source.list

source.list列出了所包含的源，一般情况下采用以下的格式：
```
deb http://site.example.com/debian distribution component1 component2 component3
deb-src http://site.example.com/debian distribution component1 component2 component3
```

## deb与deb-src
deb和deb-src代表了不同的源存档类型
- deb代表预编译好的二进制的包
- deb-src代表源码包

## 仓库URL
http://site.example.com/debian  代表仓库的URL，debian的仓库镜像可见[mirror list](https://www.debian.org/mirror/list)

如果你不知道使用哪个源，可以使用`http://httpredir.debian.org/debian`，会动态的重定向最合适的源地址

<!-- more -->

## Distribution

distribution 可以为release code name/别名（wheezy, jessie, stretch, sid），或者release class(oldstable, stable, testing, unstable)，详细可见[DebianReleases](https://wiki.debian.org/DebianReleases)

如果你需要使用特定的debian发型版，则使用代号。例如如果你运行debian8.5 jessie发行版，而不希望在stretch发布后升级到stretch，则应该使用jessie而不是stable作为distribution

### code name

- Wheezy: Debian 7.0的开发代号
- Jessie: Debian 8.的开发代号
- Stretch: Debian 9.的开发代号
- Sid: 严格来说并不是一个版本, 而是作为一个滚动开发的debian发行版，包含最新的包

### release class

- oldstable: 上一个稳定版仓库的代号，只提供安全更新
- stable: 正式的稳定版，一般情况下应该使用该版本
- testing: 开发测试中的版本，将会成为下一个正式的稳定版
- unstable: 严格来说并不是一个版本, 而是作为一个滚动开发的debian发行版，包含最新的包

### 关系

code name 和 release class之间是一一对应的，跟随着发行版的迭代，之间的关系会跟随变化
- oldstable 上一个稳定发行版： Wheezy
- stable 当前稳定发行版：Jessie
- testing 下一个发行版：Stretch
- unstable 不稳定开发版本：Sid

## Component

- main ： 包含符合DFSG（The Debian Free Software Guidelines）的包，且不依赖于该范畴外的包
- contrib：包含符合DFSG的包，但可能会依赖并不在main中的包（即依赖non-free）
- non-free ：包含不符合DFSG的包

## 例子

以下是一个debian 8/Jessie的sources.list
```
deb http://httpredir.debian.org/debian jessie main
deb-src http://httpredir.debian.org/debian jessie main

deb http://httpredir.debian.org/debian jessie-updates main
deb-src http://httpredir.debian.org/debian jessie-updates main

deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main
```

你同样可以包含contrib和non-free的components
```
deb http://httpredir.debian.org/debian jessie main contrib non-free
deb-src http://httpredir.debian.org/debian jessie main contrib non-free

deb http://httpredir.debian.org/debian jessie-updates main contrib non-free
deb-src http://httpredir.debian.org/debian jessie-updates main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free
```

## 安全性更新源

注意最后的`deb http://security.debian.org/ jessie/updates main`这个是为了保证你获取到最新的安全更新，安全性更新的源debian放在了单独的一个源。官方建议，所有安全性更新，只从官方主站更新，不要使用其他镜像，除非你对镜像站点十分有信心。

## 多种源

另外你会留意到`deb http://httpredir.debian.org/debian jessie-updates main`，这个又是做什么的？
解析这个之前，先从浏览器访问` http://httpredir.debian.org/debian/dists/`，下面就会有jessie，jessie-updates，jessie-proposed-updates这样的目录
- jessie 正如之前所说为jessie版本的源
- jessie-proposed-updates 包含为下一发行版本的准备中的源[StableProposedUpates](https://wiki.debian.org/StableProposedUpdates)
- jessie-updates 包含了大部分人希望在当前版本中使用到的jessie-proposed-updates中的源[StableUpdates](https://wiki.debian.org/StableUpdates)

看到这里你应该明白`deb http://httpredir.debian.org/debian jessie-updates main`的作用了，同样其他的路径对应的不同的用途，这里对不常用的并不进行探讨

另外请不要随意的更换不同目的和版本的源，混源会导致很多的依赖关系问题。


