---
title: 常见 Git 命令清单与使用
date: 2016-12-10 00:27:47
categories: Tech
---
Git的指令很多，每次都上stackoverflow搜答案，不如把常用的命令都记录下来。下图很好的解释了git的原理，结合本文的常用指令能在1小时内搞明白git的大致用法，当然这些还是要结合实际使用才会熟练。

![](/img/git_cheat_sheet/git.png)

<!-- more -->

首先解释一下这几个名词：
- workspace/working dir : 本地工作区
- index/stage           : 暂存区
- local repository      : 本地仓库
- remote repository     : 远程仓库
- HEAD                  : 当前分支指针
- origin                : 默认远程
- master                : 本地分支master
- origin master         : 远程origin上的master
- origin/master         : origin master的本地copy


## 常用命令

### 新建本地仓库
``` sh
git init                                    # 初始化local repo
git clone URL                               # checkout remote repo
git clone username@host:URL                 # 在remote server上checkout远程仓库
```

### Config
``` sh
git config --list                           # 查看配置，包括当前name和email
git config [--global] user.name [name]      # 设置name
git config [--global] user.email [email]    # 设置email
```

### Add/Remove
``` sh
git add [file1] [file2] ...                 # 添加文件至index
git add [dir]                               # 添加目录至index
git add .                                   # 添加所有除了删除以外的更改文件到index
git add -A                                  # 添加所有更改文件到index
git rm [file1] [file2] ...                  # 删除working dir和index文件
git rm --cached [file]                      # 删除index文件，但保留working dir
```

### Commit
``` sh
git commit -m [message]                     # 提交index到local repo
git commit -am [message]                    # add + commit到local repo
git commit --amend -m [message]             # 修改上次commit
```

### Push
``` sh
git push origin master                      # 上传local repo到remote master
git push [remote] [branch]                  # 上传branch到remote repo
git push [remote] --all                     # 上传所有branch到remote repo
```

### Branch
``` sh
git branch                                 # 列出所有local branch
git branch -r                              # 列出所有remote branch
git branch -a                              # 列出所有local和remote branch
git branch --merged                        # 显示所有已合并到当前分支的分支
git checkout [branch]                      # working dir切换到branch 
git checkout -b [branch]                   # 基于当前branch新建并切换到新branch
git branch [branch]                        # 新建branch但不切换到新branch
git merge [branch]                         # 合并branch到当前分支
git branch -d [branch]                     # 删除branch
git push origin --delete [branch]          # 删除remote branch
```

### 远程同步
``` sh
git remote                     # 显示当前所有remote
git remote show [remote]       # 显示remote信息
git remote add [remote] [URL]  # 为本地添加一个新的remote
git fetch                      # 获取所有origin分支到origin/master，working dir不变
git merge                      # 合并origin/master到master，working dir改变
git pull [remote] [branch]     # 获取远程分支且合并到当前分支. git pull = git fetch + git merge
```

### 日志
``` sh
git log                                  # 显示本地提交日志，git pull后更新远程日志
git log --stat                           # 显示提交日志及相关变动文件
git log --pretty=format:'%h %s' --graph  # 图示提交日志
git log --follow [file]                  # 显示文件提交日志
git show [commit]                        # 显示commit日志by commitid(缩写也可以)
git show HEAD                            # 显示HEAD commit日志
git show origin/master                   # 显示origin/master commit日志
```

### 状态
``` sh
git status                       # 显示working dir所有修改过的文件
git diff                         # 显示working dir和index差异
git diff --cached                # 显示index和HEAD的差异
git diff HEAD                    # 显示working dir和HEAD差异
```

### 撤销
``` sh
git checkout [commit]           # 切换working dir到某个commit
git checkout [commit] [file]    # 恢复working dir的文件到某个commit
git checkout [file]             # 恢复index文件到working dir
git checkout .                  # 恢复所有index文件到working dir
git reset [file]                # 重置index和local repo里的文件，working dir不变
git reset HEAD~1                # 重置index和local repo到上一个commit，working dir不变
git reset [commit]              # 重置index和local repo到某个commit，working dir不变
git reset --hard HEAD~1         # 重置index, local repo和working dir到上一个commit，本地改变丢失
git reset --hard [commit]       # 重置index, local repo和working dir到某个commit，本地改变丢失
git reset --hard origin/master  # 重置index, local repo和working dir到master，本地改变丢失
```

### 其他
``` sh
git stash                        # 暂存当前修改，将working dir至为HEAD状态
git stash list                   # 查看所有暂存
git stash pop                    # 提取暂存到working dir，如有冲突需手动merge
```

## 常见场景
### 保留本地改动同步远程master，pull完再merge冲突
``` sh
git stash; 
git pull --rebase origin master; 
git stash pop
```

### 撤销上次commit
``` sh
git commit -m "Something wrong"
git reset HEAD~1   # HEAD~1重置index和local repo到上一次commit，最新的commit取消
git status         # undo以后再查看本地改动
git add -A
git commit -m "message" 
```

### 修改上次commit的message和add新改动
``` sh
git reset; 
git commit --amend -m [message]  # 注意会把working dir最新改动也加进去
```

### 显示本地和远程origin的区别
``` sh
git fetch
git diff ..origin
```

### 重置本地working dir、index、local repo到远程最新commit，抛弃本地改动
``` sh
git fetch
git reset --hard origin/master
```

### Pull Request流程

```sh
fork原始仓库
git clone [URL]  # 抓取fork的仓库
git remote add upstream [URL]  # 添加原仓库remote URL，如命名upstream
git checkout -b [patch]  # 基于当前分支新建patch分支
touch test  # 在patch下开发
git checkout master && git pull upstream master  # 更新原仓库master
git checkout [patch] && git merge master  # 合并到patch并解决冲突
git add . && git commit -m "update" && git push origin [patch]  # 提交改动到自己仓库的patch分支
pull request patch branch in github
wait response
```

