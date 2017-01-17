---
title: Lambda表达式
date: 2017-01-16 14:43:36
categories: Tech
---

Lambda表达式指的是**匿名函数**，当你只需要运行一次或若干次一个不是很复杂的函数时，可以考虑使用lambda，它不需要名字还能减少代码量，并且可以作为一个变量传入到另一个函数中。这种函数源自functional programming languages，每种语言对于lambda的支持不尽相同，本文讲一下lambda在Java 8和Python 3中的基本用法。

<!-- more -->

# Java 8 Lambda Expressions

lambda是Java 8中的重要特性，这里举几个例子讲下基本用法。

Runnable用来创建thread时需要override run()方法，下面这个例子通过lambda一行就搞定了。

```java
// old runnable
Runnable r1 = new Runnable() {
  @Override
  public void run() {
    System.out.println("normal runnable");
  }
};

// lambda runnable
Runnable r2 = () -> System.out.println("lambda runnable");

r1.run();
r2.run();

// or new lambda thread
new Thread(
  () -> System.out.println("lambda new thread")
).start();
```

追溯到Runnable接口可以看到Java 8新增了@FunctionalInterface的注解，这样你在用第一种Runnable方法的时候IDE就会提示warning更换成lambda，而且如果你在@FunctionalInterface里有多个没覆盖的abstract方法，compiler就会报错了。

再看看下面这个Collections倒序例子，为了举例lambda使用Comparator而不使用reverse(list)，这里的Comparator也有@FunctionalInterface注解。

```java
Integer[] arr = {1, 2, 3, 4, 5, 6};

// old Comparator
List<Integer> list = Arrays.asList(arr);
Collections.sort(list, new Comparator<Integer>() {
  @Override
  public int compare(Integer o1, Integer o2) {
    return o2.compareTo(o1);
  }
});
System.out.println(list);

// lambda Comparator
list = Arrays.asList(arr);
Collections.sort(list, (Integer o1, Integer o2) -> o2.compareTo(o1));
System.out.println(list);
```

下面这个是遍历例子。

```java
List<Integer> list = Arrays.asList(1, 2, 3, 4, 5, 6);

// old iteration
for (Integer n : list)
  System.out.println(n);

// new iteration
list.forEach(n -> System.out.println(n));
```

Java 8新增了包java.util.stream和java.util.function，提供了map方法来处理传入Function、filter方法处理Predicate条件、reduce方法处理BinaryOperator，从而更方便的处理Collection数据，看下面的例子。

```java
List<Integer> list = Arrays.asList(1, 2, 3, 4, 5, 6);

// old iteration
for (Integer n : list)
  System.out.println(n + 10);

// lambda map
list.stream().map((n) -> n + 10).forEach(n -> System.out.println(n));

// lambda map + filter
list.stream().map((n) -> n + 10).filter(n -> n % 3 == 0).forEach(n -> System.out.println(n));

// lambda map + filter + reduce
int sum = list.stream().map((n) -> n + 10).filter(n -> n % 3 == 0).reduce((a, b) -> a + b).get();
System.out.println(sum);
```

可以看出新lambda特性很强大，让Java的代码更简洁更可读了，但毕竟是函数编程思想，还需要一定的适应时间。

# Python 3 Lambda Expressions

Python的语法比较灵活，其实在很多情况下不用lambda也能用很短的代码实现。注意在Python 3中对很多遍历iterable的方法进行了优化，返回的是iterator可以直接遍历，所以这里用到了list()，Python 2的话不需要加，下面针对map, filter和reduce举例。

首先是map计算加一。

```python
# function way
def plus(n):
    return n + 1
[plus(n) for n in range(3)]

# lambda way
list(map(lambda n : n + 1, range(3)))

# list comprehension
[n + 1 for n in range(3)]
```

然后是filter过滤掉奇数。

```python
# function way
def isEven(n):
    return n % 2 == 0
list(filter(isEven, range(6)))

# lambda way
list(filter(lambda n : n % 2 == 0, range(6)))

# list comprehension
[n for n in range(6) if n % 2 == 0]
```

接着是reduce求和，注意Python 3中已经把reduce放到functools中了，不再是built-in方法，需要import。

```python
from functools import reduce

# function way
def sum(a, b):
    return a + b
reduce(sum, range(6))

# lambda way
reduce(lambda a, b : a + b, range(6))

# list comprehension
# reduce不推荐用这个方法
```

