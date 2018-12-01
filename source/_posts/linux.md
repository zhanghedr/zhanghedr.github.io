---
title: Linux常用命令
date: 2018-06-03 02:29:34
categories: Tech
---

Linux文件权限分为三种：所有者、群组、其他用户和组，r=4(读)、w=2(写)、x=1(执行)，+ 为增加权限、- 为取消权限。

- rwx：4+2+1=7
- rw-：4+2=6
- r-x：4+1=5

<!-- more -->

### 权限管理

```Sh
sudo # 以系统管理者root身份执行命令，需要先输入密码
su root # 切换当前用户身份到其他用户身份，不输默认切root
sudo su # 以sudoer密码切换到root
chgrp root file # 更改文件所属群组
chown user file # 更改文件所属用户或群组
chmod 755 file # 赋予文件rwxr-xr-x权限，3个数字分别表示User、Group、Other权限
chmod 777 folder # 赋予目录rwxrwxrwx权限，-R进行子目录递归变更
useradd newuser # 新增用户
usermod newuser # 更新用户
userdel newuser # 删除用户
id # 显示用户的ID，以及所属群组的ID
whoami # 显示自身用户名称
w # 显示目前登入系统的用户信息
```

### 文件管理

```sh
cat file # 打印文件内容
cat /dev/null > file # 清空文件内容
touch file # 修改文件时间为系统时间，若文件不存在，会创建一个新文件
ls -alh # 列出所有文件，包括文件权限、拥有者、拥有组、大小(不包括子目录)等信息
diff log1 log2 # 比较文件的差异
find file # 在当前目录下查找文件
scp local_file remote_username@remote_ip:remote_folder # 基于ssh安全的远程文件拷贝
tree # 以树状图列出目录的内容
tar -xvfz archive.tar.gz # 解压一个gzip格式的压缩包 
zip # 压缩zip格式的压缩包 
unzip file.zip # 解压一个zip格式压缩包 
gzip # 压缩gz压缩包
```

### 日志查询

```sh
grep "keyword" app.log # 查找文件里字符串匹配的行
grep -B 3 -A 3 "keyword" app.log # 查找匹配行及前后3行
less app.log | grep "keyword" # 浏览文件，G-移到最后一行，ctrl+F-前移一屏，ctrl+BB-后移一屏
cat app.log | grep "keyword" -m 10 # 类似less，最多10行
cat app.log | grep "keyword" -c # 匹配总行数
cat app.log | grep "keyword" > app-new.log # 日志太多输出到新文件查看
tail -f app.log # 实时显示文件尾部内容，默认10行
tail -f -n 20 app.log | grep "keyword" # 实时显示文件尾部内容，20行
```

### 查看资源使用情况

```sh
ps aux | grep java # 显示BSD格式进程
ps -ef | grep java # 显示标准格式进程
top # 实时显示进程动态
htop # 高级版top
vmstat 5 # 查看虚拟内存，每5秒刷新一次
free -m # 以MB为单位显示内存的使用情况
kill -9 pid # 强制杀死进程
df -h # 显示文件系统的磁盘使用情况
du -h folder # 显示目录或文件的大小
du -hd 1 # 显示1层文件深度大小
```

### 系统和网络

```sh
uname -a # 显示系统信息
date # 系统日期，包括时区
crontab 0 * * * * /bin/ls # 执行定时任务
setenv VAR abc # 查询或设置环境变量
ifconfig # 显示或设置网络设备
ping zhanghedr.com # 请求检测主机
curl zhanghedr.com # curl可以用来发送各种HTTP请求、执行下载
```

### VIM

```sh
:q # quit
:wq # write and quit
:x # write and quit
:G # to bottom of file
```

### 参考

[Linux 命令大全](http://www.runoob.com/linux/linux-command-manual.html)