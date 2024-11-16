---
layout: post
title: "debug kernel panic in centos"
date: 2015-06-07 01:22:34 +0000
comments: true
categories: tools kernel panic
---

当你面对一台新机器，出于某些原因(不是闲的慌)不得不自己编译一个内核时，会碰上kernel panic。

kernel panic很让人心烦，启动时的panic更让人烦，没有挂上硬盘，没有任何log的panic尤其让人烦。

提供几个解决问题的瞎搞方法: （以下内容针对于redhat系，但大部分方法是通用的）

#### 判断引起panic的环节

简单描述下启动流程:

    1 Power On                                 Maybe Err:Worlds Collides
    2 BIOS                                     Maybe Err:Worlds Collides
    3 Load Grub From MBR                       Maybe Err:See nothing
    4 load Grub and show it                    Maybe Err:Grub loads failed
    5 Grub reads menu.list                     Maybe Err:Grub loads failed
    6 Grub loads kernel image                  Maybe Err:Grub loads failed
    7 kernel mounts root filesystem            Maybe Err:PANIC
    8 kernel runs init                         Maybe Err:PANIC
    9 init runs scripts to start               Maybe Err:PANIC
    

首先你要确认下是哪个环节引起的panic，如果你的log打得比较全，一般能根据蛛丝马迹判断是上面那个环节引起的问题。一般panic发生在step7，step8, step9环节当中。

* step9: 走到这里已经无大碍，无非是/etc/rc.sysinit 之流挂载了不该有的设备，启动了不知道神马的服务，可以直接在启动脚本中打各种log调试

* step8: 这个就比较棘手，一般是initramfs 解压后执行某些脚本报错，所幸是大部分都是init级别的，一般可以在grub的kernel后面加参数，挂载shell调，也可以直接用工具修改initramfs镜像中的文件，重新打包二分法定位

* step7: 也比较棘手，一般panic总要怀疑磁盘驱动，我感觉这个是导致panic的大户，另外如果屏幕没有东东输出，估计视频驱动也要鼓捣一番。



下面针对 step7，step8级别的panic提供一些瞎搞手段

#### 在kernel 参数中加入调试开关，关闭ACPI，selinux


```
  title CentOS (2.6.32-358.el6.x86_64)
          root (hd0,0)
          kernel /vmlinuz-2.6.32-358.el6.x86_64 ro root=/dev/mapper/vg_localhost-lv_root rd_NO_LUKS rd_NO_MD rd_LVM_LV=vg_localhost/lv_swap crashkernel=128M LANG=zh_CN.UTF-8 rd_LVM_LV=vg_localhost/lv_root  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM debug selinux=0 acpi=0
          initrd /initramfs-2.6.32-358.el6.x86_64.img

```    

这是考验人品的时候，不管三七二十一，先把最有可能的问题点排除掉。另外redhat系的会在kernel后面加上 `rhgb quiet` 之类的参数，统统去掉，开机的时候好好盯着屏幕看看，有没有可疑的东东输出。 因为系统可能会在短时间内输出大量log而没有记录，你需要设置一下输出log的速率和暂停时机，更详细的参数可以在这里找到:

https://wiki.archlinux.org/index.php/Boot_debugging

#### 在kernel 参数中加入dracut的调试开关

redhat系后期采用了dracut构建 initrd镜像，关于dracut的手册在这里:

http://people.redhat.com/harald/dracut-rhel6.html#lsinitrd

调试开关在这里:

https://fedoraproject.org/wiki/How_to_debug_Dracut_problems

你可以设定rdshell，在panic之后跳入dracut提供的shell，打dmesg看看log信息。

### 最后的最后，实在不知道为啥了，而且你很闲，可以考虑启动时加串口设备调试

#### 一些tooltip

* 编译kernel的时候，make menuconfig，3.10以后的内核支持搜索某个开关后按数字键直接跳到那个开关的设置项中，这个很有用

* redhat系用dracut构建initrd，配置文件默认在 /usr/share/dracut/ ，如果你懒得改 initramfs，可以直接修改里面的配置文件，然后重新make install即可

* 有时候你不好确认根文件系统挂载到哪里了，可以参考这里:

http://free-electrons.com/blog/find-root-device/

其它参考资料:

http://www.tuxradar.com/content/how-fix-linux-boot-problems
