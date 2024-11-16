---
layout: post
title: "Unicode string parse with python and fileinput"
date: 2019-09-06 11:41:03 +0800
comments: true
categories: develop
---
用fileinput模块parse数据很方便:

```
import fileinput

if __name__ == '__main__':
    for line in fileinput.input():
        sys.stdout.write(line)

```

但有时候会碰到UnicodeDecodeError:

比如执行:

<!-- more -->

```
echo -e "foo\x80bar" |python3 testinput.py

...
UnicodeDecodeError: 'utf8' codec can't decode byte 0x80 in position 3: invalid start byte
```

这种错误还不好用`try .. catch`忽略掉，因为它是在fileinput模块中自己parse的；

Python2的时候很罗嗦，需要自己用codecs去判断之后，才能parse;

Python3总算是引入了一个openhook参数，可以自己hook处理了；

最简单的处理方式:

```
import fileinput
import io
import sys

if __name__ == '__main__':
    sys.stdin = io.TextIOWrapper(sys.stdin.buffer, errors='replace')
    for line in fileinput.input(openhook=fileinput.hook_encoded("utf-8")):
        sys.stdout.write(line)

```

参考:

https://stackoverflow.com/questions/24754861/unicode-file-with-python-and-fileinput

https://bugs.python.org/issue26756
