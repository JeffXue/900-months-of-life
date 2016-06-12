---
title: apache的MPMs详解
date: 2016-03-10 09:21:25
categories: 运维
tags: 
- Apache 
- MPMS
---

# MPMs

Multi-Processing Modules（MPMs）为多路处理模块，对于类UNIX系统，有三个不同的MPM可选择，不同的模式会影响apache的速度和可靠性。

## Perfork MPM

该MPM实现了一个非线程，pre-forking的web server，每个进程均可处理请求，并且有一个父进程管理server poll。适用于没有线程安全库，需要避免线程兼容性问题的系统。每个请求之间都是相互独立，这对于那些需要隔离请求的系统来说是最好的MPM。

这个MPM具有很强的自我调节能力，一般情况很少去调整配置。最重要的配置是MaxRequestWorkers，应该让该值大于你所预估的同时并发请求数，同时也应考虑是否有足够的内存。

### Perfork 配置

extra/httpd-mpm.conf
```bash
<IfModule mpm_prefork_module>
    # 启动进程数量
    StartServers             5
    # 最小空闲进程数量，父进程会保持至少有MinSpareServer数量的子进程处理空闲状态
    MinSpareServers          5
    # 最大空闲进程数量，当系统有过多的空闲进程时，父进程会销毁子进程，
    # 保持空闲子进程数量为MaxSpareServers
    MaxSpareServers         10
    # 最大进程数量
    MaxRequestWorkers      250
    # 每个进程处理的最大请求数，当处理请求数量达到MaxConnectionsPerChild之后，
    # 会销毁该子进程，生成新的进程，0为无限制
    MaxConnectionsPerChild   0
</IfModule>
```

## Worker MPM

该MPM实现了一个混合多进程多线程server，使用线程来处理请求，在处理大量的请求情况下，比Perfork模式消耗更少的资源。同时，它通过保持多个进程，每个进程含有多个线程来保证服务器的稳定性。

一个单独控制进程（父进程）负责子进程的建立，每个子进程建立固定ThreadsPerChild数量的服务线程和一个监听线程，该监听线程接入请求并传递给服务线程处理和应答。

最重要的配置是ThreadsPerChild和MaxRequestWorkers，ThreadsPerChild控制每个进程的线程数量，MaxRequestWorkers控制了最大的总线程数量，其决定了能处理的最大并发请求数量。最大的子进程数量由MaxRequestWorkers/ThreadsPerChild值决定。

两个指令可以对子进程数量和子进程的线程数量进行强限制，但需要完全停止server后再启动才能生效
- ServerLimit限制最大的进程数量，但需要>=MaxRequestWorkers/ThreadsPerChild
- ThreadLimit限制子进程的最大的线程数量，但需要>= ThreadsPerChild

除了处于激活状态的进程，还有一些进程处于等待销毁的状态，但其仍在处理一个连接请求，这时候总的线程数量可能达到了MaxRequestWorkers的数量，但实际处理请求的线程数量并没有达到该数量，可以通过以下设置来避免该情况：
- 设置MaxConnectionsPerChild为0,
- 设置MaxSpareThreads等于MaxRequestWorkers

当存在the thundering herd problem（generally, when there are multiple listening sockets）情况时，该MPM采用了mpm-accept mutex来序列化请求连接，可以通过Mutex指令来修改。详细可以看[performance_hints](https://httpd.apache.org/docs/2.4/misc/perf-tuning.html)

### Worker 配置

extra/httpd-mpm.conf
```bash
<IfModule mpm_worker_module>
    # 启动进程数量
    StartServers             3
    # 最小空闲线程数量，父进程会保持至少有MinSpareThreads数量的线程处理空闲状态
    MinSpareThreads         75
    # 最大空闲线程数量，当系统有过多的空闲线程时，父进程会销毁子进程，
    # 保持空闲线程数量为MaxSpareThreads
    MaxSpareThreads        250
    # 每个进程的线程数量 
    ThreadsPerChild         25
    # 最大线程数量
    MaxRequestWorkers      400
    # 每个进程处理的最大请求数，当处理请求数量达到MaxConnectionsPerChild之后，
    # 会销毁该子进程，生成新的进程，0为无限制
    MaxConnectionsPerChild   0
</IfModule>
```

## Event MPM

[官方文档](https://httpd.apache.org/docs/2.4/mod/event.html)
该MPM可以承受更高的并发，通过传递一些处理工作给监听线程，从而释放工作线程来服务新的请求。

### 与Worker MPM的关系

Event是基于Worker MPM，也是一个混合多进程多线程server。一个单独控制进程（父进程）负责子进程的建立，每个子进程建立固定ThreadsPerChild数量的服务线程和一个监听线程，该监听线程接入请求并传递给服务线程处理和应答。

相关配置指令与Worker MPM的指令保持一致，只增加了AsyncRequestWorkerFactor。

### 工作模式

该MPM为了解决HTTP上面的keep alive问题：当一个client完成了第一个请求，会继续保持该连接打开，并通过同一个socket发送更多的请求，减少在建立TCP连接时的开销。然而Apache HTTP Server会保持整个子进程/子线程以等待client端的数据，这样会带来一些缺点。为了解决这个问题，该MPM为每个进程使用专用的监听线程处理监听套接字，所有的处于keepalive状态的sockets，还有通过了handler和protocol filters在将数据发送到client的sockets。

单个进程/线程块可以处理连接的总数量由AsyncRequestWorkerFactor指令来调节

#### 异步连接

除了event外的前面的MPMs，异步连接均需要一个专门固定的工作线程。在mod_status的状态页面显示以下部分的异步连接
- Writing
发送response到client，可能因为连接太慢而TCP write buffer填满后出现。通常向该socket中进行write()，会返回EWOULDBLOCK或者EAGAIN，过一段空闲时间后，才会变成可写。持有该socket的工作线程可能会将该等待的任务返回给监听线程，一旦有事件发生（”the socket is now writable“），监听线程会重新分配该任务到第一个可用的空闲线程
- Keep-alive
来自于worker MPM最基本的改进，一旦工作线程完成一个回复后，会将该socket返回给监听线程，将等待后续的请求。当新的请求来的时候，监听器会直接把请求分配到第一个可用的工作线程。反过来，当KeepAliveTimeout时，socket将会被关闭。通过该方式，工作线程无需负责空闲的sockets，他们可以重用来处理其他的请求。
- Closing
有时候MPM需要完成一些lingering close，即先返回一个早期的错误给client，同时它仍将数据传输给httpd。发送response，然后立即关闭连接是不正确的，因为client（仍在试图发送请求的其余部分）会得到一个connection reset和无法读取httpd的应答。在这种情况下，httpd会读取余下的请求并允许client获取应答。Lingering close是有时间限制，但仍会占用相对较长的时间，因此工作线程会把该任务返回给监听器

这些改进均对HTTP/HTTPS连接有效。

#### 限制

这个连接的改进对某些声明不兼容event的connection filters并不起作用、在这种情况下，MPM会使用worker MPM并为每个连接保持一个工作线程。而server的内置模块均与event MPM兼容。
(详细说明请查看官方文档)

#### 背景资料

event modle可以引进一些操作系统的新的APIs：
- epoll(linux)
- kqueue(BSD)
- event ports(solaris)

在这些新的API之前，采用的是select和poll。当处理大量连接或者连接速度很高的情况下，这些APIs会变慢，而新的APIs则不会。

MPM认为底层的apr_pollset实现是合理的线程安全。这使得MPM避免过多的高级锁，或者为了发送一个keep-alive socket而唤醒监听线程。这些近来只兼容KQueue和EPoll。

#### 要求

该MPM的线程同步基于APR的原子比较和交换操作，如果你在一个X86平台上并且不需要支持386，或者你在一个SPARC平台并且不需要在pre-UItraSPARC芯片上运行，在编译configure时添加参数--enable-nonportable-atomics=yes，这会让APR使用更有效的操作码来实现原子操作，这在旧的CPU上无法实现。

该MPM无法很好的支持缺乏好的线程管理的旧平台，但使用EPoll或KQueue则是可行的
- FreeBSD 5.3以上
- NetBSD 2.0 以上
- Linux 推荐2.6 kernel，同样需保证glibc支持EPoll

#### AsyncRequestWorkerFactor指令

该指令只在2.3.13以上版本有效（AsyncRequestWorkerFactor 默认值为2）。

event 以异步的方式来处理连接，让工作线程只占用其需要的更短时间，和为只有一个请求的工作线程连接保留其连接。这样会导致一个情况：所有的工作线程被占用，没有工作线程去建立新的异步连接。
为了减轻该情况，event MPM做了两件事：
- 基于空闲的工作线程来限制每个进程的连接数
- 如果所有的工作线程均处于忙状态，会关闭keep-alive状态的连接（继续keep-alive还未超时），这样允许各个clients去重新连接一个不同的进程，该进程可能有可用的工作线程。

这个指令可以用来微调每个进程的连接数限制，一个进程只有但以下条件满足的情况下才会新建连接：
```
当前连接数（不包括“closing”状态） < ThreadsPerChild + (AsyncRequestWorkerFactor * number of idle workers)
```

所有进程最大的并发连接数可以用以下的公式进行计算：
```
(ThreadsPerChild + (AsyncRequestWorkerFactor * number of idle workers)) * ServerLimit
```

```
Example：
ThreadsPerChild = 10
ServerLimit = 4
AsyncRequestWorkerFactor = 2
MaxRequestWorkers = 40

idle_workers = 4 (average for all the processes to keep it simple)

max_connections = (ThreadsPerChild + (AsyncRequestWorkerFactor * idle_workers)) * ServerLimit 
                = (10 + (2 * 4)) * 4 = 72
```

当所有工作线程均为空闲的情况下，可以用更简单的方式计算最大并发连接数：
```
(AsyncRequestWorkerFactor  + 1) * MaxRequestWorkers
```

```
Example：
ThreadsPerChild = 10 
ServerLimit = 4
MaxRequestWorkers = 40
AsyncRequestWorkerFactor = 2
If all the processes have all threads idle then:
idle_workers = 10
We can calculate the absolute maximum numbers of concurrent connections in two ways:
    max_connections = (ThreadsPerChild + (AsyncRequestWorkerFactor * idle_workers)) * ServerLimit 
                    = (10 + (2 * 10)) * 4 = 120
    
    max_connections = (AsyncRequestWorkerFactor + 1) * MaxRequestWorkers 
                    = (2 + 1) * 40 = 120
```

>Tuning AsyncRequestWorkerFactor requires knowledge about the traffic handled by httpd in each specific use case, so changing the default value requires extensive testing and data gathering from mod_status.

### Event 配置

extra/httpd-mpm.conf
```bash
<IfModule mpm_event_module>
    # 启动进程数量
    StartServers             3
    # 最小空闲线程数量，父进程会保持至少有MinSpareThreads数量的线程处理空闲状态
    MinSpareThreads         75
    # 最大空闲线程数量，当系统有过多的空闲线程时，父进程会销毁子进程，
    # 保持空闲线程数量为MaxSpareThreads
    MaxSpareThreads        250
    # 每个进程的线程数量 
    ThreadsPerChild         25
    # 最大线程数量
    MaxRequestWorkers      400
    # 每个进程处理的最大请求数，当处理请求数量达到MaxConnectionsPerChild之后，
    # 会销毁该子进程，生成新的进程，0为无限制
    MaxConnectionsPerChild   0
</IfModule>
```

# 默认的MPM

编译httpd的时候，若没有指定MPM模式，将会根据当前环境自动选择对应的MPM模式
在类Unix系统中，有以下两个条件来决定默认的MPM模式
1. 系统是否支持多线程
2. 系统是否支持安全的线程池（如kqueue/epoll）
如果上述问题均为yes，则默认的MPM为event
如果第一个问题为yes，第二个问题为no，则默认的MPM为worker
如果两个问题均为no，则默认的MPM为prefork

## 当前的MPM模式
运行以下命令，查看MPM输出
```bash
/usr/local/apache/bin/apachectl -V
```

# 设置MPM

## 以静态模块编译MPM
在编译安装configure的时候指定特定的MPM模式即可：--with-mpm=NAME

## 以动态模块编译MPM
以动态模式编译MPM，并通过LoadModule加载，而不必要对httpd进行重新编译
```bash
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
```
但需要在httpd编辑阶段指定了编译共享模块：--enable-mods-shared=all 或者 --enable-mpms-shared=all

