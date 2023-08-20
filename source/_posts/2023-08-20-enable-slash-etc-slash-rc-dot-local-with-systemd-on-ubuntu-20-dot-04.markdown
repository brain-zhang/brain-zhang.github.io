---
layout: post
title: "Enable /etc/rc.local with systemd on Ubuntu 20.04"
date: 2023-08-20 15:01:38 +0800
comments: true
categories: tools
---

# setup systemd service file

```
sudo vi /etc/systemd/system/rc-local.service


[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local
[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99
[Install]
 WantedBy=multi-user.target
```

# enable systemd service

```
sudo systemctl enable rc-local
```

# create rc.local

```
sudo vi /etc/rc.local

#!/bin/bash
...


sudo chmod +x /etc/rc.local
```
