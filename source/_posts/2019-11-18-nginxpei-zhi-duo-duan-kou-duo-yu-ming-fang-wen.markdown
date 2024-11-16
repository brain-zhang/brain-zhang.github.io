---
layout: post
title: "nginx配置多端口多域名访问"
date: 2019-11-18 15:52:07 +0800
comments: true
categories: network
---

在一个服务器上部署多个站点，需要开放多个端口来访问不同的站点，流程很简单，调试花了2小时，记录一下：

<!-- more -->

## 主域名多端口访问

#### 在DNS NameServer设置A记录

将 www.xxx.com 指向服务器ip

#### 开放所需端口，修改nginx配置文件

比如我们有两个服务分别开放在80端口和8080端口

如果有iptable，先开放端口：

```
iptables -A INPUT -ptcp --dport 80 -j ACCEPT
iptables -A INPUT -ptcp --dport 8080 -j ACCEPT
```

修改配置文件:

```
#path: /usr/local/nginx/conf/nginx.conf

server {
listen 80;
server_name www.xxx.com;
access_log /data/www/log/33.33.33.33_nginx.log combined;
index index.html index.htm index.php;
include /usr/local/nginx/conf/rewrite/none.conf;
root /data/www/website/33.33.33.33:80;


location ~ [^/]\.php(/|$) {
    fastcgi_pass unix:/dev/shm/php-cgi.sock;
    fastcgi_index index.php;
    include fastcgi.conf;
    }
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
    expires 30d;
    access_log off;
    }
location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
    }
}
server {
listen 8080;
server_name A.xxx.com;
access_log /data/www/log/33.33.33.33:8080_nginx.log combined;
index index.html index.htm index.php;
include /usr/local/nginx/conf/rewrite/none.conf;
root /data/www/website/33.33.33.33:8080;


location ~ [^/]\.php(/|$) {
    fastcgi_pass unix:/dev/shm/php-cgi.sock;
    fastcgi_index index.php;
    include fastcgi.conf;
    }
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
    expires 30d;
    access_log off;
    }
location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
    }
}
```


关键就是两个`server`段配置，你也可以把这两段拆成两个配置文件，放到

```
/etc/nginx/conf.d/
```

目录下面；


## 子域名多端口访问

这种访问比较傻，因为你的8080端口的访问需要 http://xxx.com:8080 这样的格式；

而且如果有两个不同的cgi，比如80端口对应一个php web服务， 8080端口对应一个nodejs web服务；而我们的nodejs自带web服务，已经在8080端口监听了，这怎么办？

这个时候我们需要Nginx的反向代理功能，并在DNS Server上面增加一条A记录，最终实现

* www.xxx.com 访问80端口
* A.xxx.com 通过nginx转发访问8080端口服务

##### 增加一条A记录

将 A.xxx.com 指向服务器ip

##### Nginx配置模板如下：

```
#path: /usr/local/nginx/conf/nginx.conf

server {
    listen 80;
    server_name www.xxx.com;
    access_log /data/www/log/33.33.33.33_nginx.log combined;
    index index.html index.htm index.php;
    include /usr/local/nginx/conf/rewrite/none.conf;
    root /data/www/website/33.33.33.33:80;


    location ~ [^/]\.php(/|$) {
        fastcgi_pass unix:/dev/shm/php-cgi.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
        }
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
        expires 30d;
        access_log off;
        }
    location ~ .*\.(js|css)?$ {
        expires 7d;
        access_log off;
        }
}

server {
    listen 80;
    listen [::]:80;

    server_name A.XXX.com;

    proxy_connect_timeout  300s;
    proxy_send_timeout  300s;
    proxy_read_timeout  300s;
    fastcgi_send_timeout 300s;
    fastcgi_read_timeout 300s;

    location / {
        proxy_pass    http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        try_files $uri $uri/ =404;
    }
}

```

#### nginx重新载入配置文件

```
nginx -s reload
```
