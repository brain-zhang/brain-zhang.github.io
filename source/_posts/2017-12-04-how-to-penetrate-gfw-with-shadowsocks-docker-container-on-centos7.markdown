---
layout: post
title: "How to Penetrate GFW With ShadowSocks  Docker Container On Centos7"
date: 2017-12-04 20:23:40 +0800
comments: true
categories: GFW tools
---

The quickest way to Penetrate GFW With ShadowSocks(Docker Container) On Centos7.

## Install Docker CE


```
$ sudo yum install -y yum-utils   device-mapper-persistent-data  lvm2
$ sudo yum-config-manager    --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
$ sudo yum install docker-ce

```

## start  docker


```
sudo systemctl start docker

```

## pull shadowsocks container

```
sudo docker pull oddrationale/docker-shadowsocks

```

## start shadowsocks service

```
sudo docker run -d -p 1984:1984 oddrationale/docker-shadowsocks -s 0.0.0.0 -p 1984 -k $SSPASSWORD -m aes-256-cfb

```

You can configure the service to run on a port of your choice. Just make sure the port number given to Docker is the same as the one given to shadowsocks. Also, it is highly recommended that you store the shadowsocks password in an environment variable as shown above. This way the password will not show in plain text when you run docker ps.

For more command line options, refer to the [shadowsocks documentation](https://github.com/shadowsocks/shadowsocks/tree/master)

## windows Client

Client is the machine you want to bypass the GFW.

Download the client package [Shadowsocks-win-latest-release](https://github.com/shadowsocks/shadowsocks-windows/releases), extract it, and run.

You can check its “System Proxy” option, which is convenient for all browsers and terminal.

## now enjoy it
