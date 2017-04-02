---
title: 理解与优化MySQL索引
date: 2017-03-04 00:44:08
categories: MySQL
---

索引`index(key)`是最常见的MySQL速度优化方法之一，大部分数据库和文件系统都采用[B-tree](https://en.wikipedia.org/wiki/B-tree)和[B+tree](https://en.wikipedia.org/wiki/B%2B_tree)作为索引数据结构，简略来说使带有索引的查找时间复杂度为`O(logn)`，而避免了全表扫描`O(n)`，在数据量大的表中速度可以提升几个数量级，本文粗略的学习和探讨MySQL索引原理、数据结构与优化。

<!-- more -->

### 索引原理

索引是为了高效的查询数据，就像是一本字典通过目录快速找到对应的页，这样自然会想到binary search、binary search tree等，但索引也很大存在磁盘上，磁盘I/O消耗比内存要大得多，在查找时必须首先考虑减少磁盘I/O次数，同时优化时间复杂度，同时还不能忽略对写造成的影响，这样就需要具体考虑计算机存储原理来选择数据结构了。

### 数据结构

下面分别是wikipedia中的[B-tree](https://en.wikipedia.org/wiki/B-tree)和[B+tree](https://en.wikipedia.org/wiki/B%2B_tree)结构图：

![b-tree](/img/mysql_index/b-tree.png)

![b-tree](/img/mysql_index/b+tree.png)

B-tree和B+tree不同于`self-balancing binary search trees`在于：

- 每个node中包含m个数据项
- 每个node可以有m+1个指针和children
- 一个node中的数据项按key递增排序
- 每个指针对应的子节点数据项介于指针两边数据项之间

这样不同于一般的BST它的高度会非常低且展开会非常大，下面会谈到为什么这样会利于减少磁盘I/O，而MySQL又用B+tree作为索引数据结构，可以看到B+tree的不同点在于：

- 数据只保存在叶节点上，这样必须遍历树高度才能完成查找
- 所有的相邻叶节点增加了指针，从而方便的访问范围数据

可以看到对于每个节点只要用递归二分法查找即可，如果没找到就到对应指针的子节点递归，直到找到key或者没到到为null为止。BTREE每次访问节点消耗一次磁盘I/O而非每个数据项消耗一次，这样树高度越低越好，如果总数据项为N，每个节点的数据项为m，树高为h，那么`O(h) = O(log(m+1)N)`，这里m越大则高度越低，每一个节点看做一个page，而`m = page_size / data_size`，可以看到我们想在一个节点里放多的数据项，就要减少数据项的大小，也就是为什么要缩减字段大小原因，比如能用tinyint就不用int。这里因为B+tree非叶节点不包含真正数据只有key，也节省了空间增大了扇出拥有更好的性能。

### 引擎实现

MySQL有两种引擎MyISAM和InnoDB，MyISAM不支持binary log用的比较少，InnoDB对于每个table都需要一个主键，最好是自增的int主键，占空间小，且递增顺序在b+tree中逐一插入新数据，效率比较高。下图是张洋博客里的插图，非常清晰的描绘了InnoDB存储结构：

![innodb](/img/mysql_index/innodb.png)

所有的数据都在叶节点上，主键对应了完整的row数据，这样根据主键的查找效率非常高，但其他索引的数据项中只存储对应主键，这样其他索引需要先找到主键再搜索一次找到对应的数据。

### 索引使用与优化

MySQL索引包括`PRIMARY KEY` `INDEX` `UNIQUE INDEX`，索引又分单列索引和多列索引两种，许多人的误区是把所有查询的字段都单独加上索引就行了，首先过多的索引会占用很多空间，表对索引大小有限制，其次索引会影响写速度，INSERT/DELETE到索引字段都需要b+tree改动结构。

多列索引有一个**最左前缀原理**，3个column的索引`(col1, col2, col3)`，只会命中这三种搜索条件组合`(col1)` `(col1, col2)` `(col1, col2, col3)`，和部分命中 `(col1, col3)` 。

如何建索引应该结合业务来定，找出所有的表SQL或瓶颈SQL，进行`EXPLAIN`分析索引使用情况。下面主要讨论多列索引，假设有一个app.post表，记录了帖子的所有回复，这个表中有一个多列索引`key (thread_id, user_id, status)`，首先看表index：

``` sql
SHOW INDEX FROM app.post;
```

因为测试过类似表就直接写结果了，`EXPLAIN`的结果类似如下，`key_len`代表应用到的索引字段大小，type=ALL代表全表扫描。

```sql

| id | select_type | table | type  | possible_keys | key  | key_len | ref               | rows | Extra |
+----+-------------+-------+-------+---------------+------+---------+-------------------+------+-------+
|  1 | SIMPLE      | post  | const | key           | key  | 8       | const,const,const | 1    |       |
```

下面根据完整的多列索引查询，`key_len`会应用到所有三个字段，并且打乱WHERE顺序也是如此，因为MySQL根据索引对顺序进行了优化：

```sql
EXPLAIN SELECT * FROM app.post WHERE thread_id=512 AND user_id=12 AND status=0;
EXPLAIN SELECT * FROM app.post WHERE user_id=12 AND status=0 AND thread_id=512;
```

如果只用前两个索引，会用到前两个索引字段：

``` sql
EXPLAIN SELECT * FROM app.post WHERE thread_id=512 AND user_id=12;
```

如果只用第一和第三个，则只会用到第一个索引字段，因为缺失了第二个字段，会对thread_id找到的结果进行扫描查找status：

``` sql
EXPLAIN SELECT * FROM app.post WHERE thread_id=512 AND status=0;
```

如果只用后两个将用不到索引：

```sql
EXPLAIN SELECT * FROM app.post WHERE user_id=12 AND status=0;
```

如果分别使用，只有thread_id会用到索引，而user_id和status用不到：

```sql
EXPLAIN SELECT * FROM app.post WHERE thread_id=512;
EXPLAIN SELECT * FROM app.post WHERE user_id=12;
EXPLAIN SELECT * FROM app.post WHERE status=0;
```



总结如下：

- 多列索引最左前缀原则
- 索引不仅对SELECT有效，对UPDATE/DELETE同样有效
- 索引对于`ORDER BY`和`GROUP BY`在一定情况下有效
- 索引对于模糊、范围查找有效，包括< > BETWEEN IN AND OR LIKE等
- 索引对于函数表达式无效，比如MONTH(date)，这个容易忽略
- 索引对于小表作用不大
- 索引不适合主要为写操作的表
- 索引对于选择性`COUNT(DISTINCT(field))/COUNT(*)`小的字段效率较低
- 索引非越多越好，会减慢写入速度
- 每个字段用尽可能小的类型大小
- 在字段过长的情况下，可以用前缀索引

如理解有误的地方欢迎指正。

### 参考资料

张洋的博客 - [MySQL索引背后的数据结构及算法原理](http://blog.codinglabs.org/articles/theory-of-mysql-index.html)

美团博客 - http://tech.meituan.com/mysql-index.html