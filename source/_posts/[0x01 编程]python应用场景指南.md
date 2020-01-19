---
title: '【编程】python应用场景指南'
date: 2020-01-16 14:46:34
categories: 编程
tags: Python
---

来源:  [python最佳实践指南](https://pythonguidecn.readthedocs.io/zh/latest/)

---

# 网络应用
- requests 库
- 分布式系统
    - ZeroMQ
    - RabbitMQ

---

# Web应用 & 框架
- WSGI： web server gateway interface。web服务网关接口
- 大多数web框架包含的模式和工具
    - URL路由（URL Routing）
    - 请求和响应对象（Request and Response Objects）
    - 模板引擎（Template Engine）
    - Web服务器开发（Development Web Server）
- 框架
    - Django：是一个功能齐全的web应用框架
    - Flask：轻量级web框架
    - Falcon：构建快速、可扩展的REST风格API微服务
 - Tornado：一个异步web框架
    - Pyramid：灵活的框架，重点关注模块化
    - Masonite：一个现代，以开发人员为中心的功能齐备的网络框架
- Web服务器
    - Nginx
- WSGI 服务器：独立WSGI服务器相比传统web服务器，使用更少的资源，并提供最高的性能
    - Gunicorn： 有周全的用户界面，十分易于使用和配置
    - Waitress：具备非常可接受的性能
    - uWSGI：用来构建全栈式的主机服务
- 服务端最佳实践： WSGI服务器为Python应用服务，它能更好的处理诸如静态文件服务、请求路由、DDoS保护和基本认证的任务。
- Hosting：平台及服务（Paas）是一种云计算基础设施类型，应用开发者只需关注应用代码，无须关注配置细节
    - Heroku：支持所有类型的Python web应用、服务器和框架。在Heroku上可以免费开发应用程序
    - Eldarion
- 模板
    - JinJa2：很受欢迎的模板引擎
    - Chameleo：
    - Mako： 它的语法和API借鉴了其他模板语言，如Django和Jinja2中最好的部分

<!-- more -->


---
# HTML抓取
- lxml：一个优美的扩展库，快速解析xml一级html文档
- requests

---
# 数据库
- SQLAlchemy： 一个流行的数据库工具，不仅提供ORM层，还有一个通用的API赖编写避免SQL的数据库无关代码
- Records： 极简SQL库，将原始SQL查询发送到各种数据库
- Django ORM： Django用来进行数据库访问的接口
- peewee：另一个ORM，致力于轻量级
- PonyORM：使用与众不同的方法查询数据库
- SQLObject：支付广泛的数据库，只支持python2

---
# 网络
- Twisted： 一款基于事件驱动的网络引擎架构
- PyZMQ：是zeroMQ的python捆绑库，ZeroMQ是一款高效的异步消息库
- gevent：一款基于协程的python网络库

---
# 系统管理
- Fabric：一个简化系统管理任务的库，更加关注应用级别的任务，比如部署
- Salt： 一个开源的基础管理工具，支持从中心节点到多个主机的远程命令执行
- Psutil：获取不同系统信息的接口
- Ansible：一个开源系统自动化工具，它不需要客户机上的代理
- Chef：一个系统的云基础设施自动化框架，使部署服务器到应用到任何物理、虚拟或者云终端上变得简单
- Puppet：来自puppet labs的IT自动化和配置管理软件，允许管理员定义他们的IT基础设施状态，提供一种优雅的方式管理他们的成群的物理或虚拟机器
- Blueprint
- Buildout： 一个开源软件构建工具
- Shinken：兼容Nagios的监控框架

---
# 持续集成
- jenkins：可扩展的持续集成引擎
- buildbot：一个检查代码变化的自动化编译/测试的python系统
- Tox：一款为python软件提供打包、测试和开发的自动化工具
- Travis-CI：分布式CI服务器，能和GitHub无缝集成

---
# 速度
-CPython作为最流行的Python环境，对于CPU密集型任务（CPU bound tasks）较慢，而 PyPy 则较快。
- GIL： 全局解析器锁是python支持多线程并行操作的方式，应该对GIL工作方式有深刻的理解：它如何影响你的成效，你拥有多少个核，以及你程序瓶颈在哪
- C扩展
    - Cython：python语言的超集，可以为python写C、C++模块
- 并发
    - concurrent.futures 模块是标准库中的一个模块，它提供了一个“用于异步调用的高级接口”
    - threading，标准库带有一个threading模块，允许用户手动处理多个线程


---
# 图像处理
- PIL：python图像操作的和辛苦，开发陷入停滞
- OpenCv： 是一个在图像操作与处理上比PIL更先进的库

---
# 数据序列化
数据序列化是指将结构化数据转换成允许以共享或存储的格式，并能恢复成原始结构。 在某些情况下，数据序列化的第二个目的是减少数据大小，从而减小对磁盘和带宽的要求。
- 扁平风格 vs 嵌套风格
- 简单文件（扁平数据）
    - repr： 接受单个对象参数，返回输入的可打印形式
    - ast.literal_eval：安全地解析python数据类型表达式并求值

- 序列化文本
    - CSV文件（扁平数据）：csv
    - YAML（嵌套数据）: yaml
    - JSON文件（嵌套数据）: json
    - XML（嵌套数据）: xml
- 二进制
    - NumPy Arry（扁平数据），NumPy
    - Pickle：python原生的数据序列化模块


---
# XML解析
- untangle： 将XML文档映射为一个python对象，该对象于其结构中包含了原文档的节点与属性信息
- xmltodict：简易的库，致力于将xml变得想json

---
# JSON
- json：解析json后转为python字典或者列表


---
# 密码学
- cryptography：提供加密方法（recipes）和基元（primitives）
- GPGME bindings：提供pythonic方法访问GPG Made Easy
- PyCrypto：提供安全的哈希函数和各种加密算法

---
# 机器学习
- SciPy栈：由数据科学所使用的一组核心帮助包组成，用于统计分析和数据可视化
    - Numpy
    - SciPy library
    - Matplotlib
    - IPython
    - pandas
    - Sympy
    - nose
- scikit-lean：一个用于python的免费开源机器学习库，提供现成的功能来实现诸如线性回归、分类器、SVM、k-均值和神经网络等多种算法


---
# 略
- 命令行应用
- GUI应用
- 科学应用
- 与C/C++库交互
- C语言外部函数接口(CFFI)


