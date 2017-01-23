---
title: Mac备份和移动硬盘读写格式
date: 2017-01-22 03:00:13
categories: Mac
---

初入Mac都会遇到备份的问题，Windows有Ghost，Mac有自带的Time Machine，这里主要讲下用Time Machine备份和MAC使用移动硬盘读写格式的问题。

<!-- more -->

# Time Machine备份

因为Time Machine (TM)备份需要很大的空间，通常要是本体的2倍大小，而TM是增量备份，就像DB的transaction log，第一次备份很大，后面只对变化的文件进行备份就比较小了。它需要一个单独的磁盘进行备份，常用移动硬盘来备份，最好有1T以上。

首先搜索打开TM，可以选择排除不需要备份的大目录，比如Downloads、Steam什么的，然后选择磁盘，这里可以选移动硬盘或分区磁盘，就可以开始备份了。

![](/img/mac_backup/time_machine.png)

下面问题来了，TM必须要求是Mac专用的硬盘格式才能备份，你可以买一个硬盘专门用来做TM备份，不过得转成MAC专用格式，而一般的移动硬盘都是NTFS格式的，在Win下使用没有问题，但是到了Mac下就是只读了不能写入文件，所以再谈一下MAC使用移动硬盘的问题。

# 移动硬盘读写格式

据大家介绍有以下几种方法解决：

- 使用[Paragon](https://www.paragon-software.com/home/ntfs-mac/)或[Tuxera](https://www.tuxera.com/products/tuxera-ntfs-for-mac/)这种第三方付费NTFS插件读写
- 格式化成Exfat或Fat32格式双平台通用
- 硬盘分区分别用于Mac和Win
- 开启苹果自带的NTFS插件

对于第二点，Fat32太老了所以不考虑，而Exfat据说兼容性很差有很多坑也不敢用。还有人写了开启苹果自带插件的教程http://www.tianwaihome.com/2014/07/mac-osx-ntfs.html 大家可以看看，不过听说也有很多问题，总之NTFS是微软的东西，苹果下面使用问题多多，综合来说我觉得还是用第一个方案吧，虽然花点钱但是省心省时间。