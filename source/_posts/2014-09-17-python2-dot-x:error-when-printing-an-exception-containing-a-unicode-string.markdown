---
layout: post
title: "python2.x：Error When Printing an Exception Containing a Unicode String"
date: 2014-09-17 08:43:39 +0800
comments: true
categories: Python Unicode
---
Python2.x中抛出Unicode的异常需要注意:

```
>>> try:
...     raise Exception(u'Error when printing 中文异常')
... except Exception, e:
...     print e
...     print str(e)
```
会报UnicodeEncodeError: 'ascii' codec can't encode character ...

同样，如果在log中直接输出，也会报错

```
>>> import logging
    logger = logging.getLogger('default')
    try:
...     raise Exception(u'Error when printing 中文异常')
... except Exception, e:
...     logger.error(e)
...     logger.error("%s", e)
...     logger.error("%s", str(e))
```

简单的解决办法就是用e.message

```
>>> try:
...     raise Exception(u'Error when printing 中文异常')
... except Exception, e:
...     print e.message
...     print "%s" % e.message
```

也可以详细的可以指定encoder

```
>>> try:
...     raise Exception(u'Error when printing 中文异常')
... except Exception, e:
...     print unicode(e.message).encode('utf-8')
```

Python3就没这个事了，备忘一下。

参考:

http://bugs.python.org/issue2517
