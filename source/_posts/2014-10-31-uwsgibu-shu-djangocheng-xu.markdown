---
layout: post
title: "uwsgi部署django程序"
date: 2014-10-31 08:39:26 +0800
comments: true
categories: develop Django
---

Python的web世界，部署首选uwsgi，既可独战，又可搭配Nginx等车轮战，实在是居家必备。

但我每次都得搞都得去翻一遍手册，实在烦了，记一下简单粗暴的测试方案。

##安装

    pip install uwsgi

##测试

写一个最简单的test.py:


```
# test.py
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return "Hello World"

```

python3的话需要返回一个binary


```
# test.py
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return [b"Hello World"]

```


执行shell命令:

    uwsgi --http :8000 --wsgi-file test.py

访问:

http://127.0.0.1:8000/

因该能看到`Hello World`了


##集成Django

    django-admin startproject testuwsgi

这样生成的项目，django版本不同，目录会有微小的差别，找manage.py就对了

如果是>django1.6的话，会自动生成wsgi.py文件，没有的话编辑一个:


```
#!/usr/bin/env python
# coding: utf-8

import os
import sys

# 将系统的编码设置为UTF8
reload(sys)
sys.setdefaultencoding('utf8')

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mysite.settings")

from django.core.handlers.wsgi import WSGIHandler
application = WSGIHandler()

```

执行:

    uwsgi --http :8000 --chdir xxxxx/testuwsgi --module testuwsgi.wsgi

访问:

http://127.0.0.1:8000/

因该能看到Django的欢迎页面了

##支持Https

uwsgi自1.3版本开始支持https

分两步走:

#### 生成证书

    openssl genrsa -out foobar.key 2048
    openssl req -new -key foobar.key -out foobar.csr
    openssl x509 -req -days 365 -in foobar.csr -signkey foobar.key -out foobar.crt

#### 走起

    uwsgi --master --https 0.0.0.0:8443,foobar.crt,foobar.key --chdir xxxxx/testuwsgi --module testuwsgi.wsgi

访问的时候要以:

https://127.0.0.1:8443/


OK了

至于怎么搭配Nginx，写配置文件，搭配Supervisor，还是老老实实翻手册吧，反正这个不是经常做。
