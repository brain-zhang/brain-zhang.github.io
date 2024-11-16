---
layout: post
title: "FRP内网穿透"
date: 2019-11-11 10:45:34 +0800
comments: true
categories: tools
---

对于没有公网 IP 的内网用户来说，远程管理或在外网访问内网机器上的服务是一个问题。之前一直用最简单的nc做反代，折腾了几次之后迁移到FRP上面了；记录一下ABC;

<!-- more -->

内网穿透工具 FRP，FRP 全名：Fast Reverse Proxy。

项目地址: https://github.com/fatedier/frp

#### FRP 的作用

* 利用处于内网或防火墙后的机器，对外网环境提供 HTTP 或 HTTPS 服务。

* 对于 HTTP, HTTPS 服务支持基于域名的虚拟主机，支持自定义域名绑定，使多个域名可以共用一个 80 端口。

* 利用处于内网或防火墙后的机器，对外网环境提供 TCP 和 UDP 服务，例如在家里通过 SSH 访问处于公司内网环境内的主机。

#### FRP 安装
FRP 采用 Go 语言开发，支持 Windows、Linux、MacOS、ARM等多平台部署。FRP 安装非常容易，只需下载对应系统平台的软件包，并解压就可用。

这里以 Linux 为例，为了方便管理我们把解压后的目录重命名为 frp ：

```
 wget https://github.com/fatedier/frp/releases/download/v0.29.1/frp_0.29.1_linux_amd64.tar.gz
 tar xzvf frp_0.29.1_linux_amd64.tar.gz
 mv frp_0.29.1_linux_amd64 frp
 cp frp/frpc frp/frps /usr/bin/
```


#### FRP服务端配置


* 首先建立配置文件

```
mkdir /etc/frp
vim /etc/frp/frps.ini
```

下面是模板，根据修改一下token，dashboard_user, dashboard_pwd，默认开了6000端口作为对外ssh端口， 7000作为frpc和frps通讯端口，7500端口作为web管理界面端口；

```
# [common] is integral section
[common]
# A literal address or host name for IPv6 must be enclosed
# in square brackets, as in "[::1]:80", "[ipv6-host]:http" or "[ipv6-host%zone]:80"
bind_addr = 0.0.0.0
bind_port = 7000

# udp port to help make udp hole to penetrate nat
bind_udp_port = 7001

# udp port used for kcp protocol, it can be same with 'bind_port'
# if not set, kcp is disabled in frps
kcp_bind_port = 7000

# specify which address proxy will listen for, default value is same with bind_addr
# proxy_bind_addr = 127.0.0.1

# if you want to support virtual host, you must set the http port for listening (optional)
# Note: http port and https port can be same with bind_port
vhost_http_port = 80
vhost_https_port = 443

# response header timeout(seconds) for vhost http server, default is 60s
# vhost_http_timeout = 60

# set dashboard_addr and dashboard_port to view dashboard of frps
# dashboard_addr's default value is same with bind_addr
# dashboard is available only if dashboard_port is set
dashboard_addr = 0.0.0.0
dashboard_port = 7500

# dashboard user and passwd for basic auth protect, if not set, both default value is admin
dashboard_user = user
dashboard_pwd = user

# dashboard assets directory(only for debug mode)
# assets_dir = ./static
# console or real logFile path like ./frps.log
log_file = /var/log/frps.log

# trace, debug, info, warn, error
log_level = info

log_max_days = 3

# disable log colors when log_file is console, default is false
disable_log_color = false

# auth token
token = 123456frp

# heartbeat configure, it's not recommended to modify the default value
# the default value of heartbeat_timeout is 90
# heartbeat_timeout = 90

# only allow frpc to bind ports you list, if you set nothing, there won't be any limit
#allow_ports = 2000-3000,3001,3003,4000-50000
allow_ports = 80,6000,8080,18332,18333,28332,28333,60000-60010

# pool_count in each proxy will change to max_pool_count if they exceed the maximum value
max_pool_count = 5

# if subdomain_host is not empty, you can set subdomain when type is http or https in frpc's configure file
# when subdomain is test, the host used by routing is test.frps.com
subdomain_host = frps.com

# if tcp stream multiplexing is used, default is true
tcp_mux = true

# custom 404 page for HTTP requests
# custom_404_page = /path/to/404.html

```

* 再建立systemd 启动脚本

```
vim /lib/systemd/system/frps.service

[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/frps -c /etc/frp/frps.ini

[Install]
WantedBy=multi-user.target
```

* 启动服务，再设置为开机启动

```
systemctl start frps
systemctl enable frps
```

#### FRP客户端配置

* 首先建立配置文件

```
mkdir /etc/frp
vim /etc/frp/frpc.ini
```

下面是模板，根据修改server_addr、admin_user, admin_pwd字段; token要设置的跟服务端的token相同；



```
# [common] is integral section
[common]
# A literal address or host name for IPv6 must be enclosed
# in square brackets, as in "[::1]:80", "[ipv6-host]:http" or "[ipv6-host%zone]:80"
server_addr = x.x.x.x
server_port = 7000

# if you want to connect frps by http proxy or socks5 proxy, you can set http_proxy here or in global environment variables
# it only works when protocol is tcp
# http_proxy = http://user:passwd@192.168.1.128:8080
# http_proxy = socks5://user:passwd@192.168.1.128:1080

# console or real logFile path like ./frpc.log
log_file = /var/log/frpc.log

# trace, debug, info, warn, error
log_level = info

log_max_days = 3

# disable log colors when log_file is console, default is false
disable_log_color = false

# for authentication
token = 123456frp

# set admin address for control frpc's action by http api such as reload
admin_addr = 127.0.0.1
admin_port = 7400
admin_user = user
admin_pwd = user
# Admin assets directory. By default, these assets are bundled with frpc.
# assets_dir = ./static

# connections will be established in advance, default value is zero
pool_count = 5

# if tcp stream multiplexing is used, default is true, it must be same with frps
tcp_mux = true

# your proxy name will be changed to {user}.{proxy}
user = brainzhang.bitcoin.testnet

# decide if exit program when first login failed, otherwise continuous relogin to frps
# default is true
login_fail_exit = true

# communication protocol used to connect to server
# now it supports tcp and kcp and websocket, default is tcp
protocol = tcp

# if tls_enable is true, frpc will connect frps by tls
tls_enable = true

# specify a dns server, so frpc will use this instead of default one
# dns_server = 8.8.8.8

# proxy names you want to start seperated by ','
# default is empty, means all proxies
# start = ssh,dns

# heartbeat configure, it's not recommended to modify the default value
# the default value of heartbeat_interval is 10 and heartbeat_timeout is 90
# heartbeat_interval = 30
# heartbeat_timeout = 90

# 'ssh' is the unique proxy name
# if user in [common] section is not empty, it will be changed to {user}.{proxy} such as 'your_name.ssh'
[ssh]
# tcp | udp | http | https | stcp | xtcp, default is tcp
type = tcp
local_ip = 127.0.0.1
local_port = 22
# true or false, if true, messages between frps and frpc will be encrypted, default is false
use_encryption = false
# if true, message will be compressed
use_compression = true
# remote port listen by frps
remote_port = 6000
# frps will load balancing connections for proxies in same group
#group = test_group
## group should have same group key
#group_key = 123456
## enable health check for the backend service, it support 'tcp' and 'http' now
## frpc will connect local service's port to detect it's healthy status
#health_check_type = tcp
## health check connection timeout
#health_check_timeout_s = 3
## if continuous failed in 3 times, the proxy will be removed from frps
#health_check_max_failed = 3
## every 10 seconds will do a health check
#health_check_interval_s = 10

#[ssh_random]
#type = tcp
#local_ip = 127.0.0.1
#local_port = 22
## if remote_port is 0, frps will assign a random port for you
#remote_port = 0

# if you want to expose multiple ports, add 'range:' prefix to the section name
# frpc will generate multiple proxies such as 'tcp_port_6010', 'tcp_port_6011' and so on.
[range:tcp_port]
type = tcp
local_ip = 127.0.0.1
#local_port = 6010-6020,6022,6024-6028,
#remote_port = 6010-6020,6022,6024-6028
local_port = 8080,18332,18333,28332,28333,60000-60010
remote_port = 8080,18332,18333,28332,28333,60000-60010
use_encryption = false
use_compression = false


```

* 再建立systemd 启动脚本

```
vim /lib/systemd/system/frpc.service

[Unit]
Description=Frp Client Service
After=network.target

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/frpc -c /etc/frp/frpc.ini
ExecReload=/usr/bin/frpc reload -c /etc/frp/frpc.ini

[Install]
WantedBy=multi-user.target

```

* 启动服务，再设置为开机启动

```
systemctl start frpc
systemctl enable frpc
```


#### 测试

现在可以从外网通过 frps服务端的ip(比如x.x.x.x)中转，访问内网了；比如ssh:

```
ssh -oPort=6000 root@x.x.x.x
```

也可以直接用一条scp命令直接通过跳板机拷贝文件到内网机器

```
scp -P 6000 -r xxx root@xxxxxxx:/opt/
```

同样的，如果内网开通了某些服务，比如我们的配置模板里面已经映射出了8080,18332,18333,28332,28333,60000-60010这些端口，这些端口同样的映射到服务端了；

比如，我们在内网运行一个简单的web服务:

```
python -m SimpleHTTPServer 8080
```

可以通过frps服务端的ip(比如x.x.x.x)访问这个服务：

```
curl http://x.x.x.x:8080
```

我们也可以在内网运行一个bitcoin全节点+lnd，然后关闭不必要的服务，再运行一个轻量的vps，在vps上部署Tor服务，这样我们就可以通过多重跳板把闪电网络热钱包隐藏到Tor网络里面了，保证了安全性；

#### 管理

可以通过下面的地址进入web管理界面，用户名和密码就是frps.ini中配置的dashboard_user、dashboard_pwd；

http://x.x.x.x:7500


#### 扩展

FRP还有非常多的功能，比如虚拟主机、多路复用、负载均衡、点对点内网穿透等等，请参考官方文档：

https://github.com/fatedier/frp/blob/master/README_zh.md
