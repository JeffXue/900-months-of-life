---
title: tomcat6和tomcat7性能对比
tags:
  - tomcat
date: 2016-04-18 23:43:44
categories: 性能
---

# 静态页面
测试场景：逐步递增并发到500，访问index.html静态页面
测试结论：静态页面处理能力基本无差异

- | TPS | 90%响应时间（秒） | CPU
- | - | - | -
Tomcat6 | 1410 | 0.316 | 14.93%
Tomcat7 | 1416 | 0.314 | 17.91%


# 动态页面
测试场景：逐步递增并发到500，访问login页面
测试结论：Tomcat7处理动态页面性能比Tomcat6约提升8%，CPU使用率稍有下降

- | TPS | 90%响应时间（秒） | CPU
- | - | - | -
Tomcat6 | 638| 0.649 | 62.38%
Tomcat7 | 692| 0.602 | 57.71%
