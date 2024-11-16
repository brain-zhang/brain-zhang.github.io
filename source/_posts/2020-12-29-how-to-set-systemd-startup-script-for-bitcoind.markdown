---
layout: post
title: "How to set systemd startup script for bitcoind?"
date: 2020-12-29 16:22:42 +0800
comments: true
categories: blockchain
---

## setup bitcoind.service

```
vim /etc/systemd/system/bitcoind.service
```

```
[Unit]
Description=Bitcoin daemon
After=network.target

[Service]
ExecStart=/opt/node/bitcoin/bin/bitcoind -daemon -conf=/opt/node/bitcoin/blockdata/bitcoin.conf -pid=/run/bitcoind/bitcoind.pid
# Creates /run/bitcoind owned by bitcoin
RuntimeDirectory=bitcoind
RuntimeDirectoryPreserve=yes
User=ubuntu
Type=forking
PIDFile=/run/bitcoind/bitcoind.pid
Restart=on-failure
StandardOutput=/var/log/bitcoind.log
StandardError=/var/log/bitcoind.log

# Hardening measures
####################

# Provide a private /tmp and /var/tmp.
PrivateTmp=true

# Mount /usr, /boot/ and /etc read-only for the process.
ProtectSystem=full

# Disallow the process and all of its children to gain
# new privileges through execve().
NoNewPrivileges=true

# Use a new /dev namespace only populated with API pseudo devices
# such as /dev/null, /dev/zero and /dev/random.
PrivateDevices=true

[Install]
WantedBy=multi-user.target

```

## Reload systemctl daemon

```
systemctl daemon-reload
```

## Enabled new bitcoind service

```
systemctl enable bitcoind
```

## Commands to start or stop the service

```
systemctl stop bitcoind
systemctl start bitcoind
```

## Show service status

```
systemctl status bitcoind.service
```

More info in:

https://github.com/bitcoin/bitcoin/tree/master/contrib/init
