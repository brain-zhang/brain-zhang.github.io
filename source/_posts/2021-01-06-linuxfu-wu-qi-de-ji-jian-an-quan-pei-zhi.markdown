---
layout: post
title: "linux服务器极简安全配置"
date: 2021-01-06 17:33:38 +0800
comments: true
categories: tools
---

网络知识了解的越多，就越胆小；也许，这就是江湖吧；

当配置一台新的Linux服务器并上线时，其实就是将Server暴露到了炮火横飞的战场上，任何的大意都会让其万劫不复；但由于永恒的人性的弱点，我们总是在安全和便利之间摇摆；

本文希望能提供一种最简单的办法，帮助我们抵抗大多数的炮火；

<!-- more -->


#### 用户管理

最重要的就是不要用root用户操作，当一台服务器部署初期，为不同用途划分不同用户组以及用户能避免绝大多数悲剧；

1. 增加一个用户组 `develop`

    ```
    groupadd develop
    ```

2. 增加一个用户`brain`，设置密码，并把他加入到组 `develop`

    ```
    useradd -d /home/brain -s /bin/bash -m brain
    ```

    ```
    passwd brain
    ```

    ```
    usermod -a -G develop brain
    ```

3. 允许用户登录

    ```
    vim /etc/sudoers
    ```

    找到类似下面的一行，并在后面增加一行

    ```
    root     ALL=(ALL:ALL) ALL
    ```

    ```
    brain    ALL=(ALL) NOPASSWD: ALL
    ```

    上面的NOPASSWD表示，切换sudo的时候，不需要输入密码，这样比较省事。如果出于安全考虑，也可以强制要求输入密码。

    ```
    root    ALL=(ALL:ALL) ALL
    ```

    ```
    brain    ALL=(ALL:ALL) ALL
    ```

    然后，切换到新用户的身份，检查到这一步为止，是否一切正常。

    ```
    su brain
    ```


#### 防火墙

防火墙为我们抵抗绝大多数的脚本小子的攻击，是最省力，性价比最高的配置，切勿偷懒;

几乎所有的公有云都提供了非常傻瓜化的web 操作界面，来设置防火墙规则，一般情况下这些设置足够了；

设置第一原则是：只开放必要的端口

如果是自己设置防火墙，iptable的使用比较复杂，我们采用最简单的规则链:

待整理......

#### sshd配置

几条最简单的配置，即能避免90%以上的恶意嗅探；

1. 修改默认端口

    ```
    vim /etc/ssh/sshd_config
    ```

    找到默认的22端口

    ```
    Port 22
    ```

    修改为

    ```
    Port 12222
    ```

2. DNS

    ```
    UseDNS no
    ```
    提升ssh连接速度


3. Key

    首先，确定有SSH公钥（一般是文件~/.ssh/id_rsa.pub），如果没有的话，使用ssh-keygen命令生成一个

    ```
    echo "ssh-rsa [your public key]" > ~/.ssh/authorized_keys
    ```

    ```
    sudo chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh/
    ```

    修改/etc/ssh/sshd_config


    ```
    PermitRootLogin no
    ```

    ```
    PermitEmptyPasswords no
    ```

    ```
    PasswordAuthentication no
    ```

    ```
    RSAAuthentication yes
    ```

    ```
    PubkeyAuthentication yes
    ```

    ```
    AuthorizedKeysFile .ssh/authorized_keys
    ```

4. 重新启动sshd服务让配置生效

    ```
    systemctl restart sshd
    ```

5. 验证

    注意，此时不要退出终端；而是另开一个终端，验证配置无误，可以正常登陆后再关闭老终端；

    如果出现什么问题无法登录，而之前的终端窗口又关闭了，如果是远程机房，那就有得麻烦了。所以一切验证无误后再收工，是个好习惯。


#### Fail2Ban

警惕那些不怀好意的撞库者，用Fail2Ban 将尝试暴力破解的脚本小子自动封禁

* 安装

    centos:
    ```
    yum -y install epel-release
    ```

    ```
    sudo yum install fail2ban
    ```

    ubuntu:
    ```
    sudo apt-get install fail2ban
    ```



* 编辑规则文件

```
    vim /etc/fail2ban/jail.local
    [DEFAULT]
    ignoreip = 127.0.0.1/8
    bantime  = 86400
    maxretry = 5
    findtime = 1800
    destemail = xxxx@xxx.com
    sender = xxxx@gmail.com
    mta = mail
    protocol = tcp
    banaction = firewallcmd-ipset
    action = %(action_mwl)s

    [sshd]
    enabled = true
    filter  = sshd
    port    = 12222
    action = %(action_mwl)s
    logpath = /var/log/secure
```

* 设定邮件转发

```
    vim /etc/nail.rc

    ## Add sendmail settings
    set from=xxxx@gmail.com
    set smtp=smtps:smtp.gmail.com:587
    set smtp-auth-user=xxxx@gmail.com
    set smtp-auth-password=xxxxx
    set smtp-auth=login
    set ssl-verify=ignore
    set nss-config-dir=/etc/pki/nssdb
```

* 设定邮件模板

```
     vim /etc/fail2ban/action.d/mail-whois-lines.conf

    # Fail2Ban configuration file
    #
    # Author: Cyril Jaquier
    #
    #

    [Definition]

    # Option: actionstart
    # Notes.: command executed once at the start of Fail2Ban.
    # Values: CMD
    #
    actionstart = printf %%b "Hi,\n The jail <name> has been started successfully.\n Regards,\n Fail2Ban"|mail -s "[Fail2Ban] <name>: started on `uname -n`" <dest>

    # Option: actionstop
    # Notes.: command executed once at the end of Fail2Ban
    # Values: CMD
    #
    actionstop = printf %%b "Hi,\n The jail <name> has been stopped.\n Regards,\n Fail2Ban"|mail -s "[Fail2Ban] <name>: stopped on `uname -n`" <dest>

    # Option: actioncheck
    # Notes.: command executed once before each actionban command
    # Values: CMD
    #
    actioncheck =

    # Option: actionban
    # Notes.: command executed when banning an IP. Take care that the
    # command is executed with Fail2Ban user rights.
    # Tags: See jail.conf(5) man page
    # Values: CMD
    #
    actionban = printf %%b "Hi,\n The IP <ip> has just been banned by Fail2Ban after <failures> attempts against <name>.\n\n Here are more information about <ip>:\n `whois <ip>`\n `/bin/curl http://ip.taobao.com/service/getIpInfo.php?ip=<ip>`\n\n Regards,\n Fail2Ban"|mail -s "[Fail2Ban] <name>: banned <ip> from `uname -n`" <dest>

    # Option: actionunban
    # Notes.: command executed when unbanning an IP. Take care that the
    # command is executed with Fail2Ban user rights.
    # Tags: See jail.conf(5) man page
    # Values: CMD
    #
    actionunban =

    [Init]

    # Default name of the chain
    #
    name = default

    # Destination/Addressee of the mail
    #
    dest = root

```

* 启动服务，查看状态

```
    systemctl start fail2ban
    systemctl status fail2ban
    fail2ban-client status
```
