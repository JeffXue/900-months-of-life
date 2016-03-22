---
title: 使用Hexo搭建个人博客
date: 2016-01-03 17:37:18
categories: 运维
tags: 
- Hexo
- Blog
---

## 部署Hexo
Hexo 是一个快速、简洁且高效的博客框架。Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。
以下说明针对debian/ubuntu环境,其他情况请参考:[hexo文档](https://hexo.io/zh-cn/docs/)
### 安装Git
``` bash
$ sudo apt-get install git
```

### 安装Node.js
下载https://raw.github.com/creationix/nvm/master/install.sh 后运行安装nvm
安装完成后，重启终端执行以下命令即可安装node.js
``` bash
$ nvm install 4
```

### 安装Hexo
``` bash
npm install -g hexo-cli
```

### 安装hexo-deployer-git
``` bash
npm install hexo-deployer-git --save
```

## 建站
``` bash
$ hexo init <folder>
$ cd <folder>
$ npm install
```

## 安装NexT主题
``` bash
$ cd your-hexo-sit
$ git clone https://github.com/iissnan/hexo-theme-next themes/next

```
NexT主题配置查看：
- [5分钟快安装](http://theme-next.iissnan.com/five-minutes-setup.html)
- [主题设定](http://theme-next.iissnan.com/theme-settings.html)
- [第三方服务](http://theme-next.iissnan.com/third-party-services.html)
- [主题配置参考](http://theme-next.iissnan.com/theme-settings-example.html)

## 配置
主要_config.yml配置

参数 | 描述
- | -
title | 网站标题
description | 网站描述
author | 你的名字
language | zh-Hans (ps: 中文)
timezone | Asia/Chongqing (时区设置)
url | 网址 (你的域名/子目录)
theme | 主题:next (使用NexT主题)
type | git 
repository | git仓库URL
branch | master

## 命令
安装之后需要把～/.nvm/versions/node/v4.2.4/bin添加到PATH中，否则后续无法调用到hexo命令
主要的命令：

- `hexo init [folder]` 新建一个网站
- `hexo new [layout] <title>` 新建一篇文章,layout：post,draft,page
- `hexo generate` 生成静态文件
- `hexo publish [layout] <filename>` 发布草稿
- `hexo server` 启动服务器
- `hexo deploy` 部署网站
- `hexo --debug` 调试模式
- `hexo --draft` 显示草稿
