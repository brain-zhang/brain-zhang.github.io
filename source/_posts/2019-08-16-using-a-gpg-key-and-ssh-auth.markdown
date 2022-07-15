---
layout: post
title: "Using a GPG key and ssh Auth"
date: 2019-08-16 16:13:32 +0800
comments: true
categories: tools
---

在我的一台服务器被数不清的脚本小子暴力尝试登陆N次后，我下定决心将所有的开发环境换成统一的ssh key；并禁止用户登陆；

其中最折腾的部分就是使用我的GPG Key统一所有的ssh 环境；我也很纳闷，为什么自己没有早点搞定这些事情；

众所周知，GPG和Openssl的key是不兼容的，所以统一环境还是花了不少时间，主要是参考了这篇文章：

https://ryanlue.com/posts/2017-06-29-gpg-for-ssh-auth

常用命令:
<!-- more -->

### GPG

* 生成证书



```
gpg --gen-key


```

* 生成撤销证书



```
gpg --gen-revoke [用户ID]


```

* 列出所有密钥


```
gpg --list-keys


```

输出


```
/home/brain/.gnupg/pubring.gpg
-------------------------------
pub   4096R/xxxxxxxx 2018-08-16
uid                  brain.zhang (brain-zhang.github.io) <brain.zhangbin#xxx.com>
sub   4096R/yyyyyyyy 2018-08-16


```

第一行显示公钥文件名（pubring.gpg），第二行显示公钥特征（4096位，Hash字符串和生成时间），第三行显示"用户ID"，第四行显示subkey。


* 输出密钥



```
gpg --armor --output public-key.txt --export [用户ID]


```

* 输出密钥时转换私钥


```
gpg --armor --output private-key.txt --export-secret-keys


```

* 上传公钥


```
gpg --keyserver keys.gnupg.net --send-keys [pub key ID] 
...
gpg --keyserver keys.gnupg.net --search-keys brain.zhang


```

* 生成公钥指纹供别人检查


```
gpg --fingerprint [用户ID]


```

* 加密文件


```
gpg --recipient [用户ID] --output demo.en.txt --encrypt demo.txt


```

* 解密文件


```
gpg --decrypt demo.en.txt --output demo.de.txt


```

* 对文件签名


```
gpg --clearsign demo.txt


```

* 获得单独的签名文件


```
gpg --armor --detach-sign demo.txt


```

* 验证签名


```
gpg --verify demo.txt.asc demo.txt


```

### 导入第三方公钥

* 获得公钥


```
gpg --keyserver keys.gnupg.net --search-keys <user ID>
...
gpg --keyserver hkp://subkeys.pgp.net --search-keys brain.zhang


```

* 验证公钥


```
 gpg --edit-key <key ID>



```
你可以键入`fpr` 来打印这个主钥的指纹，和你得到的主钥指纹进行对比，如果一致则键入`trust` 来设置主钥的信任度。如果主钥被设置为绝对可信的（ultimately），GPG 会根据主钥的公钥验证从钥的签名，最终完成信任建立。最后键入quit 退出。


### 在Github中使用GPG

* 输出key id


```
gpg --list-secret-keys --keyid-format LONG


```

* 设置提交


```
 git config  user.signingkey <key ID>



```

* 对单次提交进行签名： 


```
git commit -S -m "-S选项表示对此次提交使用gpg进行签名"


```

* 签名标签


```
git tag -s <tag>


```

### ssh server gen

* 制作密钥对


```
[root@host ~]$ ssh-keygen 


```

* 把生成的/root/.ssh/id_rsa.pub拷贝到在服务器上，安装公钥


```
[root@host ~]$ cd .ssh
[root@host .ssh]$ cat id_rsa.pub >> authorized_keys
[root@host .ssh]$ chmod 600 authorized_keys
[root@host .ssh]$ chmod 700 ~/.ssh


```

* 设置 SSHD，打开密钥登录功能
编辑 /etc/ssh/sshd_config 文件，进行如下设置：



```
PubkeyAuthentication yes
PermitRootLogin yes


```

* 将私钥下载到客户端，然后转换为 PuTTY 能使用的格式

使用 WinSCP、SFTP 等工具将私钥文件 id_rsa 下载到客户端机器上。然后打开 PuTTYGen，单击 Actions 中的 Load 按钮，载入你刚才下载到的私钥文件。如果你刚才设置了密钥锁码，这时则需要输入。

载入成功后，PuTTYGen 会显示密钥相关的信息。在 Key comment 中键入对密钥的说明信息，然后单击 Save private key 按钮即可将私钥文件存放为 PuTTY 能使用的格式。

今后，当你使用 PuTTY 登录时，可以在左侧的 Connection -> SSH -> Auth 中的 Private key file for authentication: 处选择你的私钥文件，然后即可登录了，过程中只需输入密钥锁码即可。

* 验证无误，关闭密码登陆


```
PasswordAuthentication no
[root@host .ssh]$ service sshd restart


```
