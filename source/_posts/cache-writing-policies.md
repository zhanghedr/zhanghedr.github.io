---
title: Cache写机制
date: 2017-03-08 08:25:32
categories: Tech
---

Cache的写机制有两种，分别是`Write Through`和`Write Back`，一般指硬件磁盘读写，但也可用于软件cache实现，比如DAL。

<!-- more -->

### Write Through

在写的时候，同时更新cache和磁盘，这里可以理解为cache和数据库，这样数据库和缓存内容始终保持一致，这种方式实现简单一致性好，但效率一般。下流程图说明了这个过程，图片引用自[wikipedia](https://en.wikipedia.org/wiki/Cache_(computing))。

![](https://upload.wikimedia.org/wikipedia/commons/0/04/Write-through_with_no-write-allocation.svg)

### Write Back

也称作write-behind，在写的时候只写cache而延后写数据库，从而减少数据库的I/O而获得更好的性能。在延后写数据库之后这个cache标记为dirty，然后有两种情况，第一种是这个cache过期或LRU被踢掉了，那么它在invalidate时必须将它的最新内容写回到数据库中，保证数据一致；第二种情况是这个cache被新的写操作给替换了，这时可以选择继续延后写数据库，而始终保持cache内容最新，如果在更新非常频繁的内容上，可以在这部分cache延迟写多个周期后，再同步到数据库里。

这种方法效率更高，但实现复杂，而且存在cache和数据库不一致问题，如果系统宕机可能造成数据丢失。

![](https://upload.wikimedia.org/wikipedia/commons/c/c2/Write-back_with_write-allocation.svg)