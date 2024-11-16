---
layout: post
title: "mysql cheat"
date: 2016-07-05 08:23:00 +0800
comments: true
categories: mysql tools
---

整理一下经常忘记的mysql命令

# 连接


```
$ mysql -u root -p

```

# list

```
$ show DATABASES;
$ show TABLES;

```

# Error

* ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)


```
$ mysqld --skip-grant-tables
$ mysql -u root mysql
$ mysql> UPDATE user SET Password=PASSWORD('my_password') where USER='root';
$ mysql> FLUSH PRIVILEGES;

```
