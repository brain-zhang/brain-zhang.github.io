---
layout: post
title: "如何配置Fail2Ban阻止Web频繁请求"
date: 2025-03-22 10:38:46 +0800
comments: true
categories: tools
---

这类问题，AI回答已经非常靠谱了；记录一下，仅仅是加强一下记忆；


### 1. 确认Nginx日志格式

#### 1.1 确保Nginx日志中包含客户端IP（$remote_addr），检查Nginx配置（通常位于/etc/nginx/nginx.conf）：

```
http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent"';
    access_log /var/log/nginx/access.log main;
}
```


#### 1.2 重启Nginx使配置生效：
```
sudosystemctl restart nginx
```

### 2. 安装Fail2Ban

```
# Ubuntu/Debian
sudo apt update && sudo apt install fail2ban

# CentOS/RHEL
sudo yum install epel-release && sudo yum install fail2ban
```


### 3. 创建自定义Filter规则

比如要监控 所有 `/hello` url下的请求；

新建文件 /etc/fail2ban/filter.d/nginx-url-bruteforce.conf：
```
[Definition]failregex=^<HOST> -.*"(GET|POST) /hello/[a-fA-F0-9]{64} HTTP/.*".*ignoreregex=
```


### 4. 配置Jail规则
编辑 /etc/fail2ban/jail.local，添加以下内容：
```
[nginx-url-bruteforce]
enabled = true
port = http,https
filter = nginx-url-bruteforce
logpath = /var/log/nginx/access.log
 # 允许的最大尝试次数
maxretry = 5
# 在60秒内超过maxretry则封禁
findtime = 60
# 封禁1小时
bantime = 3600
action = %(action_mwl)s
```

### 5. 测试Filter规则
使用 fail2ban-regex 测试正则匹配：
```
sudo fail2ban-regex /var/log/nginx/access.log /etc/fail2ban/filter.d/nginx-url-bruteforce.conf
```

### 6. 重启Fail2Ban并监控
```
sudo systemctl restart fail2ban
sudo fail2ban-client status nginx-url-bruteforce
```


### 7. 高级调整（可选）

* 日志路径：如果日志路径不同，修改 logpath。

* 封禁时间：调整 bantime（单位：秒，如 86400 封禁1天）。

* 精确匹配状态码：如需仅封禁500错误，修改 failregex：

