---
title: Java JDBC PreparedStatement 用法
date: 2016-12-06 23:15:33
categories: Tech
---
在不需要ORM的场景下，用Java对MySQL进行操作时会用到PreparedStatement，它可以预载SQL语句然后再动态设置其中变量。这篇文章讲一下通常需要注意的问题和在处理大量数据时的优化。

<!-- more -->

## General
这里列出几点通常要注意的地方
- 在循环执行PreparedStatement时，注意将只建一个instance在循环外，重复设置SQL中的变量，避免OutOfMemoryError错误
- 合理commit transactions，在需要的情况下使用conn.setAutoCommit(false)来手动commit，它的default是true，避免在每次execute时候就自动commit
- 在setAutoCommit(false)的情况下，如果抓到SQLException使用conn.rollback()来撤销当前的transaction
- 用close()关闭相关的resource，分别有ResultSet, PreparedStatement和Connection。Java 7+版本可以使用try-with-resources方式自动close

简单的代码example:
``` java
String sql = "...";
try (Connection conn = getDbConnection()) {
    conn.setAutoCommit(false);
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        // ps.setString();
        // ps.execute();
        conn.commit();
    } catch (SQLException e) {
        conn.rollback();
        throw e;
    }
} catch(SQLException e) {
    e.printStackTrace();
}
```

## Batch Update
在执行大量数据的写入时，比如上百万条记录，这时简单的用executeUpdate()进行逐条update会变得非常慢。这里需要用PreparedStatement.executeBatch()来进行批量写入，从而减少数据库的访问次数，极大的增加速度。注意对于大量数据要批量执行batch，否则会导致OutOfMemoryError，代码如下。
``` java
final int batchSize = 1000;
int count = 0;
for (String s : names) {
    ps.setString(1, s);
    ps.addBatch();

    if (++count % batchSize == 0) {
        ps.executeBatch();
        ps.clearBatch();
    }
}
ps.executeBatch(); 
```

注意executeBatch只能对于insert/update/delete使用，select不能使用。

## Conclusion
本文只是简单介绍了PreparedStatement用法，提高数据库速度还要看数据库本身的优化和SQL等。Java的PreparedStatement在设置变量时还是不怎么方便，还要注意?对应的顺序，但是有一些工具可以简化这个操作，大家可以搜一下。