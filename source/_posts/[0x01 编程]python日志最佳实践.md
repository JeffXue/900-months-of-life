---
title: 【编程】python日志最佳实践
date: 2020-02-05 12:48:25
categories: 编程
tags: Python
---


---

# `print`的局限性

使用print输出日志是一个常规性的做法，但应该尽可能避免使用print来输出日志，而是使用内置的logging模块。
使用print输出日志存在以下局限：
- 无法区分信息的重要性
- 可能存在很多垃圾信息在日志中，不便于找到目标日志
- 不能通过修改代码的方式控制日志
- 所有print信息将输出到标准输出中

<!-- more -->

---

# 标准库：`Logging`

## 常规用法

- `basicConfig`配置方法
- `FileHandler`配置方法
- 日志轮询配置方法：`RotatingFileHandler` 或 `TimedRotatingFileHandler`
- `StreamHandler`配置方法
- 输出不同级别日志
- 捕获异常日志

```python
#!/usr/bin/env python3.7

import logging
from logging.handlers import TimedRotatingFileHandler
from logging.handlers import RotatingFileHandler

LOG_LEVEL = logging.DEBUG
LOG_FORMAT = '%(asctime)s %(filename)s[%(funcName)s:%(lineno)d] %(levelname)-8s %(message)s'
LOG_FILE = 'debug.log'

logger = logging.getLogger(__name__)
logger.setLevel(LOG_LEVEL)

# 可通过 baseConfig 的方式添加配置
# logging.basicConfig(level=LOG_LEVEL,
# format=LOG_FORMAT,
# filename=LOG_FILE,
# datefmt='%Y-%m-%d %H:%M:%S',
# filemode='a')

# 若不使用 baseConfig 的方式，也可以手动添加 FileHandler
# 若需要设置日志轮询，使用 RotatingFileHandler 或者 TimedRotatingFileHandler 替换 FileHandler
# file_handler = TimedRotatingFileHandler(LOG_FILE, when='D', backupCount=10)
# file_handler = RotatingFileHandler(LOG_FILE, maxBytes=10*1024*1024*1024, backupCount=10)
file_handler = logging.FileHandler(LOG_FILE)
file_handler.setLevel(LOG_LEVEL)
file_handler.setFormatter(logging.Formatter(LOG_FORMAT))
logger.addHandler(file_handler)

# 定义一个StreamHandler，将INFO级别或更高的日志信息打印到标准错误，并将其添加到当前的日志处理对象
console_handler = logging.StreamHandler()
console_handler.setLevel(LOG_LEVEL)
console_handler.setFormatter(logging.Formatter(LOG_FORMAT))
logger.addHandler(console_handler)


if __name__ == '__main__':
    # 记录不同级别的日志
    logger.info('Start reading database')
    logger.debug('Update database records')

    # 用于捕获异常
    try:
        open('/path/to/does/not/exist', 'rb')
    except (SystemExit, KeyboardInterrupt):
        raise
    except Exception as e:
        logger.error('Failed to open file', exc_info=True)

```

## logger陷阱
在模块中创建logger  `logger = logging.getLogger(__name__)`，看上去无害，实际上是一个陷阱。
在模块中创建 logger后 ，在从文件加载 logging 配置之前导入该模块。 logging.fileConfig 和 logging.dictConfig，默认禁用已经存在的 logger。 所以配置文件中的配置不会在模块中的 logger 中生效。

my_module.py
```python
import logging

logger = logging.getLogger(__name__)

def foo():
    logger.info('Hi, foo')

class Bar(object):
    def bar(self):
        logger.info('Hi, bar')

```

main.py
```python
import logging

# load my module
import my_module

# load the logging configuration
logging.config.fileConfig('logging.ini')

my_module.foo()
bar = my_module.Bar()
# logging.ini的配置在模块中所创建的logger不会生效
bar.bar()
```

可以通过两种方式来避免该陷阱
- 将logger对象传入到类的构造函数中，以便在类中引用
- 在配置中设置`disable_existing_loggers=False` （推荐该方式）

```python
import logging
import logging.config

logger = logging.getLogger(__name__)

# load config from file
# logging.config.fileConfig('logging.ini', disable_existing_loggers=False)
# or, for dictConfig
logging.config.dictConfig({
    'version': 1,
    'disable_existing_loggers': False, # this fixes the problem
    'formatters': {
        'standard': {
            'format': '%(asctime)s [%(levelname)s] %(name)s: %(message)s'
        },
    },
    'handlers': {
        'default': {
            'level':'INFO',
            'class':'logging.StreamHandler',
        },
    },
    'loggers': {
        '': {
            'handlers': ['default'],
            'level': 'INFO',
            'propagate': True
        }
    }
})

logger.info('It works!')
```


## 使用YAML配置logging
无论使用ini的配置文件或者json的配置，实际在可读性和可维护性上均比不上YAML格式的配置，因此应该尽可能的采用yaml格式的日志配置（但需要安装yaml第三方模块，若采用json格式，则可直接使用内置的json模块）

logging.yaml
```yaml
---
version: 1
disable_existing_loggers: False
formatters:
    detail:
        format: "%(asctime)s %(filename)s[%(funcName)s:%(lineno)d] %(levelname)-8s %(message)s"

handlers:
    console:
        class: logging.StreamHandler
        level: DEBUG
        formatter: detail

    debug_file_handler:
        class: logging.handlers.TimedRotatingFileHandler
        level: DEBUG
        formatter: detail
        filename: debug.log
        when: D
        backupCount: 20
        encoding: utf8


    info_file_handler:
        class: logging.handlers.TimedRotatingFileHandler
        level: INFO
        formatter: detail
        filename: info.log
        when: D
        backupCount: 20
        encoding: utf8

    error_file_handler:
        class: logging.handlers.TimedRotatingFileHandler
        level: ERROR
        formatter: detail
        filename: errors.log
        when: D
        backupCount: 20
        encoding: utf8

root:
    level: INFO
    handlers: [console, debug_file_handler, info_file_handler, error_file_handler]
```

yaml_logging.py
```python
#!/usr/bin/env python3.7

# Requirement：
# PyYAML==5.3

import os
import logging.config

import yaml


def setup_logging(default_path='logging.yaml', default_level=logging.INFO, env_key='LOG_CFG'):
    """设置logging配置，可以通过LOG_CFG变量指定配置文件
    如： LOG_CFG=my_logging.yaml python my_server.py
    """
    target_path = default_path
    env_yaml_path = os.getenv(env_key, None)
    if env_yaml_path:
        target_path = env_yaml_path
    if os.path.exists(target_path):
        with open(target_path, 'rt') as f:
            config = yaml.safe_load(f.read())
        logging.config.dictConfig(config)
    else:
        logging.basicConfig(level=default_level)


if __name__ == '__main__':

    setup_logging(default_level=logging.DEBUG)
    logger = logging.getLogger(__name__)

    logger.debug('Debug Work!')
    logger.info('Info Work!')

    # 用于捕获异常
    try:
        open('/path/to/does/not/exist', 'rb')
    except (SystemExit, KeyboardInterrupt):
        raise
    except Exception as e:
        logger.error('Failed to open file', exc_info=True)

```




---
# 参考文档
- [Python Logging 最佳实践](https://zdyxry.github.io/2018/07/22/%E8%AF%91-python-logging-%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5/)
- [python的logging模块学习](https://www.cnblogs.com/dkblog/archive/2011/08/26/2155018.html)