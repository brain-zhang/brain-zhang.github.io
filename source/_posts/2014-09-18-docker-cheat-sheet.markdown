---
layout: post
title: "Docker Cheat Sheet"
date: 2014-09-18 09:09:52 +0800
comments: true
categories: docker tools
---

# container相关


```
$ docker run -it xxx /bin/bash                                      // 启动一个container
$ docker rm -f xxx                                                  // 结束一个container，加-f表示删除掉，这样比较干净
$ docker run -it --add-host host:ip xxx /bin/bash                   // 启动一个container,增加/etc/hosts设定
$ docker run -d -p 127.0.0.1:5000:5000 webapp python app.py         // 启动一个container,映射本地的5000端口

```

# image 相关


```
$ docker rmi -f xxx                                                 // 删除一个image，以下情况下不能删除:
                                                                    // * 有其他image依赖于这个image
                                                                    // * 有已创建的container依赖于这个image
                                                                    // build的过程会出现很多<none>的临时image，最好不要去手工清除
$ docker build tag Dockerfile_dir                                   // build一个image

```

# docker service 相关

## 配置文件位置

* ubuntu: /etc/default/docker

* centos: /etc/sysconfig/docker

### 配置参数

    DOCKER_OPTS

#### 增加docker 仓库验证

    --insecure-registry own-docker.com

#### 设置storage backend

    -s overlay

使用overlay极大提升性能和稳定性，建议开启。但是有两个问题:

* 编译centos镜像时，调用yum会报checksum错误，所以基本上不能在overlay上面构建redhat系的镜像

* 不支持 `inotify_add_watch` 调用，`tail -f` 类的命令会有问题，具体见:https://github.com/docker/docker/issues/11705

# 相关工具:

#### docker镜像瘦身工具

https://github.com/jwilder/docker-squash

#### nsenter, docker inspect的增强版

https://github.com/jpetazzo/nsenter


#### dockerfly，自己写的一个构建工具

https://github.com/brain-zhang/dockerfly

####shipyard，还算是比较靠谱的监控工具

https://github.com/shipyard/shipyard



# 一些坑:

* centos 在4.0.0-1.el6.elrepo.x86_64内核下，启动xfs+overlay，删除文件夹会有问题
* overlay下，tail命令会有问题
* overlay下，docker build，yum的checksum会有问题
* devicemapper效率巨慢无比，不要用
