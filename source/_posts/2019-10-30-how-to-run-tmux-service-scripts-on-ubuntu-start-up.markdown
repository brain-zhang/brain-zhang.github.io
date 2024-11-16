---
layout: post
title: "How to run tmux service scripts on ubuntu start up"
date: 2019-10-30 10:11:38 +0800
comments: true
categories: tools
---

是的，做了无数遍还是不长记性，昨天又在这上面踩坑了；在ubuntu上写的启动脚本不执行，仅仅是可执行权限和用户权限的问题，又浪费了一上午；

<!-- more -->

在unbuntu启动时自动做一些工作，最佳实践是：

#### 你想要执行一个服务

* 如果是比较老的ubuntu (version<=14.04LTS);

这个时候你需要利用ubuntu的[upstart机制](http://upstart.ubuntu.com/)

简单说来，就是将一个这样的脚本:

```
start on startup
task
exec /path/to/command
```

存为taskxxx.conf文件，放到/etc/init 目录下面(这将会在开机时用root用户权限启动)；

或者存为 ~/.config/upstart(这将会在开机时用当前用户权限启动)

* 如果你是比较现代的ubuntu (version>=16.04LTS)

你需要利用 [systemd](https://github.com/systemd/systemd) 服务，这个我们之前写文章科普过：

https://brain-zhang.github.io/blog/2016/08/22/how-to-write-standard-startup-script/


#### 仅仅想执行一条简单的命令

```
sudo nano /etc/rc.local
```

加入执行的命令，不要忘了最后加exit

```
/opt/tmux.sh
exit 0
```

增加可执行权限

```
sudo chmod +x /etc/rc.local
```


注意：

* 要有可执行权限，这个最容易踩坑，ubuntu安装完毕 /etc/rc.local 是没有可执行权限的
* 注意执行命令的ENV变量，不确定的时候要在命令签名设定SHELL ENV Variable
* 如果是执行一个脚本，注意脚本命令调用的shell (bash or sh or zsh)，以及ENV Variable
* 注意执行脚本、执行命令的用户


#### 如果是修改一个环境变量

修改当前用户:

```
nano ~/.bashrc
```

所有用户生效:

```
nano ~/etc/profile
```



#### 最后，附赠最简单粗暴的开机执行任务方式

就是在/etc/rc.local 里面启动一个tmux session，在里面执行想要运行的命令；简单粗暴有效

来个模板:

```
#!/bin/bash
# description "Start Tmux"

# Sleep for 5 seconds. If you are starting more than one tmux session
#   "at the same time", then make sure they all sleep for different periods
#   or you can experience problems
/bin/sleep 5
# Ensure the environment is available
source ~/.bashrc
# Create a new tmux session named newscrawler..
/usr/bin/tmux new-session -d -s bitcoin
# ...and control the tmux session (initially ensure the environment
#   is available, then run commands)

# /usr/bin/tmux send-keys -t bitcoincash:0 "source ~/.bashrc" C-m
tmux new-window -n console -t bitcoin
/bin/sleep 3
/usr/bin/tmux send-keys -t bitcoin:0 "cd /opt/bitcoin && ./startbitcoind.sh" C-m
/bin/sleep 3
/usr/bin/tmux send-keys -t bitcoin:1 "cd /opt/bitcoin && ./checkwallet start" C-m

```
