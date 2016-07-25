---
title: debian设置程序开机启动
tags:
  - Debian
  - Linux
date: 2016-07-25 22:51:59
categories: Linux
---

# 方法一：修改rc.local
修改/etc/rc.local，在`exit 0`之前添加你需要运行的程序，需要注意以下几点：
- 使用绝对路径，如需要调用node的forever守护进程来启动,需要使用绝对路径`/usr/local/node/bin/forever start usr/local/apps/document/ROOT/app.js`，不能直接使用forever，具体原因是/etc/init.d/rc.local在调用/etc/rc.local之前修改了PATH，否则会导致你的服务无法启动
- rc.local是等待对应运行状态的/etc/init.d/服务都开启后才会执行的，因此如果服务未开启完成，rc.local是不会执行的
```bash
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
/usr/local/node/bin/forever start /usr/local/apps/document/ROOT/app.js

exit 0
```

<!-- more -->

# 方法二：添加自启动服务
在/etc/init.d下面添加脚本aria2c
```bash
#!/bin/sh
### BEGIN INIT INFO
# Provides:          Aria2
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop::    $network $local_fs $remote_fs
# Should-Start:      $all
# Should-Stop:       $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Aria2 - Download Manager
# Description:       Aria2 - Download Manager
### END INIT INFO
NAME=aria2c
USER=pi
ARIA2C=/usr/bin/$NAME
PIDFILE=/var/run/$NAME.pid
CONF=/home/$USER/.aria2/aria2.conf
ARGS="--conf-path=${CONF}"
test -f $ARIA2C || exit 0
. /lib/lsb/init-functions
case "$1" in
start)  log_daemon_msg "Starting aria2c" "aria2c"
        start-stop-daemon -S -q -b -m -p $PIDFILE -c $USER -a $ARIA2C -- $ARGS
        log_end_msg $?
        ;;
stop)   log_daemon_msg "Stopping aria2c" "aria2c"
        start-stop-daemon -K -q -p $PIDFILE
        log_end_msg $?
        ;;
restart|reload|force-reload)
        log_daemon_msg "Restarting aria2c" "aria2c"
        start-stop-daemon -K -R 5 -q -p $PIDFILE
        start-stop-daemon -S -q -b -m -p $PIDFILE -c $USER -a $ARIA2C -- $ARGS
        log_end_msg $?
        ;;
status)
        status_of_proc -p $PIDFILE $ARIA2C aria2c && exit 0 || exit $?
        ;;
*)      log_action_msg "Usage: /etc/init.d/aria2c {start|stop|restart|reload|force-reload|status}"
        exit 2
        ;;
esac
exit 0
```
以上脚本 ### BEGIN INIT INFO - ### END INIT INFO 为启动脚本需要定义的 metadata 信息，不定义会报错
上述脚本使用了start-stop-daemon，具体参数可查看`man start-stop-daemon`

修改脚本权限：
```bash
chmod +x /etc/init.d/aria2c
```

设置程序自启动：
```bash
#添加服务
insserv /etc/init.d/aria2c

#删除服务
insserv -r /etc/init.d/aria2c
```
