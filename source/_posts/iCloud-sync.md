---
title: iCloud同步
date: 2017-01-22 01:55:01
categories: Mac
---

一直以来都觉得iCloud和iTunes就是apple生态系统里的两个坑，用了这么多年了始终没太搞明白这两个怎么用，特别在照片同步上感觉很不方便。由于无法忍受iCloud最近在mac和iphone上反复提醒我5GB空间满了，目前又不想花钱升级，就清理下照片和设置同步。

<!-- more -->

# 选择云盘

国外常见的有Google Drive, Dropbox, OneDrive iCloud Drive，国内常见的有百度云、微云、360云盘、坚果云等，由于一些不可描述的原因国内很多云盘都关闭了。我对云盘有三点需求：数据安全可靠、国内可直接访问、多平台方便同步，首先对于数据安全这点我更相信Google Drive, Dropbox等，然而国内还不能直接访问，OneDrive我不知道可不可以有没有人告知下。现在用Google Drive + iCloud，虽然iCloud做的不如前面几位，但考虑到现在用的都是苹果系产品，用它作文件同步还是不错的，免费只有5GB空间也是个梗，想想国内云盘、Google Drive什么的都是>10GB的，5GB未免太小气了点。为了使用iCloud，首先必须设置下照片同步这个问题。

# 在各设备上取消不必要iCloud同步项

首先在MAC上进入设置->iCloud，取消不需要的同步项，比如我不用额Safari还有占空间的Photos，注意在取消照片同步前，先把iCloud上的照片本地备份下，然后在管理中删除所有照片和取消照片同步，这样iCloud就有空间来做文档同步了。同样在iPhone上也在iCloud设置中取消不必要的同步项，包括照片。

开启iCloud Drive同步，设置中添加Documents文件夹，我会把我重要的文档放在其中这样就能自动同步了。

# Image Capture导入和删除照片

Image Capture可以用来导入iPhone照片和批量删除手机上的照片，导入的照片都会放在/Users/username/Pictures里，新iPhone照片多了动态图功能，这样很多照片都附带一个MOV格式视频，感觉挺占空间的，此外Photos也可以用来导入照片。

Image Capture批量删除手机照片有个坑，对于10.12 macOS，好像苹果取消了删除键..后来发现必须把mac和iphone的照片同步都关了才能看到删除键。