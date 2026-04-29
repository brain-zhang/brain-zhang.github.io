---
layout: post
title: "PVE 9.1 LXC 显卡共享: 部署Steam headless"
date: 2026-04-29 16:48:46 +0800
comments: true
categories: tools
---

这是一种非常折腾的做法，目前来看这么折腾的人真不多;

最终实现的效果就是在PVE环境中，用数个LXC容器将一张消费级GPU (我是一张RTX 3060 12GB) 切分到不同的Linux系统实例中，同时这些实例还能共享显卡的算力和显存；同时，最妙的 ---- 这张显卡的算力和显存是动态分配的； 这比显卡直通，比老黄专业卡的虚拟化还爽；

具体配置请参考前一篇文章；这种方法肯定是老黄不愿意看到的，但是折腾人士乐此不疲；

<!-- more -->

目前我的一张3060 12GB上面运行了六台LXC容器共享，里面的服务有:

1. Ollama运行了一干小尺寸模型进行测试，例如gemma 4 e4b;
2. 有数个FFmpeg流媒体压制
3. 有数个CUDA实现的加密算法测试


当然，还有今天我们想做的，跑一个Linux Steam 串流服务器；这种做法的原理是：PVE宿主机 --(挂载.so文件和/dev设备)-->  LXC容器 --(Docker device mapping)-->  Docker容器。

#### 具体搭建步骤参考了这篇文章

https://zheteng.pages.dev/posts/2024/headless-steam-in-lxc-with-gpu

#### 踩过的坑：

* LXC容器中的docker用最新版本，我的版本是: Docker version 29.4.1, build 055a478

* 宿主机PVE HOST的 NVIDIA 驱动需要开启 modeset

```
modprobe nvidia-modeset
modprobe nvidia-drm modeset=1
nvidia-modprobe -m
```

* LXC容器配置:

```
arch: amd64
cores: 32
features: fuse=1,keyctl=1,mknod=1,nesting=1
hostname: hpc-ubuntu24-gpu1
memory: 65535
mp0: thinpoolg:vm-154-disk-0,mp=/opt,size=1000G
net0: name=eth0,bridge=vmbr0,firewall=1,gw=192.168.100.2,hwaddr=BC:24:11:53:58:CE,ip=192.168.100.154/24,type=veth
ostype: ubuntu
rootfs: thinpoolf:vm-154-disk-0,size=100G
swap: 512
unprivileged: 0
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.cgroup2.devices.allow: c 10:* rwm
lxc.cgroup2.devices.allow: c 235:* rwm
lxc.cgroup2.devices.allow: c 195:* rwm
lxc.cgroup2.devices.allow: c 511:* rwm
lxc.cgroup2.devices.allow: c 236:* rwm
lxc.mount.entry: /dev/nvidia-modeset dev/nvidia-modeset none bind,optional,create=file
lxc.mount.entry: /dev/uinput dev/uinput none bind,optional,create=file
lxc.mount.entry: /dev/nvidia0 dev/nvidia0 none bind,optional,create=file
lxc.mount.entry: /dev/nvidiactl dev/nvidiactl none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm dev/nvidia-uvm none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm-tools dev/nvidia-uvm-tools none bind,optional,create=file
lxc.mount.entry: /dev/nvram dev/nvram none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-caps/nvidia-cap1 dev/nvidia-caps/nvidia-cap1 none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-caps/nvidia-cap2 dev/nvidia-caps/nvidia-cap2 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-ml.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-cfg.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-cfg.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libcuda.so.580.142 usr/lib/x86_64-linux-gnu/libcuda.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libcuda.so.580.142 usr/lib/x86_64-linux-gnu/libcuda.so.1 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libcuda.so.580.142 usr/lib/x86_64-linux-gnu/libcuda.so none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-encode.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-encode.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-encode.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-encode.so.1 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvcuvid.so.580.142 usr/lib/x86_64-linux-gnu/libnvcuvid.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvcuvid.so.580.142 usr/lib/x86_64-linux-gnu/libnvcuvid.so.1 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-encode.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-encode.so.1 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-allocator.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-allocator.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-allocator.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-allocator.so.1 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-ptxjitcompiler.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-ptxjitcompiler.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-ptxjitcompiler.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-ptxjitcompiler.so.1 none bind,optional,create=file
lxc.mount.entry: /usr/bin/nvidia-smi usr/bin/nvidia-smi none bind,optional,create=file
lxc.mount.entry: /usr/bin/nvidia-ctk usr/bin/nvidia-ctk none bind,optional,create=file
lxc.mount.entry: /usr/bin/nvidia-cdi-hook usr/bin/nvidia-cdi-hook none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-compute.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-compute.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-compute.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-compute.so.1 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-fbc.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-fbc.so.580.142 none bind,optional,create=file
lxc.mount.entry: /usr/lib/x86_64-linux-gnu/libnvidia-fbc.so.580.142 usr/lib/x86_64-linux-gnu/libnvidia-fbc.so.1 none bind,optional,create=file:w
```


* 要在LXC容器中开启 CDI:

```
# 创建配置目录
sudo mkdir -p /etc/cdi

# 生成 CDI 规范文件
# 这会扫描 /dev/nvidia* 设备并创建一个名为 nvidia.yaml 的文件
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

* 教程中的docker-compose.yaml driver部分需要做一点儿小小的修改:
```
services:
  steam-headless:
    image: ...
    deploy:
      resources:
        reservations:
          devices:
            - driver: cdi
              capabilities: [gpu]
              device_ids:
                - nvidia.com/gpu=0     # 确保这里和你的 /etc/cdi/nvidia.yaml 里面的 name 对应
...
```

好了，steam串流起来了，最后就可以愉快的最大化压榨这张显卡了；


