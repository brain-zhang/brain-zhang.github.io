---
layout: post
title: "多个git账号之间的切换"
date: 2014-12-07 15:00:34 +0800
comments: true
categories: git tools
---

做过很多遍了，却总是记不住，这回从头来描述一下。

介绍
===============================

所谓多个git账号，可能有两种情况:

* 我有多个github的账号，不同的账号对应不同的repo，需要push的时候自动区分账号

* 我有多个git的账号，有的是github的，有的是bitbucket的，有的是单位的gitlab的，不同账号对应不同的repo，需要push的时候自动区分账号

这两种情况的处理方法是一样的，分下面几步走:

处理
===============================

* 先假设我有两个账号，一个是github上的，一个是公司gitlab上面的。先为不同的账号生成不同的ssh-key

    
```
        ssh-keygen -t rsa -f ~/.ssh/id_rsa_work -c xxx@gmail.com
    
```

    然后根据提示连续回车即可在~/.ssh目录下得到id_rsa_work和id_rsa_work.pub两个文件，id_rsa_work.pub文件里存放的就是我们要使用的key

    
```
        ssh-keygen -t rsa -f ~/.ssh/id_rsa_github -c xxx@gmail.com
    
```

    然后根据提示连续回车即可在~/.ssh目录下得到id_rsa_github和id_rsa_github.pub两个文件，id_rsa_gthub.pub文件里存放的就是我们要使用的key

* 把id_rsa_xxx.pub中的key添加到github或gitlab上，这一步在github或gitlab上都有帮助，不再赘述

* 编辑 `~/.ssh/config`，设定不同的git 服务器对应不同的key


```
    # Default github user(first@mail.com),注意User项直接填git，不用填在github的用户名
    Host github.com
     HostName github.com
     User git
     IdentityFile ~/.ssh/id_rsa_github

    # second user(second@mail.com)
    # 建一个gitlab别名，新建的帐号使用这个别名做克隆和更新
    Host 172.16.11.11
     HostName 172.16.11.11
     User work
     IdentityFile ~/.ssh/id_rsa_work

```

编辑完成后可以使用命令 `ssh -vT git@github.com` 看看是不是采用了正确的id_rsa_github.pub文件

这样每次push的时候系统就会根据不同的仓库地址使用不同的账号提交了

* 从上面一步可以看到，ssh区分账号，其实靠的是HostName这个字段，因此如果在github上有多个账号，很容易的可以把不同的账号映射到不同的HostName上就可以了。比如我有A和B两个账号， 先按照步骤一生成不同的key文件，再修改`~/.ssh/config` 内容应该是这样的。


```
    # Default github user(A@mail.com),注意User项直接填git，不用填在github的用户名
    Host A.github.com
     HostName github.com
     User git
     IdentityFile ~/.ssh/id_rsa_github_A

    # second user(B@mail.com)
    # 建一个gitlab别名，新建的帐号使用这个别名做克隆和更新
    Host A.github.com
     HostName github.com
     User git
     IdentityFile ~/.ssh/id_rsa_github_B

```

同时你的github的repo ssh url就要做相应的修改了，比如根据上面的配置,原连接地址是:

    git@github.com:testA/gopkg.git

那么根据上面的配置，就要把`github.com`换成`A.github.com`, 那么ssh解析的时候就会自动把`testA.github.com` 转换为 `github.com`,修改后就是

    git@A.github.com:testA/gopkg.git

直接更改 `repo/.git/config` 里面的url即可

这样每次push的时候系统就会根据不同的仓库地址使用不同的账号提交了


一些题外话
===============================

我有一个repo，想要同时push到不同的仓库该如何设置?
--------------------------------------------------

很简单， 直接更改 `repo/.git/config` 里面的url即可，把里面对应tag下的url增加一个就可以了。例:


```
[remote "GitHub"]
    url = git@github.com:elliottcable/Paws.o.git
    fetch = +refs/heads/*:refs/remotes/GitHub/*
[branch "Master"]
    remote = GitHub
    merge = refs/heads/Master
[remote "Codaset"]
    url = git@codaset.com:elliottcable/paws-o.git
    fetch = +refs/heads/*:refs/remotes/Codaset/*
[remote "Paws"]
    url = git@github.com:Paws/Paws.o.git
    fetch = +refs/heads/*:refs/remotes/Paws/*
[remote "Origin"]
    url = git@github.com:Paws/Paws.o.git
    url = git@codaset.com:elliottcable/paws-o.git

```

上面这个立即就是有4个远端仓库，不同的tag表示不同的远端仓库，最后的Origin标签写法表示默认push到github和codaset这两个远端仓库去。当然，你可以自己随意定制tag和url

我有一个github的repo，clone没有问题，push的时候总是报错:error: The requested URL returned error: 403 while accessing xxx
--------------------------------------------------

这个问题也困扰了我一段时间，后来发现修改 `repo/.git/config` 里面的url，把https地址替换为ssh就好了。

例如

    url=https://MichaelDrogalis@github.com/derekerdmann/lunch_call.git

替换为

    url=ssh://git@github.com/derekerdmann/lunch_call.git

参考
===============================

http://stackoverflow.com/questions/7438313/pushing-to-git-returning-error-code-403-fatal-http-request-failed
http://stackoverflow.com/questions/849308/pull-push-from-multiple-remote-locations/3195446#3195446
