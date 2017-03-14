---
title: N + 1 问题
date: 2017-03-13 22:43:49
categories: Tech
---

在数据库中经常会碰到不同表之间关联的问题，为了防止单表过大字段过多，通常会通过表id将两个表联系起来，可以是一对一或者一对多的关系。API中也经常需要调用到多个表的信息，用惯了ORM简洁的调用方式后，代码中可能会出现N + 1问题。

<!-- more -->

假设一个社区网站的信息流首页，要显示用户关注的最新帖子(thread)列表，在每个列表条目中要显示thread标题和作者username，那么N + 1问题就在于用ORM先读取了所有threads，然后根据thread表中的user_id在user表中循环找username如下：

``` Python
threads = Thread.objects.all().order_by("-create_time")
for thread in threads:
	user = User.objects.get(id=thread.user_id)
```

这里只是举例Django ORM简单伪代码，不包括条件查找和分页问题，某些ORM若执行类似上面的代码会产生如下SQL:

```sql
SELECT title, user_id FROM thread WHERE ...
SELECT username FROM user WHERE id = 1
SELECT username FROM user WHERE id = 2
SELECT username FROM user WHERE id = 3
SELECT username FROM user WHERE id = 4
...
```

这样会生成N + 1条SQL，N是threads个数，即使都是用索引读取，数据库机器造成的网络开销时间还是不可忽视的。有时还不止是2个表关联，比如列表项中可能还要显示thread的tags和最新回复内容，那么就可能是3N + 1了。但是如果考虑到缓存，这样N条读取粒度很小，在流量高峰期时缓存命中率会很高，具体节省的时间还是要看benchmark才行。

当然ORM也会给出一些解决办法，这个基于不同ORM而异。这里说下最直观的两种解决方法，首先是提取出threads的user_id set，然后用IN (set)去读取user表，就变成了总共2条SQL语句如下：

``` sql
SELECT title, user_id FROM thread WHERE ...
SELECT username FROM user WHERE id IN (1, 2, 3, 4 ...)
```

另外一种就是用JOIN了：

``` sql
SELECT t.title, u.username FROM thread t
LEFT JOIN user u ON t.user_id = u.id
WHERE ...
```

这样只有一条SQL，甚至可以JOIN更多的表，当然JOIN能不用尽量不用，会影响到性能。