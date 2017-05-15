---
title: 搭建 WebPageTest Private Instance
tags:
  - WebPageTest
date: 2017-05-15 22:22:31
categories: 前端性能
---


# WebPageTest

WebPageTest是google的一个开源项目“make the web faster”的子项目，后来在2008年基于BSD开源
详情可见：[官方文档](https://sites.google.com/a/webpagetest.org/docs/)

WebPageTest服务端基于PHP，而客户端会有不同的形式，可以部署在window/linux以及手机上，以下主要针对说明window上的agent。
后续将web server部署在debian上，agent部署在window上

<!-- more -->

# Web Server

## 安装配置webpagetest

- 下载[webpagetest_3.0.zip](https://github.com/WPO-Foundation/webpagetest/releases)，解压后，将www目录拷贝到/usr/local/apps/webpagetest/目录下
- 修改目录权限

```
cd /usr/local/apps/webpagetest/www/
mkdir temp results
chmod -R  777  work temp results logs dat
```

- 修改location.ini

```
[locations]
1=Office
default=Office

; These are the top-level locations that are listed in the location dropdown
; Each one points to one or more browser configurations

[Office]
1=Office_wptdriver
label="Office LAN (Chrome,Firefox,IE)"

; These are the browser-specific configurations that match the configurations
; defined in the top-level locations.  Each one of these MUST match the location
; name configured on the test agent (urlblast.ini or wptdriver.ini)

[Office_wptdriver]
browser=Chrome,Firefox,IE
label="Office LAN"
```
- 配置connectivity,settings
具体可根据settings里面的说明项进行配置

```
cp connectivity.ini.sample connectivity.ini
cp settings.ini.sample settings.ini
```

## Nginx
安装nginx，具体可见[nginx安装脚本](https://raw.githubusercontent.com/JeffXue/common-scripts/master/install_nginx1.8.sh)

配置nginx.conf：

```
    server {
        server_name webpagetest.jeffxue.com;
        root    /usr/local/apps/webpagetest/www;
        include /usr/local/apps/webpagetest/www/nginx.conf;
        location ~ \.php$ {
            include        fastcgi.conf;
            fastcgi_pass   127.0.0.1:9000;
        }
    }
```

启动nginx：`/usr/local/nginx/sbin/nginx`

## PHP
安装php，具体可见[php安装脚本](https://raw.githubusercontent.com/JeffXue/common-scripts/master/install_php5.6.sh)

配置php.ini（修改以下配置）

```
memory_limit = 256M
display_errors = On
error_log = /usr/local/php/php_errors.log
post_max_size = 10M
upload_max_filesize = 10M
```

启动php-fpm：`/usr/local/php/sbin/php-fpm`

## 检查依赖
访问`http://webpagetest.jeffxue.com/install/`（需先使用ihosts修改本地host，将域名指向对应的服务器）
检查对应的依赖是否为`yes`即可，若为`no`，则安装具体的依赖即可

ffmpeg(--enable-libx264)可通过源码进行编译安装：
- yasm

```
git clone git://github.com/yasm/yasm.git
cd yasm
./autogen.sh
./configure
make
make install
```

- libx264

```
git clone git://git.videolan.org/x264.git
cd x264
./configure --enable-static --enable-shared
make
make install
ldconfig
```

- ffmpeg

```
tar xvzf FFmpeg-n3.3.tar.gz
cd FFmpeg-n3.3
./configure --enable-gpl --enable-libx264
make && make install
```

# Agent

以下操作均在window 7中执行

- 下载[webpagetest_3.0.zip](https://github.com/WPO-Foundation/webpagetest/releases)，解压后，将agent目录拷贝到window中
- 配置默认使用administrator登录
- 安装chrome、firefox、IE11
- 设置不休眠
- 关闭防火墙
- 关闭UAC
- 设置稳定时钟，cmd中运行`bcdedit /set {default} useplatformclock true`
- 安装python2.7
    - 安装selenium`pip install selenium`
    - 安装pyWin32（注意window操作系统是否为x64）
    - 安装[Imagemagick](https://www.imagemagick.org/script/binary-releases.php#windows)
    - 安装[Windows Performance Toolkit](https://msdn.microsoft.com/en-us/windows/hardware/commercialize/test/wpt/index?f=255&MSPPError=-2147217396)
- 单台window只支持单个版本IE，若需要测试多个IE，需要配置多台window，或使用多个虚拟机
- 设置开启启动任务，开机启动wptdriver.exe
- 配置wptdriver.ini（单独打开http://www.webpagetest.org/installers/software.dat，下载安装对应的一些依赖软件）

```
[WebPagetest]
url=http://webpagetest.jeffxue.com/
location=Office_wptdriver
browser=Chrome
Time Limit=120
;key=TestKey123
;Automatically install and update support software (Flash, Silverlight, etc)
;software=http://www.webpagetest.org/installers/software.dat

[Chrome]
exe="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
options='--load-extension="%WPTDIR%\extension" --user-data-dir="%PROFILE%" --no-proxy-server'
;installer=http://www.webpagetest.org/installers/browsers/chrome.dat

[Firefox]
exe="C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
options='-profile "%PROFILE%" -no-remote'
;installer=http://www.webpagetest.org/installers/browsers/firefox.dat
;template=firefox

[IE]
exe="C:\Program Files\Internet Explorer\iexplore.exe"

```

- 若运行测试时结果显示没有找到ipfw，则需要安装agent目录下的dummynet，在高级网络设置中安装对应的ipfw，并将对应的目录下的文件拷贝到dummynet目录下

启动agent：直接运行`wptdriver.exe`即可，显示waiting for work即正常，再次访问`http://webpagetest.jeffxue.com/install/`检查agent是否已经连上server

# 运行测试

访问webpagetest.jeffxue.com

## 指定URL

输入URL，选择浏览器，即可开始测试

## 使用script

点开高级设置，选择scirpt，输入对应的脚本，即可进行测试
具体script的语法可见：[scripting](https://sites.google.com/a/webpagetest.org/docs/using-webpagetest/scripting)

```
logData	0

navigate	https://sso.jeffxue.com

setValue	name=username test
setValue	name=password	123456
clickAndWait	id=loginBtn
clickAndWait	class=ant-modal-close-x

logData	1
setTimeout	10
navigate	https://corp.jeffxue.com/xxx/#/order/indent
```



