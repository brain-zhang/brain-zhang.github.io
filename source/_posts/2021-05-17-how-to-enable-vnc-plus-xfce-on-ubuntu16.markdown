---
layout: post
title: "How to enable VNC+xfce on ubuntu16"
date: 2021-05-17 17:13:32 +0800
comments: true
categories: tools linux
---

#### 安装桌面环境和vncserver

```
sudo apt-get install xfce4 vnc4server
```

#### 启动vncserver

```
vncserver
```

#### 修改配置文件

```
vim ~/.vnc/xstartup


#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
```

#### 修改配置文件后，运行如下命令结束掉之前产生的窗口:1

```
vncserver -kill :1
```

#### 用vnc client连接后，tab键自动补全用不了，可以进行如下设置

settings -> window manager -> keyboard -> switch window for same application -> clear

