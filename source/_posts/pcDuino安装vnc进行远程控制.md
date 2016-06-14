---
title: pcDuino安装vnc进行远程控制
tags:
  - pcDuino
  - vnc
date: 2013-08-05 15:39
categories: 嵌入式
---

可选用显示器或者用ssh连接
1、安装x11vnc 
输入下面的命令：
```bash
sudo apt-get install vino vinagre x11vnc
```

2、设置远程桌面登录时使用的密码，设置完后直接回车确认保存密码到     ~/.vnc/passwd  文件里，“~/  ”是你当前用户的根目录如： /home/你的用户名/
输入下面的命令：
```bash
sudo x11vnc -storepasswd
```

3、设置x11vnc通用的密码存储位置
输入下面的命令：
```bash
sudo x11vnc -storepasswd in /etc/x11vnc.pass
```

4、将用户目录下的passwd文件内容copy到 /etc/x11vnc.pass下
输入下面的命令：
```bash
sudo cp .vnc/passwd/etc/x11vnc.pass
```

5、配置x11vnc为跟随系统自动启动需要新建一个文件  /etc/init/x11vnc.conf
输入下面的命令：
```bash
sudo leafpad /etc/init/x11vnc.conf
```

按 i 键进入编辑模式，粘贴以下内容，并保存退出：
```bash
start on login-session-start

script
x11vnc -display :0-auth/var/run/lightdm/root/:0-forever-bg-o /var/log/x11vnc.log-rfbauth/etc/x11vnc.pass-rfbport5900
end script
```

其中，5900是端口号，可以自己定义。

6、重启ubuntu   等重启好了以后，到windows 下 打开 vncviewer ，输入ubuntu IP的地址和5900端口号，如 ： 192.168.1.130:5900

然后连接，如果成功的话，会出现输入密码的对话框，只需要输入上面设置好的密码就可以看到操作远程桌面啦！


7、汉化后无法连接vnc,需要将启动x的权限重新设置
```bash
sudo dpkg-reconfigure x11-common
```
