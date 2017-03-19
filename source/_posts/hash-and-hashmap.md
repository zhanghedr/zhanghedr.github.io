---
title: Hash 与 HashMap
date: 2017-03-18 21:26:47
categories: Tech
---

Hash在软件领域有非常多的应用， 最熟悉的莫过于HashMap，还有MD5/SHA-1哈希算法等，这里主要讲一下hash函数特性和Java中的HashMap原理。

<!-- more -->

### Hash函数

Hash(散列)函数将任何长度的数据映射成固定长度的数据，是不可逆的。其最重要的特征是**防碰撞能力**，即对任意两个不同的数据输入，其输出hash值相同的概率非常小，近似为零，所以想用brute-force找出一个与某数据hash值相同的数据是非常困难的 。并且对于输入数据稍微改动一位，其hash值就会改动很大。贴一段Java 8中hashCode源码：

```java
public int hashCode() {
    int h = hash;
    if (h == 0 && value.length > 0) {
        char val[] = value;

        for (int i = 0; i < value.length; i++) {
            h = 31 * h + val[i];
        }
        hash = h;
    }
    return h;
}
```

### MD5和SHA-1

所以hash最重要的就是防碰撞特性，那么hash函数实现的好坏就非常重要了。经典的hash函数实现有MD5和SHA-1加密算法，MD5输出128位，SHA-1输出160位，SHA-1是基于MD5的哈希算法。他们最重要的应用之一就是文件或和据校验，比如下载软件会告诉你一个MD5哈西值，下载后你可以用`md5sum`监测其MD5值是否和网站给的值相同，用以监测文件的完整性，因为只要任意改动文件一处，那么MD5值就是完全不同。

但要注意MD5和SHA-1因为年代久远都已经不再安全，[2017年Google宣布实际破解了SHA-1算法](https://security.googleblog.com/2017/02/announcing-first-sha1-collision.html)，两个PDF文件产生了相同的hash值，实现了碰撞，那么也就是说攻击者有可能用hash值相同的恶意文件冒充原文件，SHA-1在互联网上有那么多的应用该怎么办呢，甚至包括了数字证书签名、GIT/SVN等。首先SHA-1也不是谁都能破解的，也就是Google这么强大的计算能力才做到了，但是为了避免以后潜在的安全漏洞，Google推荐使用更加安全的SHA-256算法。

### HashMap

HashMap作为hash函数的经典应用和Java最常用的数据结构之一，其实现非常有学习意义，这里以**Java 7**为例，注意Java 8里改动提升了很多且使用了tree，下面的某些地方可能不太适用。首先看一下HashMap的时间复杂度，其中n为entry的个数：

| Action | Average | Worst |
| :----- | ------- | ----- |
| Search | O(1)    | O(n)  |
| Insert | O(1)    | O(n)  |
| Delete | O(1)    | O(n)  |

HashMap最著名的就是其平均O(1)的时间复杂度，这正是利用了hash函数的特性，HashMap是一个buckets(table)数组，index是key的hash值，对于不同的object产生不同的hash值快速锁定其index，而不需要遍历比较。而每个bucket是一个entry的单向链表(非ArrayList和LinkedList)，数组每个元素即为链表head，至于为什么桶里是一个链表而不是单个entry是因为hash函数存在碰撞可能，hash碰撞后还需要通过equals()判断然后放在同一个桶里，理想情况是entry均匀的分布在各个桶里。理论上确实存在最坏情况O(n)，如果用一个所有对象都生成一个hash值的hash函数，那么只会有一个桶即一个链表保存所有entry。

首先看一下链表node(entry)的结构：

```java
static class Entry<K,V> implements Map.Entry<K,V> {
    final K key;
    V value;
    Entry<K,V> next;
    int hash;
}
```

然后下面是查找相关的函数：

```java
public V get(Object key) {
    if (key == null)
        return getForNullKey();
    Entry<K,V> entry = getEntry(key);

    return null == entry ? null : entry.getValue();
}

public boolean containsKey(Object key) {
    return getEntry(key) != null;
}

final Entry<K,V> getEntry(Object key) {
    int hash = (key == null) ? 0 : hash(key);
    for (Entry<K,V> e = table[indexFor(hash, table.length)];
         e != null;
         e = e.next) {
        Object k;
        if (e.hash == hash &&
            ((k = e.key) == key || (key != null && key.equals(k))))
            return e;
    }
    return null;
}
```

可以看到`getEntry(Object key)`这里面首先通过key的hash值找到table的index，然后通过head遍历链表直到找到key equals的entry为止，`get(Object key)`和`containsKey(Object key)`基本就是基于这个函数实现的。

然后就是`put(K key, V value)`，实现和getEntry大同小异，主要区别就是先遍历链表查找有没有相同的key，如果有替换并返回，如果没有则插入链表head新的entry，主要的两个方法如下：

```java
public V put(K key, V value) {
    if (key == null)
        return putForNullKey(value);
    int hash = hash(key);
    int i = indexFor(hash, table.length);
    for (Entry<K,V> e = table[i]; e != null; e = e.next) {
        Object k;
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
            V oldValue = e.value;
            e.value = value;
            e.recordAccess(this);
            return oldValue;
        }
    }

    modCount++;
    addEntry(hash, key, value, i);
    return null;
}

void createEntry(int hash, K key, V value, int bucketIndex) {
    Entry<K,V> e = table[bucketIndex];
    table[bucketIndex] = new Entry<>(hash, key, value, e);
    size++;
}
```

这里同时实现了insert，接下来就剩delete了，remove操作和上面类似，区别是要查找并删除entry，删除entry需要前后两个指针：

```java
public V remove(Object key) {
    Entry<K,V> e = removeEntryForKey(key);
    return (e == null ? null : e.value);
}

final Entry<K,V> removeEntryForKey(Object key) {
    int hash = (key == null) ? 0 : hash(key);
    int i = indexFor(hash, table.length);
    Entry<K,V> prev = table[i];
    Entry<K,V> e = prev;

    while (e != null) {
        Entry<K,V> next = e.next;
        Object k;
        if (e.hash == hash &&
            ((k = e.key) == key || (key != null && key.equals(k)))) {
            modCount++;
            size--;
            if (prev == e)
                table[i] = next;
            else
                prev.next = next;
            e.recordRemoval(this);
            return e;
        }
        prev = e;
        e = next;
    }

    return e;
}
```

那么从上面的源码来看，只要hash碰撞概率低，那么这些操作都是近似O(1)，事实上也确实如此，至于为什么bucket选择用单向链表，可以考虑单向链表的`Search/Insert/Delete`时间复杂度分别是`O(n)/O(1)/O(1)`，其空间复杂度为O(n)，综合来看是非常好的。

可以看出如果一个类如果作为HashMap的key，那么其hashCode()的实现防碰撞和速度就很重要了。并且key最好是不可变的对象，要不然修改了某个属性后可能就找不到了。注意如果在iterator创建后改变了collection结构，那么iterator会抛出`ConcurrentModificationException`异常。下面是其他几种常见map实现：

- **ConcurrentHashMap**: 用于多线程的HashMap，HashMap本身线程不安全
- **EnumMap**: 用enum作为key的Map
- **LinkedHashMap**: 可预知迭代顺序的HashMap (可以用来实现LRU)
- **TreeMap**: 基于SortedMap接口，使用key的Comparable排序或者提供Comparator

如果对Java 8的HashMap优化感兴趣，可以参考美团的[文章](https://zhuanlan.zhihu.com/p/21673805)。