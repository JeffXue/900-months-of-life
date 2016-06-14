---
title: RVDS2.2配置
tags:
  - RVDS
date: 2012-12-01 11:57
categories: 嵌入式
---

1. 进入CodeWarrior for RVDS

2. 选择菜单edit--Debug Settings

3. 修改RealView Assembler 下的 Architecture or Processor 为ARM1176JZF-S（根据不同CPU进行修改）

4. 修改RealView Compiler 下的 Architecture or Processor 为ARM1176JZF-S（根据不同CPU进行修改）

5. 修改RealView Linker 下的 R0 Base （程序所要下载要的内存地址）

6. 修改RealView FromELF 下的 output format（Plain binary） 和output file name （xxx.axf/xxx.bin）

7. 进入AXD

8. 进入菜单Options--configure target（启动时或许会提示缺少某一个.dll文件，只需要在jlink安装目录下找到相关dll文件拷贝到对应的目录下即可）

9. 点击Add，添加jlink安装目录下的JlinkRDI.dll 点击OK即可
