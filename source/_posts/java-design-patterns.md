---
title: 常见 Java 设计模式
date: 2016-12-20 01:47:26
categories: Tech
---
设计模式（Design Patterns）是一套被反复使用、代码设计经验的总结。设计模式有很多原则，比如降低耦合、简单化类、接口隔离等，都是为了提高代码复用率、代码可读性和代码可靠性。本文介绍常用Java设计模式以及代码实例，持续更新中。

<!-- more -->

# Behavioral模式


## Observer
### 介绍
设计对象一对多的依赖关系，当一个主对象改变状态时，它所有的观察者都会被通知并且更新。在使用时注意observer同为observable的链和thread safe。

### 使用场景
常见的有RSS feed，多个subscribers订阅一个RSS feed，当publisher有更新时所有的订阅者都会自动收到更新。又或者是UI里的button触发它所有的listeners更新。还有Java SE里的java.util.Observer和java.util.Observable。

### 代码和结构图
以publisher->subscribers为例子的**[代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/observer)**
![](/img/java_design_patterns/observer.png)


<!-- ## Iterator
![](/img/java_design_patterns/iterator.png) -->