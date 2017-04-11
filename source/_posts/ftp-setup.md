---
title: 搭建FTP
date: 2017-04-11 00:45:29
categories: Tech
---

FTP应用协议可以用于服务器文件的上传和下载，这里讲下如何在Ubuntu下搭建FTP。

<!-- more -->

FTP服务器工具有很多，这里选用**vsftpd**，安装如下：

```bash
sudo apt-get install vsftpd
```

然后修改配置并重启服务：

```sh
sudo vim /etc/vsftpd.conf

write_enable=YES
chroot_local_user=YES
pasv_enable=YES
pasv_min_port=1024
pasv_max_port=1048
pasv_address={Elastic IP}
allow_writeable_chroot=YES

sudo service vsftpd restart
```

创建FTP用户，adduser会配置好/home/ftp_user和user group：

```sh
sudo adduser ftp_user
```

修改FTP用户home目录：

```sh
sudo usermod ftp_user -d /home/ftp_user/
```

查看user和group：

```sh
compgen –u
compgen –g
```

查看group包含哪些users：

```sh
getent group ftp_user
```

看user属于哪些group：

```sh
groups ftp_user
```

登录FTP：

```sh
ftp {domain}
```

`/etc/vsftpd/ftpusers`列举了被禁止的FTP用户。