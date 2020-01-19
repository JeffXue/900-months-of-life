---
title: Git分支管理实践
tags:
  - Git
date: 2017-06-17 17:23:03
categories: 软件工程
---

# Git分支管理实践

Git分支管理的引入其实在团队逐步扩大，开发特性逐步增多的情况下引入时，其优势才会突显，否则将会带来为谓管理开销。



# 不同的Git分支管理

---

##  Master单分支

当团队较小时，往往只需要单独的master分支，大家都在本地master分支上进行特性开发，完成后即可推送到远程分支，推送后触发CI构建，单元测试，集成测试等，通过后即可上线发布。


此时的迭代周期应该较短，发布频率会比较高，上线后发现的问题可以快速的通过新版本迭代进行修复，生产环境的bug fix和新功能可以同步进行。

![master](http://www.jeffxue.cn/img/20170617_git-master.png)


但是随着业务的逐步扩张，业务复杂度开始增加，上线后出现的问题较多，同时迭代周期逐步被拉长的时候，就无法快速响应生产环境的bug fix。而实际情况下我们团队采用了局部包的方式为生产环境打补丁，但是在bug验证的过程中无法保证验证环境与生产环境一致，会引入一定的风险。

---

<!-- more -->

## Develop + Master

后续引入了develop分支作为开发分支，master分支用于发布和生产环境的bug fix。

![develop+master](http://www.jeffxue.cn/img/20170617_git-develop.png)

此时可以在开发新功能的同时对生产环境的bug进行修复发布

但是随着新需求的逐步增多，在临近发布日期的情况下，部分需求会存在无法完全交付的情况，但是部分代码已经提交到了develop上（我们会有部分提测的情况），导致发布时develop上到带有不可控的代码，存在隐形风险。在前期我们采取了入口屏蔽，代码抽取/代码回滚的方式去解决，但是当代码耦合度较高的时候，仍存在较大的风险，因此开始了gitflow的引入


---

## GitFlow

gitflow的流程是比较复杂的，会引入了release发布分支和hotfix的分支，而想完整的执行该模式对每位开发人员的要求也是较高的，需要对gitflow有明确的理解，还需要有较强的git实践能力。



实际执行gitflow的情况下，我们会遇到以下的问题：

- 仓库数量非常多（十几个），hotfixes步骤多，合并频繁，人的要求十分高

- release的过程中，生产bug fix如何解决？

- 会存在超长生命周期的分支，如何管理？



最后根据实际情况对gitflow进行了以下改造:

- 非release过程，生产环境bug fix直接基于master进行修复

- 拉出release分支之前，需要将master merge到develop，以便带上生产环境的bug fix

- 拉出release分支后，生产环境bug fix可以直接基于relese进行修复

- 在发布后，需要将develop合并到长生命周期的分支


并且对每个关键步骤进行了详细说明：

![tps](http://www.jeffxue.cn/img/20170617_gitflow.jpeg)



另外除了git flow流程外还有github flow，gitlab flow，详细可见[git-workflow](http://www.ruanyifeng.com/blog/2015/12/git-workflow.html)



---

参考：

http://nvie.com/posts/a-successful-git-branching-model/
http://blog.jobbole.com/109466/
http://www.ruanyifeng.com/blog/2012/07/git.html
http://www.ruanyifeng.com/blog/2015/12/git-workflow.html
