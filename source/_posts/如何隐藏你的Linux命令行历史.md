---
title: 如何隐藏你的Linux命令行历史
tags:
  - Linux
date: 2016-07-25 23:24:35
categories: 运维
---


简直就是黑客必备小技能

# 命令前加空格

首先需要设置环境变量HISCONTROL为ignorespace或者ignoreboth

```bash

export HISTCONTROL=ignorespace

```



后面在运行命令前加入空格，将不会被记录到系统history中

```bash

Jeff-Mac$  echo $HISTCONTROL

```



# 禁止当前会话的所有历史记录

```bash

export HISTSIZE=0

```

没有东西会记录到历史记录中


<!-- more -->


# 工作结束后清除整个历史

```bash

history -cw

```



# 只针对你的工作关闭历史记录

```bash

Jeff-Mac$  set +0 history

```

set之前带空格，执行该命令后，所有东西都不会记录到历史记录



重新开启历史功能：

```bash

Jeff-Mac$  set -0 history

```



# 从历史记录中删除指定命令

```bash

Jeff-Mac$  history | grep "part of command  you want to remove"

Jeff-Mac$  history -d [num]

```

num 为对应想删除命令的行数






