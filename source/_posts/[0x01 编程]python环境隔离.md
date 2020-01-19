---
title: 【编程】python环境隔离
date: 2020-01-16 14:05:23
categories: 编程
tags: Python
---



来源:  [python最佳实践指南](https://pythonguidecn.readthedocs.io/zh/latest/)

---

# 隔离环境：虚拟环境
virtualenv 是一个创建隔绝的Python环境的 工具。virtualenv创建一个包含所有必要的可执行文件的文件夹，用来使用Python工程所需的包
```
# 安装virtualenv
pip install virtualenv

# 创建一个虚拟环境
cd your_project_folder
virtualenv venv

# 激活虚拟环境
source venv/bin/activate

# 安装依赖包
pip install requests

# 记录环境依赖，能帮助确保安装、部署和开发之间的一致性
pip freeze > requirements.txt

# 退出虚拟环境
deactivate

```
