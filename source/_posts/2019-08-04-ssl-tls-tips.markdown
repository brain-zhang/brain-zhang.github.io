---
layout: post
title: "SSL&TLS Tips"
date: 2019-08-04 09:35:42 +0800
comments: true
categories: develop
---
每天的日常编码工作：就是解决一个问题的时候再创造另外一个问题 Orz.....

话说刚才生成一个私钥的时候， Python3绑定libssl1.1 又崩了；正在痛苦思考中~~~

<!-- more -->

现在有两个选择:

1. 放弃ssl动态库调用，反正我只用ECDSA，所以找个原生库来用好啦
2. 死磕openssl，把它彻底搞明白

利弊权衡之下我选择了1，不过当然我也在2上花了一点时间，复习了一下基础知识，在此记录下来。

### libssl3是个什么东东

在探究libssl.so的时候，我无意发现我的系统里面还有一个libssl3.so；这个是什么东东？我印象里面openssl还只有1.x版本才对；

我在ubuntu16.04下查看这个so文件来源;


```
~ locate libssl3.so
/usr/lib/x86_64-linux-gnu/libssl3.so

```

nm看一下:


```
~ nm /usr/lib/x86_64-linux-gnu/libssl3.so
nm: /usr/lib/x86_64-linux-gnu/libssl3.so: no symbols


```

奇怪，没有任何符号；继续用ldd看一下：


```
~ ldd /usr/lib/x86_64-linux-gnu/libssl3.so
ldd /usr/lib/x86_64-linux-gnu/libssl3.so
        linux-vdso.so.1 =>  (0x00007ffe833bb000)
        libnss3.so => /usr/lib/x86_64-linux-gnu/libnss3.so (0x00007faf3cc8a000)
        libnssutil3.so => /usr/lib/x86_64-linux-gnu/libnssutil3.so (0x00007faf3ca5d000)
        libplc4.so => /usr/lib/x86_64-linux-gnu/libplc4.so (0x00007faf3c858000)
        libnspr4.so => /usr/lib/x86_64-linux-gnu/libnspr4.so (0x00007faf3c619000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007faf3c3fc000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007faf3c032000)
        libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007faf3be18000)
        libplds4.so => /usr/lib/x86_64-linux-gnu/libplds4.so (0x00007faf3bc14000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007faf3ba10000)
        librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007faf3b808000)
        /lib64/ld-linux-x86-64.so.2 (0x00007faf3d21d000)


```

嗯，找到了一个有意思的依赖:libnss3.so

再用命令dpkg看一下


```
~ dpkg -S /usr/lib/x86_64-linux-gnu/libnss3.so
libnss3:amd64: /usr/lib/x86_64-linux-gnu/libnss3.so

```

基本上确定是libnss3这个库引入的libssl3.so了，最后再用dpkg确认一下:


```
~ dpkg-query -L libnss3
/.
/usr
/usr/lib
/usr/lib/x86_64-linux-gnu
/usr/lib/x86_64-linux-gnu/libnssutil3.so
/usr/lib/x86_64-linux-gnu/nss
/usr/lib/x86_64-linux-gnu/nss/libfreebl3.chk
/usr/lib/x86_64-linux-gnu/nss/libnssckbi.so
/usr/lib/x86_64-linux-gnu/nss/libsoftokn3.so
/usr/lib/x86_64-linux-gnu/nss/libsoftokn3.chk
/usr/lib/x86_64-linux-gnu/nss/libfreeblpriv3.chk
/usr/lib/x86_64-linux-gnu/nss/libfreeblpriv3.so
/usr/lib/x86_64-linux-gnu/nss/libnssdbm3.chk
/usr/lib/x86_64-linux-gnu/nss/libnssdbm3.so
/usr/lib/x86_64-linux-gnu/nss/libfreebl3.so
/usr/lib/x86_64-linux-gnu/nss/libnsssysinit.so
/usr/lib/x86_64-linux-gnu/libsmime3.so
/usr/lib/x86_64-linux-gnu/libnss3.so
/usr/lib/x86_64-linux-gnu/libssl3.so
/usr/share
/usr/share/doc
/usr/share/doc/libnss3
/usr/share/doc/libnss3/copyright
/usr/share/doc/libnss3/changelog.Debian.gz
/usr/share/lintian
/usr/share/lintian/overrides
/usr/share/lintian/overrides/libnss3

```

### libnss3是个什么东东?


```
apt-cache show libnss3

```

看了一下，发现是mozilla基金会搞得东东；再google一下，发现是自己孤陋寡闻了；

原来，SSL&TSL的实现，不只是openssl一家独大，像Mozilla Firefox就用自家实现的Nss；

Google Chrome之前也是用Nss的，后来迁移到了openssl，再后来，2014年，openssl1.0.1出现了heartbeat 漏洞，Google干脆自己开了个分支，用自己定制的openssl了；

至于Windows平台的，还有C++阵营的，都有自己实现的ssl库，具体可参见:

https://www.usenix.org/conference/usenixsecurity15/technical-sessions/presentation/de-ruiter

### nss在centos中

搜素的过程中，我惊奇的发现，ubuntu和centos上面的curl，竟然链接的libssl也不一样：

ubuntu上的curl默认链接的是openssl，而centos上面默认链接的是libnss3；

耐人寻味啊，莫非redhat系的人发现了什么~~~~

做事要做全套，我分别切换到ubuntu16.04和centos7.2上面，看看他们官方仓库中自带的curl是如何编译的。

#### centos7.2


```
~ rpm -q --requires curl
libc.so.6()(64bit)
libc.so.6(GLIBC_2.14)(64bit)
libc.so.6(GLIBC_2.17)(64bit)
libc.so.6(GLIBC_2.2.5)(64bit)
libc.so.6(GLIBC_2.3)(64bit)
libc.so.6(GLIBC_2.4)(64bit)
libc.so.6(GLIBC_2.7)(64bit)
libcurl = 7.29.0-51.el7
libcurl.so.4()(64bit)
libdl.so.2()(64bit)
libnspr4.so()(64bit)
libnss3.so()(64bit)
libnssutil3.so()(64bit)
libplc4.so()(64bit)
libplds4.so()(64bit)
libpthread.so.0()(64bit)
libpthread.so.0(GLIBC_2.2.5)(64bit)
libsmime3.so()(64bit)
libssl3.so()(64bit)
libz.so.1()(64bit)
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(FileDigests) <= 4.6.0-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rtld(GNU_HASH)
rpmlib(PayloadIsXz) <= 5.2-1

```
用的是libcurl = 7.29.0-51.el7；


```
~ rpm -q --requires libcurl
/sbin/ldconfig
libc.so.6()(64bit)
libc.so.6(GLIBC_2.14)(64bit)
libc.so.6(GLIBC_2.15)(64bit)
libc.so.6(GLIBC_2.16)(64bit)
libc.so.6(GLIBC_2.17)(64bit)
libc.so.6(GLIBC_2.2.5)(64bit)
libc.so.6(GLIBC_2.3)(64bit)
libc.so.6(GLIBC_2.3.4)(64bit)
libc.so.6(GLIBC_2.4)(64bit)
libc.so.6(GLIBC_2.7)(64bit)
libcom_err.so.2()(64bit)
libdl.so.2()(64bit)
libgssapi_krb5.so.2()(64bit)
libgssapi_krb5.so.2(gssapi_krb5_2_MIT)(64bit)
libidn.so.11()(64bit)
libidn.so.11(LIBIDN_1.0)(64bit)
libk5crypto.so.3()(64bit)
libkrb5.so.3()(64bit)
liblber-2.4.so.2()(64bit)
libldap-2.4.so.2()(64bit)
libnspr4.so()(64bit)
libnss3.so()(64bit)
libnss3.so(NSS_3.10)(64bit)
libnss3.so(NSS_3.12.1)(64bit)
libnss3.so(NSS_3.12.5)(64bit)
libnss3.so(NSS_3.2)(64bit)

....

```
看到libnss3了,重点输出：

```
libnss3.so

```
那么这个包是谁提供的？输入如下命令：


```
~ rpm -qf /usr/lib64/libnss3.so 
    nss-3.36.0-7.1.el7_6.x86_64
~ rpm -ql nss
/etc/pki/nss-legacy
/etc/pki/nss-legacy/nss-rhel7.config
/etc/pki/nssdb
/etc/pki/nssdb/cert8.db
/etc/pki/nssdb/cert9.db
/etc/pki/nssdb/key3.db
/etc/pki/nssdb/key4.db
/etc/pki/nssdb/pkcs11.txt
/etc/pki/nssdb/secmod.db
/usr/lib64/libnss3.so
/usr/lib64/libnssckbi.so
/usr/lib64/libsmime3.so
/usr/lib64/libssl3.so
/usr/lib64/nss/libnssckbi.so
...

```
至此水落石出，还可以看到我们熟悉的证书cert8.db文件；但其实 curl 最终使用的根证书库并不是该文件。那 curl 使用的根证书文件在哪儿呢？

使用 curl-config 命令行工具，能够了解更多：

```
~ curl-config --ca                        
/etc/pki/tls/certs/ca-bundle.crt

```

#### ubuntu16.04

ubuntu16上面验证类似，不一一说明了~~~


```
~ dpkg-query -L libcurl3
/.
/usr
/usr/share
/usr/share/doc
/usr/share/doc/libcurl3
/usr/share/doc/libcurl3/copyright
/usr/share/doc/libcurl3/changelog.Debian.gz
/usr/share/doc/libcurl3/NEWS.Debian.gz
/usr/share/lintian
/usr/share/lintian/overrides
/usr/share/lintian/overrides/libcurl3
/usr/lib
/usr/lib/x86_64-linux-gnu
/usr/lib/x86_64-linux-gnu/libcurl.so.4.4.0
/usr/lib/x86_64-linux-gnu/libcurl.so.3
/usr/lib/x86_64-linux-gnu/libcurl.so.4


```


```
~ apt-cache depends  libcurl3
  Depends: libc6
  Depends: libgssapi-krb5-2
  Depends: libidn11
  Depends: libldap-2.4-2
  Depends: librtmp1
  Depends: libssl1.0.0
  Depends: zlib1g
  Recommends: ca-certificates

```

然后寻找libcurl的依赖库:


```
~ ldd /usr/lib/x86_64-linux-gnu/libcurl.so.4.4.0|grep ssl
libssl.so.1.0.0 => /lib/x86_64-linux-gnu/libssl.so.1.0.0 (0x00007fbdf8aa0000)

```

验证一下:


```
~ apt-cache depends openssl
openssl
  Depends: libc6
  Depends: libssl1.0.0
  Suggests: ca-certificates
  
~ apt-cache rdepends  libssl1.0.0 | grep curl
  libcurl3  

```


### 总结

所以这就是想要解决一个问题的中途，又被带到了另外一条小路上；该说我是还有那么一点好奇心呢？还是注意力不集中呢？

Orz.........

### 参考资料:

https://www.ruanyifeng.com/blog/2014/02/ssl_tls.html

https://www.usenix.org/conference/usenixsecurity15/technical-sessions/presentation/de-ruiter

https://zh.wikipedia.org/wiki/%E5%BF%83%E8%84%8F%E5%87%BA%E8%A1%80%E6%BC%8F%E6%B4%9E

https://www.lbbniu.com/6680.html
