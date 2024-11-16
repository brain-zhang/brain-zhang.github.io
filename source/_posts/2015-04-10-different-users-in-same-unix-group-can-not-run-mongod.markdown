---
layout: post
title: "Different users in same unix group can not run mongod"
date: 2015-04-10 08:44:42 +0800
comments: true
categories: docker mongodb tools
---

事情的缘起是这样的.......

想要在Dockerfile中启动一个MongoDB，之后编译为Docker image。(不要问我问什么要在docker image中存一个mongodb数据库，真实世界的需求你永远想不到)

Docker build不支持 --privileged，所以默认的/etc/init.d/mongod  这个脚本中的


```
runuser -s /bin/bash mongod -c 'ulimit -S -c 0 >/dev/null 2>&1 ; numactl --interleave=all /usr/bin/mongod -f /etc/mongod.conf'

```

这种写法就死翘翘了。

github上有这个Issue:

https://github.com/docker/docker/issues/1916

大家讨论了1年多，对于怎么解决，还是没有个所以然。(话说要再吐槽一下github的issue了，一般大一点的项目，一个issue跨度以年来论，长篇大论读完也不容易呀)

最后只好在Dockerfile中这么搞:


```
    mongod --fork -f /etc/mongod.conf && \
    mongod --shutdown -f /etc/mongod.conf && \
    chown mongod:mongod /opt/lib/mongodbpath -R


```

这样build就顺利完成了。

可是启动这个image为container后，执行:


```
/etc/init.d/mongod start

```

报错:


```
 [initandlisten] warning couldn't write to / rename file /datadir/journal/prealloc.0: couldn't open file /datadir/journal/prealloc.0 for writing errno:1 Operation not permitted

```

虾米，明明已经加了mongod的group了。而且errorno是1，不是 `"errno:13 Permission denied"`，有点奇怪。

问题在这里:

https://jira.mongodb.org/browse/SERVER-7583


要再加一个指令:


```
setcap cap_fowner+ep /usr/bin/mongod

```


就是这么折腾。
