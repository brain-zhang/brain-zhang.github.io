---
layout: post
title: "libpcap PACKET_MMAP内存分配"
date: 2014-12-25 10:03:49 +0800
comments: true
categories: libpcap PACKET_MMAP network
---
libpcap为了提高效率，调用`setsockopt(handle->fd, SOL_PACKET, PACKET_RX_RING,(void *) &req, sizeof(req))`时采用kmalloc分配内存。

可以参考:

https://www.kernel.org/doc/Documentation/networking/packet_mmap.txt


kmalloc底层依赖linux的slab内存分配机制，在2.6.22内核之后，slub取代slab成为默认的内存分配器。空间和时间上都有所提升。值得升级。

另外，centos5.9默认采用的2.6.18内核，编译的时候默认的KMALLOC_MAX_SIZE 设置为size-131072，这对于有很大内存的机器，分配效率是不高的。

最简单的办法就是用rpm包升级到2.6.33.9-rt31.86.el5rt，这个内核编译的时候已经将KMALLOC_MAX_SIZE设置为size-4194304。

这个问题是追踪libpcap的抓包程序，内存分配频繁失败发现的。

只能说，内核升级频繁，很多编译开关影响很大，要想全面发挥linux的性能，只能紧跟潮流啊。
