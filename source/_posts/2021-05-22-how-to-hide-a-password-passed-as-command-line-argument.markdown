---
layout: post
title: "How to hide a password passed as command line argument?"
date: 2021-05-22 17:22:37 +0800
comments: true
categories: tools
---

有部分软件设计的时候没有考虑命令行参数之外传递密码的途径，无法用环境变量或配置传递密码；导致任何用户用ps一看都能看到，这是重大的安全隐患；

解决方法很tricky:

https://serverfault.com/questions/592744/how-to-hide-a-password-passed-as-command-line-argument

https://stackoverflow.com/questions/3830823/hiding-secret-from-command-line-parameter-on-unix

做软件设计的时候一定要考虑命令行传递密码的替代方案；
