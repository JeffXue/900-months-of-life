---
title: pcDuino安装synergy
tags:
  - pcDuino
date: 2013-03-13 21:19
categories: 嵌入式
---

# PART 1       

入手pcDuino的第一件事就是安装synergy，synergy是用来共享键盘鼠标的，既然pcDuino就是一个miniPC 当然要接上显示器玩下咯，HDMI输出网上似乎已经有修改的方法啦，不过暂时没没有试成功(http://www.the-greathouses.net/blog/2013/03/setting-pcduino-display-resolution/comment-page-1/#comment-601),接上显示器、电源、USB键鼠，开机启动吧，pcDuino上预装的是ubuntu系统，由于对桌面没怎么研究，不知道安装的是什么桌面环境，个人觉得这个桌面环境很差，如果你以为它跟PC上的ubuntu差不多，那你就错了，不过还是有一定可玩性的。
首先需要到synergy官网上下载相关源码和windows上的客户端(http://synergy-foss.org/zh-cn/download/?list)，我下载的是1.4.10版本的windows 32位 和 源码
下载好后，使用U盘copy到pcDuino的/home/ubuntu 目录下（PS:默认用户是ubuntu、密码也为ubuntu）
解压到当前目录吧，进入到synergy-1.4.10-Source目录中，运行./configure,此时会报错没有cmake，查看configure文件

```
configure：
     cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release .
```

<!-- more -->

可知需要编译安装synergy需要使用cmake，现在去下载cmake的源码进行编译安装吧，地址：http://www.cmake.org/cmake/resources/software.html
下载的版本是：cmake-2.8.10.2.tar.gz   （我是在另外一台PC上下载再使用U盘copy过去的，如果你的pcDuino连接的是外网，直接在pcDuino上下载吧，俺只在LAN上运行pcDuino）
解压到/home/ubuntu目录下，进入cmake-2.8.10.2目录下，同样运行./configure ，make，sudo make install
安装完cmake后再次进入synergy源码目录，运行./configure ,此时会出现如下错误：

```
./configure
...
CMake Error at CMakeLists.txt:196 (message):
Missing header: X11/Xlib.hX11/XKBlib.h
-- Configuring incomplete, errors occurred!
```

由于synergy需要使用libx11-dev，而pcDuino上默认是缺少很多的库文件的工具的。
如果你的pcDuino连接上了外网可以直接使用以下命令下载安装（方便省事，依赖关系都给你解决了）：

```bash
apt-get install libx11-dev
```
        
可是我是LAN的网络，可以到http://www.debian.org/distrib/packages  上下载相应的deb包安装：libx11-6_1.5.0-1_armhf.deb （下载的是armhf架构的）
可是下载deb包安装会发现还缺少很多的依赖包，我还是一一下载了（其实下载安装还是很快的,debian的软件包网站上都是有依赖说明的）
下载的所有deb包和源码情况如下（只要你不是联网安装，这些都要的，安装过程中缺少哪些包就安装哪些吧，不过这些都是必须的）

```bash
cmake-2.8.10.2.tar.gz                     libxcb1-dev_1.8.1-2_armhf.deb   libxi6_1.6.1-1_armhf.deb            x11proto-kb-dev_1.0.6-2_all.deb
libpthread-stubs0-dev_0.3-3+b1_armhf.deb  libxcb1_1.8.1-2_armhf.deb       libxtst-dev_1.2.1-1_armhf.deb       x11proto-record-dev_1.14.2-1_all.deb
libpthread-stubs0_0.3-3+b1_armhf.deb      libxdmcp-dev_1.1.1-1_armhf.deb  libxtst6_1.2.1-1_armhf.deb          x11proto-xext-dev_7.2.1-1_all.deb
libx11-6_1.5.0-1_armhf.deb                libxdmcp6_1.1.1-1_armhf.deb     synergy-1.4.10-Source.tar.gz        xorg-sgml-doctools_1.10-1_all.deb
libx11-dev_1.5.0-1_armhf.deb              libxext-dev_1.3.1-2_armhf.deb   x11-common_7.7+2_all.deb            xtrans-dev_1.2.7-1_all.deb
libxau-dev_1.0.7-1_armhf.deb              libxext6_1.3.1-2_armhf.deb      x11proto-core-dev_7.0.23-1_all.deb
libxau6_1.0.7-1_armhf.deb                 libxi-dev_1.6.1-1_armhf.deb     x11proto-input-dev_2.2-1_all.deb
```

安装好了libX11-dev后，再运行到synergy源码目录下运行./configure ，可是还是报错，这是由于CMakeLists.txt  上配置cmake的include目录不对
需要修改成如下：

```bash
177                 set(CMAKE_INCLUDE_PATH "${CMAKE_INCLUDE_PATH}:/usr/include")
178 
179                 set(XKBlib "X11/Xlib.h;X11/XKBlib.h")
```

同时还要删除源码目录下的CMakeCache.txt  再次运行./configure 时，这个错误就没有了（实际上这个错误是有记录，可参考：http://synergy-foss.org/spit/issues/details/3365/）
但是此时出现了一个新的错误，如下：

```bash
mv CMakeCache.txt OldCache.txt
./configure
...
CMake Error at CMakeLists.txt:222 (message):
Missing library: Xtst
-- Configuring incomplete, errors occurred!
```

提示缺少Xtst library，此时继续安装 libxtst-dev_1.2.1-1_armhf.deb ，这个包以及相关的依赖包你可以在之前下载的所有包中找到（如果联网直接sudo apt-get install libxtst-dev  即可）
安装好libxtst-dev 之后同样需要删除CMakeCache.txt  ，再次在源码目录下运行./configure ，这次config正常了（同样这个错误也是有记录的：http://synergy-foss.org/spit/issues/details/3150/  ）
继续安装synergy，make之后并不需要make install ，编译好的二进制文件就在目录的bin目录下可以找到。
此时synergy已经编译好了，可以到bin目录直接运行

```bash
./synergyc --daemon --name pcduino --restart 172.19.148.42
```

--daemon指synergy在以客户端形式在后台运行，该客户端名字为pcduino，同时--restart指明synergy会自动重新连接服务端
现在已经将我的PC机的键盘鼠标共享到了pcDuino上，一套键鼠控制了两个台PC哦。
可是现在还是不行，还需要设置synergy开机启动，不然pcDuino重启后，还是需要重新插入键盘鼠标去启动synergy
另外由于我是吧pcDuino连接到了内网，而PC是一台同时连接了外网和内网的，而我的PC机IP随时需要发生变化，所以我需要synergy的启动参数是可配置的，既在开机前可以修改名称和IP
此时我在/etc/rc.local上添加如下代码：

```bash
/usr/bin/check_synergy.sh
```

pcDuino在启动的时候会运行check_synergy.sh 脚本（注意权限问题，后续脚本也需要注意）
check_synergy.sh 
```bash
#!/bin/bash
interval=3
count=40

i=0  
while [ $i -lt $count ]; do
        if [ -f /media/E9FE-18F0/synergy.sh ]; then
                bash /media/E9FE-18F0/synergy.sh
                break
        fi
        sleep $interval
        i=`expr $i + 1`
        if [ $i -gt $count ]; then
                break;
        fi 
done
```

首先检查了sd卡上的配置文件是否存在，还是sd上文件存在则运行sd卡上的synergy.sh
synergy.sh    
```bash
#!/bin/bash
echo `date` : hello synergy >> /home/ubuntu/synergy.log
if [ -f /media/E9FE-18F0/synergy ]; then
        cp /media/E9FE-18F0/synergy /etc/init.d/synergy
        chmod 777 /etc/init.d/synergy
fi
/bin/bash /etc/init.d/synergy start
```

可见检查sd卡中synergy文件是否存在，存在着copy到/etc/init.d/目录下，并修改其权限，最后运行synergy
synergy
```bash
#! bin/sh
# /etc/init.d/synergy
case "$1" in
  start)
    cd /home/ubuntu/synergy-1.4.10-Source/bin/
    su ubuntu -c './synergyc --daemon --name pcduino --restart 172.19.148.42'
    echo "Starting synergy client..."
    ;;
  stop)
    pkill synergyc
    echo "Attempting to kill synergy client"
    ;;
  *)
    echo "Usage: /etc/init.d/synergy (start/stop)"
    exit 1
    ;;
  esac
  exit 0
```

copy到/etc/init.d/上就是为了修改这个文件，我修改了sd卡上面的文件，再次启动pcDuino的时候这个文件就会被修改，启动synergy的时候参数也会修改，另外放到在/etc/init.d下是为了更方便的设置
建立好/etc/init.d/synergy后，运行  
```bash
    sudo update-rc.d synergy defaults
    sudo update-rc.d-insserv synergy
```

之后可以使用以下指令启停synergy啦
```bash
/etc/init.d/synergy start
/etc/init.d/synergy stop
service synergy start
service synergy stop
```

至此synergy在pcDuino上可配置的使用和运行了。途中还是出现其他问题，如果在rc.local上直接添加启动运行synergy的指令会无效或者有时开机启动成功有时则不行，可能更我配置有关，后续再查明原因。
另外可参看Rpi上配置synergy的一篇tutorial （http://www.rootusers.com/compiling-synergy-from-source-on-the-raspberry-pi/）

# PART 2

PART1 里面说明了如何在pcduino上安装使用synergy，并通过sd卡来修改开启启动synergy时的启动参数，以上便于没有串口或者没有在pcduino上安装ssh或者telnet的开发者使用。
PART2补充下PART1上遗留下来的问题并补充：
（1）在PART1中将synergy加入到init.d中并设置为开机启动后（update-rc.d synergy defaults 和update-rc.d-insserv synergy），从串口中可以查看到开机时有运行synergy时所打印的信息，但是开机后查看进程并没有发现进程
开机信息：
```
    [    6.585562] list-records used greatest stack depth: 5504 bytes left

    Last login: Sat Jan  2 07:39:36 CST 2010 on tty1
    Welcome to Linaro 12.07 (GNU/Linux 3.0.8+ armv7l)

    * Documentation:  https://wiki.linaro.org/
    INFO: Synergy 1.4.10 Client on Linux 3.0.8+ #20 PREEMPT Fri Feb 1 22:19:20 CST 2013 armv7l
    Starting synergy client...
    [   13.095493] android_usb: already disabled
```

查看进程： 
```bash
    root@ubuntu:~# ps -ef |grep sy
    root        10     2  0 07:47 ?        00:00:00 [sync_supers]
    102        172     1  0 07:47 ?        00:00:00 dbus-daemon --system --fork --activation=upstart
    syslog     196     1  0 07:47 ?        00:00:00 rsyslogd -c5
    root       813   504  0 07:51 ttyS0    00:00:00 grep --color=auto sy
```
该问题仍暂时无法定位

（2）通过SD卡修改synergy的启动参数只是其中一种方法，要是你手上拥有串口并一定需要这样做。你只需要在/etc/rc.local 中加入如下代码（我已经将文件系统挪到了SD卡，不知在nand上是否生效），并把之前的/usr/bin/check_synergy.sh 这段删除
```bash
service synergy start
```

开机信息：
```
    [    6.607514] list-records used greatest stack depth: 5504 bytes left

    Last login: Sat Jan  2 07:47:34 CST 2010 on tty1
    Welcome to Linaro 12.07 (GNU/Linux 3.0.8+ armv7l)

    * Documentation:  https://wiki.linaro.org/
    INFO: Synergy 1.4.10 Client on Linux 3.0.8+ #20 PREEMPT Fri Feb 1 22:19:20 CST 2013 armv7l
    Starting synergy client...
    root@ubuntu:~# [   13.092226] android_usb: already disabled
    2 Jan 07:57:11 ntpdate[551]: no servers can be used, exiting
    INFO: Synergy 1.4.10 Client on Linux 3.0.8+ #20 PREEMPT Fri Feb 1 22:19:20 CST 2013 armv7l
    Starting synergy client...
```
查看进程：

```bash
    root@ubuntu:~# ps -ef |grep sy
    root        10     2  0 07:56 ?        00:00:00 [sync_supers]
    102        173     1  1 07:57 ?        00:00:00 dbus-daemon --system --fork --activation=upstart
    syslog     184     1  0 07:57 ?        00:00:00 rsyslogd -c5
    ubuntu     641     1  0 07:57 ?        00:00:00 ./synergyc --daemon --name pcduino --restart 172.19.133.192
    root       772   509  0 07:58 ttyS0    00:00:00 grep --color=auto sy
```
可见synergy终于启动成功了，启动参数需要修改，只需使用串口修改/etc/init.d/synergy文件即可
