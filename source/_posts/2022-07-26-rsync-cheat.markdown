---
layout: post
title: "rsync Cheat"
date: 2022-07-26 15:35:51 +0800
comments: true
categories: tools
---

这条命令我用了不下百次了，但是每次还得查，老年痴呆的前兆，/(ㄒoㄒ)/~~

```
rsync -acvruP --progress /opt/src1 /opt/src2  /mnt/dest/
```

* -c, --checksum 打开校验开关，强制对文件传输进行校验; 开了前置计算会很慢，文件多的时候不要用
* -a, --archive 归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD
* -r, --recursive 对子目录以递归模式处理
* -u, --update 仅仅进行更新，也就是跳过所有已经存在于DST，并且文件时间晚于要备份的文件。(不覆盖更新的文件)；已经有拷贝了一半的文件的情况下不要用，不会自动更新

最后，要注意路径中的斜杠处理:

```
rsync -acvruP --progress /opt/src1 /mnt/dest/
```

与下面的命令是不一样的

```
rsync -acvruP --progress /opt/src1/ /mnt/dest/
```

前者会拷贝src1目录，后者会拷贝src1目录下的文件，但是不会带src1
