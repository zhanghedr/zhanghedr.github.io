---
title: 理解与优化MySQL索引
date: 2017-03-04 00:44:08
categories: MySQL
---

大家知道添加索引`index(key)`是最常见的MySQL速度优化方法之一，数据库会找到提前准备好的搜索条件对应数据位置，从而避免了对整个表的全局搜索，可以理解为从`O(n)`到`O(logn)`的提升。可以想象这在对于越大的表越有效果，在实际中也确实如此，如果在上千万条数据的表中没有命中索引那读取速度将非常慢，对于这种表在考虑分表前，不妨先进行索引优化、硬件升级、增加缓存等，本文探讨MySQL索引，从而优化命中率。

<!-- more -->

MySQL主要的索引包括`PRIMARY KEY` `INDEX` `UNIQUE INDEX`，索引存储在[B-tree](https://en.wikipedia.org/wiki/B-tree)(基于[binary search tree](https://en.wikipedia.org/wiki/Binary_search_tree))中，它会在以下操作中用到索引：

1. WHERE里对应的单列或多列索引。
2. 组合索引的使用，比如3个column的索引`(col1, col2, col3)`，会命中这三种搜索条件组合`(col1)` `(col1, col2)` `(col1, col2, col3)`，也就是越左优先级越高。
3. `ORDER BY`和`GROUP BY`语句与WHERE类似，对于组合索引也是最左优先。
4. 在JOIN时，类和大小相同的column索引会更加有效，比如`VARCHAR(50)`和`VARCHAR(55)`大小不同。比如int 1和string的'1'比较前必须经过转换，这会让MySQL miss索引。
5. 用`function(indexed column)`会miss索引，比如`MONTH(indexed date)`。但方法`MIN(indexed column)`和`MAX(indexed column)`会命中索引。
6. 如果有多条索引可以查询，选择查询范围最小的index。

MySQL表对于索引大小有限制，所以优化不是简单的把每个column都加上索引，如果使用了多列索引可以把不必要的单列索引删除。设计好一个表是第一步，表合理的结构、数据类和大小的选择，比如tinyint/smallint/mediumint/int/bigint和varchar(size)，然后就是如何创建合理的索引来满足最常用的业务需求，从而提高索引命中率。