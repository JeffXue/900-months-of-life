---
title: 【编程】python代码最佳实践指南
date: 2020-01-16 14:06:58
categories: 编程
tags: Python
---


来源:  [python最佳实践指南](https://pythonguidecn.readthedocs.io/zh/latest/)

---

#  结构化工程

## 仓库结构
根据项目的实际情况初始化下面的目录结构，可参考[GitHub samplemod](https://github.com/navdeep-G/samplemod)
```
README.rst # 说明文档
LICENSE # 许可证，请查看[choosealicense.com](https://choosealicense.com/)
setup.py # 打包和发布管理
requirements.txt # 依赖
sample/__init__.py # 真正的项目模块
sample/core.py              
sample/helpers.py
docs/conf.py # 参考配置
docs/index.rst # 参考文档
tests/test_basic.py # 测试套件
tests/test_advanced.py
```

另外对于django的初始化项目，需要减少不必要的嵌套：
```
# 错误的初始化操作
django-admin.py startproject samplesite

# 正确的初始化操作，注意最后有`.`，在当前目录做初始化
django-admin.py startproject samplesite .
```

---

<!-- more -->

## 糟糕的结构化特征
- 多重且混乱的循环依赖关系：可以通过再方法或函数内部使用import去避免
- 隐含耦合：某个类的变更会影响到其他类的逻辑
- 大量使用全局变量或上下文
- 面条式代码： 多页嵌套的if与for循环，大量复制-粘贴的过程代码，且没有合适的分割
- 混沌代码： 上百段相似的逻辑碎片，缺乏合适结构的类或对象

---

## 模块导入方式
模块名称要短、使用小写，并避免使用特殊符号，不推荐在模块名中使用下划线，最重要的是，不要使用下划线命名空间，而是使用子模块
```
# 好的实践
import library.plugin.foo
# 不好的实践
import library.foo_plugin
```

> 首先理解import的原理机制，例如`import modu`语句
>- 寻找对应的文件
>    - 调用目录下的 modu.py 文件（如果该文件存在）
>    - 如果没有找到，解析器递归在`PYTTHONPATH`环境变量中查找该文件
>    - 如果仍没找到，将抛出`ImportError`
>- 在隔离作用域内执行模块
>    - 所有顶层语句都会被执行，包括其他引用
>    - 方法与类的定义将会存储到模块的字典中
>    - 模块的变量、方法和类通过命名空间暴露给调用方


不应该使用import的特殊形式`from modu import *`，需要尽可能的保证代码可读性，但不能过于简洁而导致简短隐晦
```
# 差
from modu import *
x = sqrt(4) # sqrt是模块modu的一部分吗？ 或是内建函数？上文定义的？

# 稍好
from modu import sqrt
x = sqrt(4) # 如果import和调用之间没有定义sqrt，sqrt也许是模块modu的一部分

# 最好的做法
import modu
x = modu.sqrt(4) # 显然sqrt是属于modu的

```

---

## 包的__init__.py
任意包含 __init__.py 文件的目录都被认为是一个Python包，导入一个包里不同模块的方式和普通的导入模块方式相似，特别的地方是 __init__.py 文件将集合所有包范围内的定义
> 会寻找包下的__init__.py文件，并执行其中所有顶层语句，导入模块对应定义的所有变量、方法和类在导入方命名中间中可见

常见问题： __init__.py 加了过多的代码，随着项目复杂度增加，导入多层嵌套的子包中的某个部件需要执行所有通过路径里的__init__.py。**因此如果包内模块和子包没有代码共享的需求，使用空白的__init__.py文件是正常 甚至是好的做法**

导入深层嵌套包使用as语法替代冗长的调用
```
import very.deep.module as mod
# 使用mod替代very.deep.module
```

---

## 面向对象 还是 面向函数

python中一切都是对象，并且能按对象的方式处理，python更应该理解为面向`对象语言`而非`面向对象编程的语言`，但python并没有将面向对象编程作为最主要的范式。

根据项目的实际情况选择是否需要使用类和对象，还是纯函数的方式。
> 显然在很多情况下，面向对象编程有用甚至必要，如图形桌面应用或游戏开发等

纯函数在某些架构情况下比类和对象更有效率，因为他们没有任何上下文和副作用。
- 使用无状态的函数是一种更好的编程范式
- 尽量使用隐式上下文和副作用较小的函数与程序
    - 函数的隐式上下文由内部访问到的所有全局变量与持久层对象组成
    - 副作用即函数可能使其上下文发生改变

把隐式上下文和副作用的函数与仅包含逻辑的函数（纯函数）谨慎区分开来能带来以下好处：
- 纯函数的结果是确定的：给定一个输入，输出总是固定相同
- 当需要重构或优化时，纯函数更易于更改或替换
- 纯函数更容易做单元测试：很少需要复杂的上下文配置和之后的数据清除工作
- 纯函数更容易操作、修饰和分发

---

## 使用装饰器语法
> 装饰器是一个函数或类，它可以 包装(或装饰)一个函数或方法。被 '装饰' 的函数或方法会替换原来的函数或方法

首选`@decorators`语法进行装饰，而非手工装饰，这个机制对于分离概念和避免外部不相干逻辑污染主要逻辑很有用处
```
def foo():
    # 实现语句

def decorator(func):
    # 操作func语句
    return func

foo = decorator(foo) # 手动装饰（避免使用手动装饰）

# 使用`@decorators`语法
@decorator 
def bar():
    # 实现语句
# bar()被装饰了
```

---

## 上下文管理器实现原则
实现上下文管理器有两种简单的方法： 使用类（实现`__enter__`和`__exit__`）或使用生成器（使用contextlib的contextmanager装饰生成器）

遵循原则： 如果封装的逻辑量很大，则类的方法可能会更好。 而对于处理简单操作的情况，函数方法可能会更好

```
# 类实现上下文管理器例子

class CustomOpen(object):
    def __init__(self, filename):
        self.file = open(filename)

    def __enter__(self):
        return self.file

    def __exit__(self, ctx_type, ctx_value, ctx_traceback):
        self.file.close()

with CustomOpen('file') as f:
    contents = f.read()
```

```
# 生成器实现上下文管理器例子
from contextlib import contextmanager

@contextmanager
def custom_open(filename):
    f = open(filename)
    try:
        yield f
    finally:
        f.close()

with custom_open('file') as f:
    contents = f.read()
```

## 应对动态类型特性
应对原则：避免对不同类型的对象使用同一变量名
> 函数编程，推荐的是从不重复对同一个变量命名赋值

```
# 差
a = 1
a = 'a string'
def a():
    pass # 实现代码

# 好
count = 1
msg = 'a string'
def func():
    pass # 实现代码

# 即使是相关的不同类型的对象，也更建议使用不同命名
# 不好的实践
items = 'a b c d' # 首先指向字符串...
items = items.split(' ') # ...变为列表
items = set(items) # ...再变为集合

```

## 可变和不可变类型
可变类型是不'稳定'的，不能作为字典的键使用
字符串是不可变类型，组合字符串时，应使用列表推导的构造方式
```
#例子： 创建将0到19连接起来的字符串 (例 "012..1819")

# 差
nums = ""
for n in range(20):
    nums += str(n) # 慢且低效
print nums

# 好
nums = []
for n in range(20):
    nums.append(str(n))
print "".join(nums) # 更高效

# 更好
nums = [str(n) for n in range(20)]
print "".join(nums)

# 最好
nums = map(str, range(20))
print "".join(nums)
```
> 使用 join() 并不总是最好的选择。比如当用预先 确定数量的字符串创建一个新的字符串时，使用加法操作符确实更快，但在上文提到的情况 下或添加到已存在字符串的情况下，使用 join() 是更好的选择

---

# 代码风格

## 一般原则

### 使用明确的代码
存在各种黑魔法的python中，提倡最明确和直接的编码方式
```
# 糟糕
def make_complex(*args):
    x, y = args
    return dict(**locals())

# 优雅
def make_complex(x, y):
    return {'x': x, 'y': y}

```

### 每行只有一个声明
不要在一行代码中写两条独立的语句

### 函数传参原则
整体原则：
- 易读（名字和参数无需解释）
- 易改（添加新的关键字参数不会破坏代码的其他部分）

- 四种方式：
    - 位置参数（强制，没有默认值）： 不要去使用名称和改变顺序，使用默认的顺序传参即可
    - 关键字参数（非强制，有默认值，用于可选参数）：遵循最接近函数定义的语法
    - 任意参数列表（*args，可扩展的位置参数）：一个函数接受的参数列表具有 相同的性质，通常把它定义成一个参数
    - 任意关键字参数字典（**kwargs，可扩展的关键字参数）：不应该被用在能用更简单和更明确的结构，来足够表达函数意图 的情况


### 避免魔法方法

魔法方法最主要的确定是可读性不高，使用更加直接的方式来达成目标通常是更好的方法
> pyline或者pyflakes，将无法解析这种魔法方法

### 约定私有方法或属性

任何不开放给客户端代码使用的方法或属性，应该有一个下划线 前缀

### 返回值
- 建议在函数体中避免使用返回多个有意义的值
- 越早返回所发现的不正确上下文越好，这有助于扁平化的函数结构
- 保持单个出口点可能会更好，有助于提取某些代码路径，多个出口点可能意味着需要重构

## Pythonic

### 解包
```
for index, item in enumerate(some_list):
    # 使用index和item做一些工作

a, b = b, a

a, (b, c) = 1, (2, 3)

a, *rest = [1, 2, 3]

a, *middle, c = [1, 2, 3, 4]
```

### 使用忽略的变量
```python
# 不需要这个变量是，使用__
basename, __, ext = filename.rpartions('.)
```

### 创建N个对象列表/列表对象
```
four_nones = [None] * 4

four_lists = [ [] for __ in xrange(4) ]
```

### 使用列表创建字符串
```
letters = ['s', 'p', 'a', 'm']
word = ''.join(letters)
```

### 在集合中查找

查找集合是利用python中集合的可哈希的特性，而查找列表会查看每一项知道找到匹配项。两者的查询性能是不同的
在下列场合使用集合或者字典，而不是列表：
- 集合体中包含大量的项
- 你将在集合体中重复查找项
- 你没有重复的项

## Python之禅（PEP 20）
见 pep20_by_example.pdf 

## PEP8 
PEP8 是python的代码风格指南，详情见 pep8.org
```
pip install pycodestyle

# 检查文件
pycodestyle optparse.py

# 自动将代码转换成PEP8 风格
pip install autopep8

# 指令格式化一个文件
autopep8 --in-place optparse.py
```

## 约定

### 检查变量是否等于常量
```python
# 糟糕
if attr == True:
    print(True)
if attr == None:
    print('attr is None')

# 优雅
# 检查值
if attr:
    print 'attr is truthy!'

# 或者做相反的检查
if not attr:
    print 'attr is falsey!'

# or, since None is considered false, explicitly check for it
if attr is None:
    print 'attr is None!'

```

### 访问字典元素
不要使用dict.has_key()，应使用 x in d语法，或者将一个默认参数传递给dict.get()
```
d = {'hello': 'world'}

print(d.get('hello', 'default_value')) # 打印 'world'
print(d.get('thingy', 'default_value')) # 打印 'default_value'

# Or:
if 'hello' in d:
    print d['hello']
```

### 维护列表
- 使用列表推导式
    - 如果只是要遍历列表，使用迭代器
```
# 推导创建了一个新的列表对象
filtered_values = [value for value in sequence if value != x]

# 生成器不会创建新的列表
filtered_values = filter(lambda i: i != x, sequence)
```

- map()和filter()函数使用一种不同但是更简洁的语法处理列表
    - filter返回的为迭代器而不是列表，如需要列表，请使用list进行包装`list(filter(....))`    

- 修改原始列表会产生副作用：可能会有其他变量引用原始列表，修改就会有风险
    - 在列表中修改值：创建一个新的列表对象并保留原始列表对象会更安全
    - 在迭代列表过程中，永远不要从列表移除元素

### 读取文件
使用with open 语法来读取文件，会为你自动关闭文件

### 行的延续
避免使用反斜杠将一行分隔为多行，更好的方案是在元素周围使用括号，解析器会把行的结尾和下一行连接起来直到遇到闭合括号
```
my_very_big_string = (
    "For a long time I used to go to bed early. Sometimes, "
    "when I had put out my candle, my eyes would close so quickly "
    "that I had not even time to say “I’m going to sleep.”"
)

from some.deep.module.inside.a.module import (
    a_nice_function, another_nice_function, yet_another_nice_function)

```

---

# 阅读好的代码
推荐阅读的python项目
- Howdoi: 代码搜寻工具
- Flask: 是基于Werkzeug和Jinja2，Web服务微框架
- Diamond: 守护进程，它收集指标，并且将他们发布至Graphite或其它后端。 
- Werkzeug: 非常重要的WSGI实用模型
- Requests: HTTP库
- Tablib: 无格式的表格数据集库


---

# 文档

## 项目文档
- README： 解析项目或者库的目的，软件主要源的URL，一些基本的信用信息，为代码阅读者的主要入口
- INSTALL： 非必要，通常把命令放在README中即可
- LICENSE： 应该指定向公众开放的软件许可
- TODO： 位于README或者TODO，列出代码的开发计划
- CHANGELOG：位于README或者CHANGELOG，呈现对代码库的最新修改的简短概述

## 项目发布
- 一份介绍：用一两个极其简化的用例，简短地概述产品用来做什么
- 一份教程：展示主要的用例，要有更多细节，可一步步搭建工作原型
- 一份API参考： 通常从代码中生产(docstrings)
- 开发人员文档： 适用于潜在贡献者，包括代码惯例和通用设计策略

## Sphine
Sphine 最流行的python文档工具，可以把reStructured Text转换成广泛的输出格式

Read The Docs 是一个很好的免费文档托管服务，可以托管你的Sphine文档

## reStructuredText

大多数Python文档是用 reStructuredText 编写的。它就像是内建了所有可选扩展的 Markdown

## 代码文档建议
- 代码加入注释是为了更容易的理解代码
- 文档字符串 用来描述模块、类、函数`""" xxxxx  """`
- 不要用三引号去注释代码
- Sphine会解析文档字符串为reStructuredText，并以HTML呈现，让示例代码片段嵌入项目的文档非常简单
- Doctest会读取文档字符串内嵌>>> 的内容并运行，以检查命令输出是否匹配其下行的内容，运行开发人员在源码中嵌入真实的示例和函数用法，还能确保代码被测试和工作
- 文档字符串和块注释不能互换，函数或类的开头注释区是开发者的注解，而文档字符串描述函数或类的操作
- 编写文档字符串取决于函数、方法或类的复杂度，详情可以查看docstrings （PEP 257）

---

# 测试你的代码
测试代码和运行代码一起写是一种非常好的习惯。
测试的通用规则：
- 测试单元应该集中小部分的功能，并证明是对的
- 每个测试单元必须完全独立
- 尽量使测试单元快速运行
- 学习使用工具，学习如何允许一个单独的测试用例
- 在编码前后，要运行完整的测试套件
- 实现钩子（hook）是一个非常好的主意
- 当您调试代码的时候，首先需要写一个精确定位bug的测试单元
- 测试函数使用长且描述性的名称，与运行代码不一样
- 测试代码的另外一个用处是作为新开发人员的入门介绍

## 基础
- 单元测试：unittest
- 文档测试： doctest

## 工具
- pytest
- Hypothesis
- tox
- mock

---

# 日志
日志的目的：
- 诊断日志：记录与应用程序操作相关的日志
- 审计日志： 商业分析而记录的日志

命令行应用，打印相对日志是更好的选择，而在其他情况，日志总能优于打印

## 库日志
在库中，声明日志的最佳方式是通过__name__全局变量。如requests库在__init__.py中
```
import logging
logging.getLogger(__name__).addHandler(logging.NullHandler())
```

## 应用程序日志
配置日志至少有以下三种方式：
- INI格式文件
    - 优点: 使用 logging.config.listen() 函数监听socket，可在运行过程中更新配置
    - 缺点: 通过源码控制日志配置较少（ 例如 子类化定制的过滤器或记录器）
- 使用字典或JSON格式文件
    - 优点: 除了可在运行时动态更新，还可通过 json 模块从其它文件中导入配置
    - 缺点: 很难通过源码控制日志配置
- 使用源码
    - 优点: 对配置绝对的控制
    - 缺点: 对配置的更改需要对源码进行修改

### 通过INI文件配置
logging_config.ini
```
[loggers]
keys=root

[handlers]
keys=stream_handler

[formatters]
keys=formatter

[logger_root]
level=DEBUG
handlers=stream_handler

[handler_stream_handler]
class=StreamHandler
level=DEBUG
formatter=formatter
args=(sys.stderr,)

[formatter_formatter]
format=%(asctime)s %(name)-12s %(levelname)-8s %(message)s
```

```
# 源码中调用
import logging
from logging.config import fileConfig

fileConfig('logging_config.ini')
logger = logging.getLogger()
logger.debug('often makes a very good meal of %s', 'visiting tourists')

```

### 通过字典配置

```
from logging.config import dictConfig

logging_config = dict(
    version = 1,
    formatters = {
        'f': {'format':
              '%(asctime)s %(name)-12s %(levelname)-8s %(message)s'}
        },
    handlers = {
        'h': {'class': 'logging.StreamHandler',
              'formatter': 'f',
              'level': logging.DEBUG}
        },
    root = {
        'handlers': ['h'],
        'level': logging.DEBUG,
        },
)

dictConfig(logging_config)

logger = logging.getLogger()
logger.debug('often makes a very good meal of %s', 'visiting tourists')
```

### 通过源码配置
```

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter(
        '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

logger.debug('often makes a very good meal of %s', 'visiting tourists')
```

# 常见陷阱

## 可变默认参数
```
def append_to(element, to=[]):
    to.append(element)
    return to

>>> my_list = append_to(12)
>>> [12]
>>> my_other_list = append_to(42)
>>> [12, 42]
```

函数被定义时，一个新的列表被创建，而且这个列表在后续的每次调用中都被使用

正确的做法是： to=None，None通常是一个好的选择

## 延迟绑定闭包
```
def create_multipliers():
    return [lambda x : i * x for i in range(3)]


for multiplier in create_multipliers():
    print(multiplier(2))


# 实际输出 
# 8
# 8
# 8
```

python的闭包时 延迟绑定，意味着闭包中用到的变量，是在内部函数被调用时查询得到的。
不论 任何 返回的函数是如何被调用的， i 的值是调用时在周围作用域中查询到的。 接着，循环完成， i 的值最终变成了4。

取巧的做法： `[lambda x, i=i : i * x for i in range(5)]` 创建一个立即绑定参数的闭包

### 屏蔽pyc文件

```
# 禁用pyc文件
export PYTHONDONTWRITEBYTECODE=1

# 删除所有pyc文件
find . -type f -name "*.py[co]" -delete -or -type d -name "__pycache__" -delete

# 版本控制忽略pyc文件
*.py[cod] # 将匹配 .pyc、.pyo 和 .pyd文件
__pycache__/ # 排除整个文件夹
```
