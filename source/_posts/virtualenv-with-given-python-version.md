---
title: Virtualenv使用指定Python版本
date: 2017-02-04 01:54:46
categories: Tech
---

Virtualenv默认使用系统python版本，但在某些project我们想用另外一个版本的python，virtualenv在创建环境时可以选择已安装的python版本，但在某些情况下我们没有root权限，可以选择在用户本地安装一个python版本来创建环境。

<!-- more -->

#### 使用系统版本

```sh
virtualenv -p /usr/local/bin/python3 env
```

#### 使用本地版本

以Python 3.5.3举例，安装条件[httpie](https://github.com/jkbrzt/httpie), [virtualenv](https://virtualenv.pypa.io/en/stable/)。

```sh
# install local python
cd ~ && mkdir -p ~/.localpython/3.5.3
http --download https://www.python.org/ftp/python/3.5.3/Python-3.5.3.tgz
tar -zxvf Python-3.5.3.tgz
cd Python-3.5.3
./configure --prefix=$HOME/.localpython/3.5.3
make
make install
cd ~ && rm Python-3.5.3.tgz && rm -rf Python-3.5.3

# create virtualenv with local python
cd /path/to/project
virtualenv -p ~/.localpython/3.5.3/bin/python3.5 env
source env/bin/activate
python --version
deactivate
```



