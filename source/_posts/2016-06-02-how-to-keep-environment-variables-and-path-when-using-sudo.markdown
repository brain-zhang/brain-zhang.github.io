---
layout: post
title: "How to keep Environment Variables and PATH when Using SUDO"
date: 2016-06-02 09:15:19 +0800
comments: true
categories: tools
---

## sudo tips

####  How to keep Environment Variables when Using SUDO

The trick is to add environment variables to sudoers file via sudo visudo command and add these lines:

    Defaults env_keep += "HOME"

or and pay attention to the -E flag. This works:

    export HOME=/home/users/memorybox
    sudo -E bash -c 'echo $HOME'

####  How to keep PATH Variables when Using SUDO

    vim /etc/sudoers
    sed -i 's#Defaults    secure_path =.*#Defaults    secure_path =/usr/java/latest/bin/.....:#g' /etc/sudoers

#### How to change root env

    sudo -i

