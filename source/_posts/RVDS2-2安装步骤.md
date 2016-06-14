---
title: RVDS2.2安装步骤
tags:
  - RVDS
date: 2012-11-30 20:40
categories: 嵌入式
---

安装环境：window7
CPU：AMD（对安装会有影响，查看最后面排除CPU引起错误说明）

1. 下载rvds2.2的压缩包(下载地址:http://115.com/file/aq6lhqym)解压,进入目录

2. 进入Crack文件夹,双击运行keygen.exe,然后点击Generate来生成license.dat

3. 在C盘的根目录下创建一个名为flexlm的文件夹,将刚才生成的license.dat拷贝进去，同时将LM_LICENSE_FILE = c:\flexlm\license.dat 加入到环境变量中

4. 运行Crack文件夹中的patch.exe进行打补丁（否则安装到100%之后会提示错误，无法安装成功）:
``` 
  %Install Path%\IDEs\CodeWarrior\CodeWarrior\5.6.1\1592\win_32-pentium\bin\Plugins\License\oemlicense.dll （该文件没有找到，我直接跳过了）
  %Install Path%\IDEs\CodeWarrior\RVPlugins\1.0\86\win_32-pentium\oemlicense\oemlicense.dll 
  %Install Path%\RDI\armsd\1.3.1\66\win_32-pentium\armsd.exe 
  %Install Path%\RDI\AXD\1.3.1\98\win_32-pentium\axd.exe 
  %Install Path%\RVCT\Programs\2.2\349\win_32-pentium\armasm.exe 
  %Install Path%\RVCT\Programs\2.2\349\win_32-pentium\armcc.exe 
  %Install Path%\RVCT\Programs\2.2\349\win_32-pentium\armcpp.exe 
  %Install Path%\RVCT\Programs\2.2\349\win_32-pentium\armlink.exe 
  %Install Path%\RVCT\Programs\2.2\349\win_32-pentium\fromelf.exe 
  %Install Path%\RVCT\Programs\2.2\349\win_32-pentium\tcc.exe 
  %Install Path%\RVCT\Programs\2.2\349\win_32-pentium\tcpp.exe 
  %Install Path%\RVD\Core\1.8\734\win_32-pentium\bin\tvs.exe 
  %Install Path%\RVD\Core\1.8\734\win_32-pentium\bin\xry100.dll 
  %Install Path%\RVARMulator\ARMulator\1.4.1\206\win_32-pentium\armiss.sdi 
  %Install Path%\RVARMulator\ARMulator\1.4.1\206\win_32-pentium\armulate.sdi 
  %Install Path%\RVARMulator\ARMulator\1.4.1\206\win_32-pentium\v6armiss.sdi 
  %Install Path%\RVARMulator\v6ARMulator\1.4.1\238\win_32-pentium\v6thumb2.sdi 
  %Install Path%\RVARMulator\v6ARMulator\1.4.1\238\win_32-pentium\v6trustzone.sdi
```

5. 由于CPU为ADM的，在安装过程中会出现很多出现很多Error: %variable HOSTPLAT is not defined in File RDI\armsd\1.3.1\66\install.xml
为了排除该错误只需要进行如下操作：把安装目录中的RDI/ARMSD/1.3.1/66下的INSTALL.XML与utilities/installer/1.6/43下的install.xml中的%（HOSTPLAT）%替换为%(FS)win_32-pentium%

6. 进入rvds2.2目录下运行setup安装，安装到达lincense验证页面时，选择C:/flexlm目录下的license.dat 继续安装
