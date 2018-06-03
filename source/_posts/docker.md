---
title: Docker初识
date: 2018-06-02 18:40:15
categories: Tech
---

Docker是一个开源的容器框架，可以打包、发布、运行任何的应用，相比虚拟机更为轻量，虚拟机启动分钟级，而Docker启动秒级。

<!-- more -->

## 两个基本概念

### 镜像（Image）

Docker镜像核心是OS文件系统，如linux的root文件系统，还包括了运行参数，如环境变量、JDK，镜像是静态文件数据。

### 容器（Container）

**镜像和容器的关系，就像是Java中的类和实例**，容器是镜像的实例，可以被创建、启动、停止、删除等。

## Docker vs 虚拟机

- **虚拟机**：硬件虚拟，通过物理机来管理和共享硬件，实现了多个虚拟机隔离，每个虚拟机包括一个操作系统的完整副本，一台机器上可以运行多个虚拟机，启动慢但隔离性更好
- **Docker**：采用容器方式，共享了宿主机同一个操作系统内核，一个物理机或一个虚拟机上可以运行多个容器，启动快但隔离性更差

Docker的优势：

- **资源利用率更高**：因为共享了一个操作系统内核，在执行速度、内存更高效，因此一台物理机能运行更多应用
- **启动更快**：因为运行于宿主机操作系统内核，启动时间达到了秒级
- **环境一致性**：docker提供了除内核外完整的运行环境，镜像保证了在开发、测试、线上等多个环境一致
- **维护成本低**：镜像使容器复用更为容易，也使维护更加简单
- **弹性扩缩容**：在高峰低估明显的项目中，容器可以快速扩展和回收，应对短期高流量，低谷时缩容提高资源利用率
- **持续集成/测试/发布**：在多个测试环境并行的应用中，需要支持快速的扩缩容、构建和发布，docker满足了这种场景要求

## 常用命令

#### List all docker local images

```sh
docker images
```

#### Pull and tag image

```sh
docker pull registry.aliyuncs.com/v-image/redis  # default latest tag
docker tag registry.aliyuncs.com/v-image/redis redis  # tagging
```

#### Run a container by image name or id

```sh
docker run 0c95b8a497f3
```

#### Remove container by name

```sh
docker rm -f webserver
```

#### Remove image by name or id

```sh
docker rmi nginx
```

#### Docker container logs

```sh
docker logs name/id
```

#### Create and run container by yml files

```sh
docker-compose up -d  # by docker-compose.yml in current dir
docker-compose -f docker-compose.yml -f docker-compose-nginx.yml up -d
```

#### Docker execute command for container by id

```sh
docker exec -i -t {CONTAINER ID} /bin/bash
```

#### Docker container restart by name or id

```sh
docker start/stop/restart 1626246cc473
```

#### Inspect container

```sh
docker inspect 0b0d02212e12
```

#### Start containers by links dependencies order

```sh
docker start redis mysql nginx web
```

## 参考

[从零开始学习 Docker](https://www.jianshu.com/p/cf6e7248b6c7)

