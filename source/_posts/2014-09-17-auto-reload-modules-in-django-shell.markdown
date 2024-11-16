---
layout: post
title: "Auto Reload Modules in Django Shell"
date: 2014-09-17 08:36:01 +0800
comments: true
categories: django develop
---
`python manage.py shell`

太常用了，但是每次修改模块代码后，总要 exit—>reset 才能重新load一遍代码，实在是不爽。

也曾经改造ipython，想要代码修改后实时载入，各种坑，最后各种懒之下还是老老实实reload。

最近发现一个扩展，django-externsions:

https://github.com/django-extensions/django-extensions

装上好用不少，貌似还比较靠谱，推荐之。
