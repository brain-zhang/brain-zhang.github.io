---
layout: post
title: "用Pyinstaller打包python脚本适配windows"
date: 2017-02-14 16:13:52 +0800
comments: true
categories: windows develop
---

一行命令的事，纯python脚本打包出来一般5Mb左右，大小还可以接收。

首先在脚本同目录下加入一个pyinstaller.py:

    #!/usr/bin/env python
    from PyInstaller.__main__ import run
    run()

然后执行:

    python pyinstaller.py -c -F <xxxx.py> -p <sdk>

* <xxxx.py> 为脚本名称
* <sdk> 为三方包目录

