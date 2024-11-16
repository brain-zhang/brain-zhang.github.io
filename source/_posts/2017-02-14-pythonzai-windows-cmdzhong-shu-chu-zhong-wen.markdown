---
layout: post
title: "Python在windows CMD中输出中文"
date: 2017-02-14 16:06:12 +0800
comments: true
categories: develop
---

在windows CMD中输出中文是比较烦的事情，最简单的就是增加一个windows.py，用的时候import一下:

    #!/usr/bin/env python
    #  -*- coding: utf-8 -*-
    import sys

    class UnicodeStreamFilter:
        def __init__(self, target):
            self.target = target
            self.encoding = 'utf-8'
            self.errors = 'replace'
            self.encode_to = self.target.encoding
        def write(self, s):
            if type(s) == str:
                s = s.decode("utf-8")
            s = s.encode(self.encode_to, self.errors).decode(self.encode_to)
            self.target.write(s)

    if sys.stdout.encoding == 'cp936':
        sys.stdout = UnicodeStreamFilter(sys.stdout)
