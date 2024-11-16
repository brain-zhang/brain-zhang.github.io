---
layout: post
title: "how to xargs separate parameters"
date: 2015-05-06 08:06:52 +0800
comments: true
categories: shell
---

做过很多遍了，每次还是得现查，记一下:

    echo "'param 1' 'param 2'" | xargs -n1 | xargs -I@ echo \[@\] \[@\]

output:


```
[param 1] [param 1]
[param 2] [param 2]

```

## xargs里面替换字符串

    ls|xargs -I @  echo "mv @ @.pack"|sed 's/.json.pack.pack/.pack/g'|bash


