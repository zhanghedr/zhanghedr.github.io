---
title: Mac安装MySQL
date: 2017-01-22 12:49:44
categories: Tech
---

安装MySQL的方法很多，最好还是从官网下载，需要注意的是新版本的初始root密码改为随机生成了，这里讲下安装步骤和添加PATH。

<!-- more -->

# 安装步骤

1. 官网下载最新版[MySQL Community Server](https://dev.mysql.com/downloads/mysql/)

2. 打开安装包一直下一步，记下在安装过程中随机生成的初始root密码，在右侧Notifications里也会有密码提醒

3. 安装完成后，添加mysql到PATH中，添加方法在下面有写

4. 在System Preferences -> MySQL中开启server，并且勾选开机自启动

5. 打开你使用的terminal，mysql -u root -p，使用初始随机密码登录

6. 初次登录后会提醒必须重置root密码才能使用，根据版本不同修改密码：

   ```Sh
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass'; # MySQL 5.7.6+
   SET PASSWORD FOR 'root'@'localhost' = PASSWORD('MyNewPass'); # MySQL 5.7.5-
   FLUSH PRIVILEGES;  # 最后刷新权限
   ```

# 添加PATH

方法如下，注意系统读取PATH时是按从左到右顺序优先级来的，所以把mysql放在末端。

```sh
echo $PATH  # 查看当前PATH，分隔符是':'
export PATH=$PATH:/usr/local/mysql/bin  # 添加mysql到PATH末端
```

但是上面的方法只是暂时作用于当前session，下次登录时添加的PATH就失效了，如果想永久添加，需要把这句话写到你使用的一个shell配置文件中，比如：~/.zshrc、~/.bashrc、~/.bash_profile、~/.profile。最后要生效，只需重新读一遍配置文件，要不然重启terminal也可以。

```sh
source ~/.zshrc  # 以zsh为例
```

但是上面这个永久方法只是对于当前user有效，因为是在/Users/username/目录下配置，想要为所有users都添加PATH，需要把/usr/local/mysql/bin添加到下面文件中：

```sh
sudo vim /etc/paths
```

# MySQL客户端

这里推荐[Sequel Pro](https://www.sequelpro.com/)，非常简洁快速还是开源的，不过只支持MySQL一种数据库。这时候你就可以在上面建一个127.0.0.1数据库测试一下了，用root和之前修改过的密码。