---
layout: post
title: "C:dynamic Array in Stack"
date: 2014-09-17 08:42:25 +0800
comments: true
categories: C Array
---
以前一直认为C99 只支持const int 定义数组，今天才学到C99里面是支持动态数组的。

```
int main()
{
    int x = 12;
    char pz[x];
}
```
C99是支持的。在gcc4+以上的版本里测试OK。

另外stackoverflow上提到C++不支持动态数组，在g++4.4.7里面试了一下，也是可以的。

不是我不明白，这世界变化快。

Out好多好多年了…….

参考:
http://stackoverflow.com/questions/1204521/dynamic-array-in-stack http://stackoverflow.com/questions/737240/c-c-array-size-at-run-time-w-o-dynamic-allocation-is-allowed
