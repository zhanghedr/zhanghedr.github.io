---
title: AWS EC2和RDS搭建基础环境
date: 2017-04-10 21:37:34
categories: Tech
---

本文用EC2和RDS搭建简单的服务器环境，就当是Linux笔记了。

<!-- more -->

### 创建EC2实例

首先在AWS上创建一个EC2实例，选用Ubuntu 16.04，测试的话可以选免费的t2.micro类型，在创建时注意选择或创建security group，同时在最后选择或创建一个key pair(public key+private key)，用来SSH登录：

```sh
ssh -i "/path/to/pem" ubuntu@{domain}
```

### 创建RDS实例

创建MySQL RDS实例很简单，主要就是根据需求选类型、磁盘SSD、大小、Multi-AZ等，可以根据AWS提供的计算器根据使用量计算每个月价格。会给一个超级管理员用户，然后创建自定义DB用户。

### 配置Security Group

EC2需要配置inbound规则，也就是访问允许的协议、端口和IP，最基本几个配置举例：

| Type            | Protocol | Port Range        | Source    |
| :-------------- | :------- | :---------------- | :-------- |
| HTTP            | TCP      | 80                | 0.0.0.0/0 |
| HTTPS           | TCP      | 443               | 0.0.0.0/0 |
| SSH             | TCP      | 22                | 0.0.0.0/0 |
| Custom TCP Rule | TCP      | 8080 (customized) | 0.0.0.0/0 |
| Custom UDP Rule | UDP      | 8081 (customized) | 0.0.0.0/0 |

`0.0.0.0/0`表示任意IP地址，source可以是唯一的IP也可以是一个security group下的所有实例。RDS实例也需要设置inbound规则，首先是允许EC2所在的security group访问，然后可以是指定custom的IP地址。

### 创建Elastic IP

EC2实例的IPv4公共IP是动态的，每次重启都会改变，这里需要创建一个固定的Elastic IP，然后分配给EC2实例：

```sh
AWS -> Elastic IPs -> Allocate New Address -> Associate Address
```

### Route 53

AWS同时提供domain代理服务，可以通过route 53注册域名，方便在上面配置DNS A/CNAME记录等，已有域名的忽略。

### 安装环境

OpenJDK Java 7：

```sh
sudo add-apt-repository ppa:openjdk-r/ppa # if in Ubuntu 16.04
sudo apt-get update
sudo apt-get install openjdk-7-jdk

```

Oracle Java 8:

```sh
sudo add-apt-repository ppa:webbupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
```

Java版本选择：

```sh
sudo update-alternatives --config java
```

Tomcat 7:

``` sh
sudo apt-get update
sudo apt-get install tomcat7
sudo apt-get install tomcat7-docs tomcat7-admin tomcat7-examples # 如果需要
```

Nginx 1.10.0:

```sh
sudo apt-get update
sudo apt-get install nginx
```

Tomcat配置文件在`/var/lib/tomcat7/conf`下，在server.xml里可以配置端口、HTTP相关；Nginx配置文件在`/etc/nginx`下，nginx.conf可以配置反向代理、负载均衡、动静分离等，这篇文章不讨论具体服务器配置问题。

### 系统时区

阿里云默认没记错应该是中国标准时间CST，AWS是UTC，Cron任务是根据系统时间走的，通过下面配置系统时区：

```sh
sudo dpkg-reconfigure tzdata
date
```

### 系统监控

AWS提供UI监控各项指标，还可以设定监控报警，自己也可以在Ubuntu下安装htop实时监控：

```sh
sudo apt-get install htop
htop
```

htop包括了对多核CPU的百分比使用，内存百分比占用，和各进程的占用比。

### 系统扩展

t2.micro肯定不够用的，EC2可以直接垂直升级到功能更好的机器，当然单机永远有局限，创建多个实例水平扩展又是一个大内容了。