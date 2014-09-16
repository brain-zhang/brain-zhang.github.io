---
layout: post
title: "freeze svn:externals for tags/branch"
date: 2014-03-26 10:12:23 +0000
comments: true
categories: svn branch tag externals freeze
---

svn的external link在多个项目互相引用时很有用。

但我们想要做tag及branch的时候，需要将external link的文件或目录固定在某个版本。


## 搜了一下，基本上有几个办法:

使用tortoisesvn>1.7版本，打tag及branch的时候可以固定在某一版本:

    ¦   http://tortoisesvn.net/docs/release/TortoiseSVN_en/tsvn-dug-branchtag.html


    缺点是这样打出来的branch，checkout下来后，svn up还是回到最新的版本。

使用一个perl脚本，可以在打branch的时候把extern link一起拷贝到branch底下，这样相当于是建立了一个新的external link拷贝，修改branch不会影响到trunk

    ¦   https://svn.apache.org/repos/asf/subversion/trunk/contrib/client-side/svncopy/


    缺点是这样打出来的branch底下会多出来external link的拷贝，不完美。


有人开发了工具, C#的，但我在win7下面打branch的时候会报错

    ¦   http://svnxf.codeplex.com/



#### 原先以为这样的事情总该有个simple的解决办法的，但还真是没找到，自己实际写个脚本想做这个事情才发现不简单。想要做这件事的前提是要把代码check到本地来，这样就不如直接调命令了，如果远程操作svn库，就需要三方开发。



## 最后简单的办法是:


如果是打tag，采用方法一，用tortoisesvn固定在一个版本

如果是打branch，先用tortoisesvn 固定在一个版本，再把branch分支checkout下来，用命令 `svn propedit svn:externals .`取消external link，再重新加入版本库，最后提交。


参考:

http://stackoverflow.com/questions/1982538/how-to-have-tortoisesvn-always-freeze-svnexternals-for-tags
