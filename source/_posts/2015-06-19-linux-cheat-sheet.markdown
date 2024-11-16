---
layout: post
title: "linux cheat sheet"
date: 2015-06-19 01:43:07 +0000
comments: true
categories: tools
---

收集linux下需要多次google的命令

## 编码问题

* utf16 > utf8


```
iconv -f UTF-16 -t UTF-8 file_name

```

## web开发命令

* curl post 一个json文件


```
curl -H "Content-Type: application/json"--data @body.json http://localhost:8080/ui/webapp/conf

```

* curl post 一个json字符串


```
curl -H "Content-Type: application/json"-d '{"username":"xyz","password":"xyz"}' http://localhost:3000/api/login

```

## 系统时间

* centos6系列修改时区


```
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
vim /etc/sysconfig/clock
ZONE="Asia/Shanghai"

```

* centos7系列修改时区


```
timedatectl list-timezones | grep Asia
timedatectl set-timezone Asia/Shanghai

```

* 设置系统时间


```
date +"%Y%m%d%H%M%S"

```

## 系统状态

* 查看系统占用句柄数


```
lsof -n|awk '{print $2}'|sort|uniq -c|sort -nr|more

```

## 程序

* mongo导出


```
mongoexport  -u crossflow -p '0701!1523#SH' -authenticationDatabase admin -d bpc -c main_app_datapath -o main_app_datapath.json

```

## shell 处理

* 获取当前路径


```
export CURRENT_PATH=$(cd "$(dirname "$0")"; pwd)

```

* 检查CPU load


```
CURRENT_LOAD=`top -b -n 1|grep 'load average'|awk '{print $12}'|sed 's/,//'`
declare -i current_load=${CURRENT_LOAD%.*}

```

* find 匹配多个pattern


```
find /usr/lib64 -name '*.so' -o -name '*.so.1'

```

## 文本处理

* 根据某个字段做uniq


```
sort -u -t, -k1 file

```
