---
layout: post
title: "crontab eight comm"
date: 2015-08-07 10:11:11 +0000
comments: true
categories: crontab linux tools
---

网上收集，多次踩坑，立此存照

## crontab八诫

* 不要假定cron知道所需要的特殊环境，它其实并不知道。所以你要保证在shelll脚本中提供所有必要的路径和环境变量，除了一些自动设置的全局变量。所以注意如下2点：

    * 脚本中涉及文件路径时写全局路径；
    * 脚本执行要用到java或其他环境变量时，通过source命令引入环境变量，如：

            #!/bin/sh
            source /etc/profile
            export RUN_CONF=/home/xxxx/boss.conf
            /usr/local/jboss-4.0.5/bin/run.sh -c mev &

* 当手动执行脚本OK，但是crontab死活不执行时。这时必须大胆怀疑是环境变量惹的祸，并可以尝试在crontab中直接引入环境变量解决问题。如：

        0 * * * * . /etc/profile;/bin/sh /var/www/java/audit_no_count/bin/restart_audit.sh

* 新创建的cron job，不会马上执行，至少要过2分钟才执行。如果重启cron则马上执行。

* 每条 JOB 执行完毕之后，系统会自动将输出发送邮件给当前系统用户。日积月累，非常的多，甚至会撑爆整个系统。所以每条 JOB 命令后面进行重定向处理是非常必要的: `>/dev/null 2>&1`, 前提是对 Job 中的命令需要正常输出已经作了一定的处理, 比如追加到某个特定日志文件。

* 当crontab突然失效时，可以尝试`/etc/init.d/crond restart`解决问题。或者查看日志看某个job有没有执行/报错 `tail -f /var/log/cron`。

* 千万别乱运行 `crontab -r`。它从Crontab目录（/var/spool/cron）中删除用户的Crontab文件。删除了该用户的所有crontab都没了。

* 在crontab中%是有特殊含义的，表示换行的意思。如果要用的话必须进行转义 `\%`，如经常用的`date '+%Y%m%d'`在crontab里是不会执行的，应该换成 `date '+\%Y\%m\%d'`。

* 永远要手工验证一下crontab中的命令
