---
title: linux应用程序设计基础--进程间通信（IPC）
tags:
  - Linux
date: 2012-11-20 10:41
categories:
  - Linux
---

# 进程间通信作用
- 数据传输
- 资源共享
- 通知事件
- 进程控制

# 通信方式
- 管道pipe/FIFO
- 信号signal
- 消息队列
- 共享内存
- 信号量
- 套接字

<!-- more -->

# 管道通信
1. 管道：单向、先进先出
2. 管道种类
    - 无名管道：父子进程通信
    - 有名管道：任意进程通信
3. 无名管道
```c
int pipe(int filedis[2]);
//filedis[0]用于读管道，filedis[1]用于写管道
```
4. 关闭管道：将2个文件描述符关闭
```c
pipe() -> fork() 先pipe再fork，子进程继承文件描述符
```
5. 命名管道（FIFO）：不相干进程交换信息
```c
int mkfifo(const char *pathname,mode_t mode);
//O_NONBLOCK(非阻塞标志)
```

# 信号通信
1. 30种信号类型：常见：SIGINT（中断）,SIGKILL（KILL命令发出的信号）
2. 处理方式：
    - 忽略此信号（SIGKILL,SIGSTOP不能忽略）
    - 执行希望动作
    - 执行默认动作
3. 信号发送：kill/raise
```c
int kill(pid_t pid,int signo);
//KILL可以向自身发送信号，可以向其他发送信号（#include <sys/type.h>  #include <signal.h>）
int raise(int signo);//向进程自身发送信号
```
4. alarm设置一个时间值产生sigalarm信号，默认动作终止该进程（一个进程只能有一个）
```c
#include <unistd.h>
unsigned int alarm(unsigned int seconds);
```
5. pause 使进程挂起知道捕捉一个信号
```c
int pause(void);
```
6. 主要处理
    - 使用简单的signal函数
    ```c
    void ( *signal (int signo, void (*func)(int)))(int)
    //func 可以分为：SIG_ING：忽略 / SIG_DFL：默认处理 / 信号处理函数名
    ```
    - 使用信号集处理函数

# 共享内存
被多个进程共享的一部分物理内存（特点：快）
STEP:
- 创建共享内存：shmget
- 映射共享内存：映射到具体的进程空间shmat

1. int shmget(key_t key,int size,int shmflg);
key 标识共享内存键值：0/IPC_PRIVATE
key=IPC_PRIVATE:创建一块新的共享内存
key=0&&shmflg=IPC_PRIVATE:同样创建新的共享内存
返回内存标识符

2. int shmat(int shmid,char *shmaddr,int flag);
shmid:标识符
flag：以什么方式确定地址
成功返回共享内存映射到进程的地址

3. 脱离映射：int shmdt(char *shmaddr);

# 消息队列
1. 信号能传送的信号量有限，管道只能传送无格式的字节流
2. 消息队列：消息链表，具有特定的格式（读完则清除）
    - POSIX消息队列 //POSIX：可移植操作系统接口
    - 系统V消息队列 //随内核持续
3. 消息队列的内核持续性要求每个消息队列有唯一的键值
```c
#include <sys/type.h>
#include <sys/ipc.h>

key_t ftok(char *pathname,char proj);//返回键值

int msgget(key_t key,int msgflg);//返回消息队列描述字
/*msgflg:
    IPC_CREAT:创建新的队列
    IPC_EXCL:若已经存在，返回error
    IPC_NOWAIT:不阻塞
key为 IPC_PRIVATE也可创建
*/

//向消息队列发送消息
int msgsnd(int msqid,struct msgbuf *msgp,int msgsz,int msgflg);
/*
struct msgbuf{
    long mtype;//消息类型
    char mtext[];//消息数据首地址}
*/

//接收消息
int msgrcv(int msqid,struct msgbuf *msgp,int msgsz,long msgtype,int msgflg);
//成功读取后，队列中消息则被删除
```

# 信号量
1. 主要用途：保护临界资源（根据其判断是否访问资源）/进程同步
2. 分类
    - 二值信号量：0/1
    - 计数信号量：任意非负值
3. 创建/打开
```c
int semget(key_t key,int nsems,int semflg);//nsems为信号灯集内信号灯数量
```

4. 操作
```c
int semop(int semid,struct sembuf *sops,unsiged nsops);
//*sops 为操作数组，nsops为sops所指向数组个数
struct sembuf{
        unsigned short sem_num;//index in array
        short sem_op;//operation
        short sem_flg;//flags
}
```
