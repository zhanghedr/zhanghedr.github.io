---
title: SQL JOIN 和 UNION
date: 2017-03-15 21:43:41
categories: MySQL
---

SQL里的`JOIN`还是很常用的，但是其中还分多种类型有时候临时会搞混，搜集整理了一些资料，这里通过简单例子区分一下，顺带提下`UNION`。如果把`JOIN`当做是垂直拆分的反向过程，那么`UNION`就是水平拆分的反向过程。

<!-- more -->

### JOIN

把两个表垂直合并，假设有左a和右b两个表，JOIN有以下几种类型：

- `INNER JOIN` 返回两个表的交集
- `LEFT JOIN` 返回a表所有rows，和匹配上的b表rows
- `RIGHT JOIN` 返回b表所有rows，和匹配上的a表rows
- `FULL JOIN` 返回两个表的并集
- `CROSS JOIN` 返回两个表的乘集，如a和b表都是10条记录，那么结果是100条

注意在MySQL中`INNER` `OUTER` `CROSS`都是被忽略的，`JOIN`在有`ON`条件时为`INNER JOIN`，在没条件时即是`CROSS JOIN`，而`OUTER`不需要写直接用`LEFT JOIN` `RIGHT JOIN` `FULL JOIN`就行了。

下图引用自[w3schools](https://www.w3schools.com/sql/sql_join_inner.asp)，代表INNER JOIN，也应该能明白其他方式的含义了。

![](https://www.w3schools.com/sql/img_innerjoin.gif)

下面是两个表的结构：

 ``` sql
table a    table b

id         id
------     ------
1          3
2          4
3          5
4          6
 ```

INNER JOIN例子：

```sql
SELECT * FROM a JOIN b ON a.id = b.id

id         id
------     ------
3          3
4          4
```

LEFT JOIN例子：

``` sql
SELECT * FROM a LEFT JOIN b ON a.id = b.id

id         id
------     ------
1          NULL
2          NULL
3          3
4          4
```

RIGHT JOIN例子：

```sql
SELECT * FROM a RIGHT JOIN b ON a.id = b.id

id         id
------     ------
3          3
4          4
NULL       5
NULL       6
```

FULL JOIN例子：

``` sql
SELECT * FROM a FULL JOIN b ON a.id = b.id

id         id
------     ------
1          NULL
2          NULL
3          3
4          4
NULL       5
NULL       6
```

CROSS JOIN例子：

``` sql
SELECT * FROM a JOIN b

id         id
------     ------
1          3
1          4
1          5
1          6
2          3
2          4
2          5
2          6
3          3
3          4
3          5
3          6
4          3
4          4
4          5
4          6
```

注意在实际使用中不要使用`*`，在JOIN匹配后如果一个表ON字段有重复，那么对应的表记录也会被重复，JOIN的条件ON字段一般是在索引上以保证速度，它会比subquery快，但是JOIN还是尽量少用。

### UNION

把相似的字段水平合并，UNION返回唯一的结果，UNION ALL返回有重复的结果。

``` sql
SELECT id FROM a
UNION
SELECT id FROM b

id         
------
1
2
3
4
5
6

SELECT id FROM a
UNION ALL
SELECT id FROM b

id         
------
1
2
3
4
3
4
5
6
```

