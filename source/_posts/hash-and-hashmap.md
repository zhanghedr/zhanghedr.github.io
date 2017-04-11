---
title: Hash 与 HashMap
date: 2017-03-18 21:26:47
categories: Tech
---

Hash函数在软件领域有非常多的应用， 最熟悉的莫过于HashMap，这里主要讲一下hash函数特性和Java中HashMap原理，同时比较下HashMap和Hashtable区别。

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

### HashMap

HashMap作为hash函数的经典应用和Java最常用的数据结构之一，其实现非常有学习意义，这里以**Java 7源码**为例，注意Java 8里改动提升了很多且使用了tree，下面的某些地方可能不太适用。首先看一下HashMap的时间复杂度，其中n为entry的个数：

| Action | Average | Worst |
| :----- | ------- | ----- |
| Search | O(1)    | O(n)  |
| Insert | O(1)    | O(n)  |
| Delete | O(1)    | O(n)  |

HashMap最著名的就是其平均O(1)的时间复杂度，这正是利用了hash函数的特性，HashMap是一个buckets(table)数组，index是key的hash值，对于不同的object产生不同的hash值快速锁定其index，而不需要遍历比较。而每个bucket是一个entry的单向链表(非ArrayList和LinkedList)，数组每个元素即为链表head，至于为什么桶里是一个链表而不是单个entry是因为hash函数存在碰撞可能，hash碰撞后还需要通过equals()判断然后放在同一个桶里，理想情况是entry均匀的分布在各个桶里。理论上确实存在最坏情况O(n)，如果用一个所有对象都生成一个hash值的hash函数，那么只会有一个桶即一个链表保存所有entry。

首先看一下链表node(entry)的结构和hash函数：

```java
static class Entry<K,V> implements Map.Entry<K,V> {
    final K key;
    V value;
    Entry<K,V> next;
    int hash;
}

final int hash(Object k) {
    int h = 0;
    if (useAltHashing) {
        if (k instanceof String) {
            return sun.misc.Hashing.stringHash32((String) k);
        }
        h = hashSeed;
    }

    h ^= k.hashCode();

    // This function ensures that hashCodes that differ only by
    // constant multiples at each bit position have a bounded
    // number of collisions (approximately 8 at default load factor).
    h ^= (h >>> 20) ^ (h >>> 12);
    return h ^ (h >>> 7) ^ (h >>> 4);
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

- **ConcurrentHashMap**: 用于多线程的HashMap
- **EnumMap**: 用enum作为key的Map
- **LinkedHashMap**: 可预知迭代顺序的HashMap (可以用来实现LRU)
- **TreeMap**: 基于SortedMap接口，使用key的Comparable或者提供的Comparator排序

如果对Java 8的HashMap优化感兴趣，可以参考美团的[文章](https://zhuanlan.zhihu.com/p/21673805)。

### HashMap vs Hashtable

不同点：

1. HashMap不是synchronized，而HashTable是synchronized的，HashMap非线程安全，但在单线程程序有更好性能
2. HashMap允许1个null key和多个null value，而Hashtable都不允许
3. Hashtable继承Dictionary是遗留类不再使用，单线程用HashMap，如果多线程可以用ConcurrentHashMap
4. HashMap迭代器iterator是fail-fast，而Hashtable迭代器enumerator不是

相同点：

1. 都基于hash实现
2. 都实现了Map接口
3. 都是无序
4. 时间复杂度都是常数