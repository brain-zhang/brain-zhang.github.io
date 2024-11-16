---
layout: post
title: "megacli cheat"
date: 2016-08-05 03:21:49 +0800
comments: true
categories: linux tools
---

做Raid，用到了megacli，又学了一套命令.

<!-- more -->

* 显示Rebuid进度


```
/opt/MegaRAID/MegaCli/MegaCli64 -PDRbld -ShowProg -physdrv[20:2] -aALL

```

* 查看ES


```
/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aAll -NoLog | grep -Ei "(enclosure|slot)"

```

* 查看所有硬盘的状态


```
/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -LALL -aAll
/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aAll -NoLog

```

如果RAID卡被设置成了writethrough。这个是完全不利用卡上内存的一种做法，操作系统需要确认磁盘全部写入后再返回，io latency很大，而且性能差。

可以强制让他一定使用writeback模式，命令：


```
/opt/MegaCli64 -LDSetProp -ForcedWB -Immediate -Lall –aAll

```

RAID卡上电池没电，单个盘损坏，都会造成RAID策略的变化，所以需要及时检测。


* 查看所有Virtual Disk的状态


```
/opt/MegaRAID/MegaCli/MegaCli64 -LdPdInfo -aAll -NoLog

```

RAID Level对应关系：

    RAID Level : Primary-1, Secondary-0, RAID Level Qualifier-0 RAID 1
    RAID Level : Primary-0, Secondary-0, RAID Level Qualifier-0 RAID 0
    RAID Level : Primary-5, Secondary-0, RAID Level Qualifier-3 RAID 5
    RAID Level : Primary-1, Secondary-3, RAID Level Qualifier-0 RAID 10

* 在线做Raid


```
/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdAdd -r0[0:11] WB NORA Direct CachedBadBBU -strpsz64 -a0 -NoLog
/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdAdd -r5 [12:2,12:3,12:4,12:5,12:6,12:7] WB Direct -a0

```

* 点亮指定硬盘（定位）


```
/opt/MegaRAID/MegaCli/MegaCli64 -PdLocate -start -physdrv[252:2] -a0

```

* 清除Foreign状态


```
/opt/MegaRAID/MegaCli/MegaCli64 -CfgForeign -Clear -a0

```

* 查看RAID阵列中掉线的盘


```
/opt/MegaRAID/MegaCli/MegaCli64 -pdgetmissing -a0

```

* 替换坏掉的模块


```
/opt/MegaRAID/MegaCli/MegaCli64 -pdreplacemissing -physdrv[12:10] -Array5 -row0 -a0

```

* 手动开启rebuid


```
/opt/MegaRAID/MegaCli/MegaCli64 -pdrbld -start -physdrv[12:10] -a0

```

* 查看Megacli的log


```
/opt/MegaRAID/MegaCli/MegaCli64 -FwTermLog dsply -a0 > adp2.log

```

* 设置HotSpare


```
/opt/MegaRAID/MegaCli/MegaCli64 -pdhsp -set [-Dedicated [-Array2]] [-EnclAffinity] [-nonRevertible] -PhysDrv[4:11] -a0
/opt/MegaRAID/MegaCli/MegaCli64 -pdhsp -set [-EnclAffinity] [-nonRevertible] -PhysDrv[32：1}] -a0

```

* 关闭Rebuild


```
/opt/MegaRAID/MegaCli/MegaCli64 -AdpAutoRbld -Dsbl -a0

```

* 设置rebuild的速率


```
/opt/MegaRAID/MegaCli/MegaCli64 -AdpSetProp RebuildRate -30 -a0

```
