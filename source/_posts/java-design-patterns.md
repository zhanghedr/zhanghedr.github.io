---
title: 常见 Java 设计模式
date: 2016-12-20 01:47:26
categories: Tech
---
设计模式（Design Patterns）是一套被反复使用、代码设计经验的总结。设计模式有很多原则，比如降低耦合、简单化类、接口隔离等，都是为了提高代码复用率、代码可读性和代码可靠性。当然其中一些模式可能到了其他语言里就失效了，比如python基于语言的特性某些设计模式会有其他的解决方法，但是学习这些模式肯定还是有帮助的，在现实中没必要刻意去套用模式，最终还是简洁有效的code最好。本文介绍常用Java设计模式以及代码实例。

<!-- more -->

​     	

# Behavioral模式

## Observer
### 介绍
设计对象一对多的依赖关系，当一个主对象改变状态时，它所有的观察者都会被通知并且更新。在使用时注意observer同为observable的链和thread safe。

### 使用场景
常见的有RSS feed，多个subscribers订阅一个RSS feed，当publisher有更新时所有的订阅者都会自动收到更新。又或者是UI里的button触发它所有的listeners更新。还有Java SE里的java.util.Observer和java.util.Observable。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/observer)和结构图
以publisher->subscribers为例子。
![](/img/java_design_patterns/observer.png)

​      

## Iterator

### 介绍
提供一种实现好的方式来迭代一个集合和访问其中的元素，可以自己定义基于不同条件的迭代方式。

### 使用场景
当需要给一个集合提供一种标准化的迭代方式时，比如java.util.ArrayList和java.util.Scanner

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/iterator)和结构图
实现了一个基本的iterator和一个基于group的iterator。
![](/img/java_design_patterns/iterator.png)

​     

## strategy

### 介绍
提供一个协议将算法封装起来，让client可以在runtime动态的选择执行某种算法。其封装思想和facade有点类似，但是strategy提供了选择哪个类执行的接口，而facade是将所有的类型都封装起来不在runtime改变。

### 使用场景
当有一个类下的多种算法需要动态选择去执行时，可以通过strategy模式将这个类封装起来，让client根据需求改变和执行其中一种算法。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/strategy)和结构图
用StrategySelector将Strategy封装，用contrustor或者setter来在runtime选择用哪个类的execute()方法。
![](/img/java_design_patterns/strategy.png)

​     

## template

### 介绍
定义一个程序skeleton的算法，保证算法步骤结构不变，让子类继承重新定义其中的某些步骤来实现不同的算法。

### 使用场景
当有一个算法有固定的步骤时，某些步骤根据需求不同，可以让不同类继承这个类来重新定义其中某些步骤，从而重新定义了算法。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/template)和结构图
有一个strategy的模板，有两种类型的策略继承它，重定义其中的init(), calculate()和finish()，从而实现了不同的子策略算法。
![](/img/java_design_patterns/template.png)

​     

# Creational模式

## Singleton
### 介绍
限制一个类在系统中只能创建一个对象。

### 使用场景
当只需要一个对象时，比如abstract factory、builder模式中，还有java.lang.Runtime里实现了。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/singleton)和结构图
包含各种基本和完善的singleton实现。
![](/img/java_design_patterns/singleton.png)

​     

## factory

### 介绍
非常常见的创建对象模式，用于创建一个类型下的不同类对象。工厂类基于参数创建不同对象，将创建对象和client code隔离开来。

### 使用场景
当一个类有很多子类时，让client创建对象时不需要知道其中的细节，比如java.util.Calendar。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/factory)和结构图
基于三种水果类创建的工厂模式。
![](/img/java_design_patterns/factory.png)

​     

## abstract factory

### 介绍
工厂的工厂，超级工厂用于创建子工厂来创建相关的类对象。

### 使用场景
当多个类相关联时，同时每个类下都有不同子类，用抽象工厂来创建不同工厂对应每条产品线，每个子工厂然后再创建对应产品线上的不同子类对象。同时client不知道创建对象的具体细节。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/abstractfactory)和结构图
假设厨房有食物和水果两个类，厨房1工厂创建披萨和蓝莓，厨房2工厂创建面条和苹果，从而实现了多个工厂对于不同产品线不同子类的创建。
![](/img/java_design_patterns/abstractfactory.png)

​     

## builder

### 介绍
用于创建复杂类对象，借助builder类来动态创建对象同时保证复杂类的不变性。

### 使用场景
当一个复杂类有非常多变量时，不一定每个变量对于创建都是必须的，这时候不想对于每种组合可能性都给一个constructor，而又想保证其不变性，就可以借助builder来灵活的创建其对象，比如java.lang.StringBuilder。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/builder)和结构图
一个用户有非常多的属性，其中只有名字和邮箱是必须的，其他都是可选，而且保证User是final，这时用一个内置的UserBuilder类来动态set每一个optional变量，然后通过builder来创建User。
![](/img/java_design_patterns/builder.png)

​     

# Structural模式

## decorator
### 介绍
用于在不改变已有类的基础上给其动态添加新功能实现功能扩展。

### 使用场景
在需要不改变类的基础上对其进行不同的功能扩展时，可以动态的对这种类添加不同的功能，而不需要继承多个类来实现不同的功能组合。例子有BufferedReader input = new BufferedReader(new InputStreamReader(System.in));

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/decorator)和结构图
装饰器封装了User，然后对一个中国用户的属性进行描述，他可以是年轻或老，可以是男或女，这些额外属性描述的功能通过扩展装饰器来实现其单独的功能，然后我们就可以通过装饰器动态的给User添加不同的描述了。
![](/img/java_design_patterns/decorator.png)

​     

## adapter

### 介绍
就像其名字一样，用于将两个接口连接在一起让client使用。

### 使用场景
有些时候一个interface没法直接使用，可以通过adapter进行接口转换从而正常使用。比如java.util.Arrays#asList()将多个String通过Arrays转换成List。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/adapter)和结构图
因为最近出了2016 Macbook Pro是不带USB接口的，我们需要买一个TypeC/USB转换器来连接无线鼠标，蓝牙鼠标的请无视。这时我们只要借助PortAdapter来帮助WirelessMouse实现pluginUsb()，而在PortAdapter中我们用其typeC插口连接电脑的typeC端口。
![](/img/java_design_patterns/adapter.png)

​     

## facade

### 介绍
在复杂系统中将多个相关的类在一个facade类中包裹起来，提供一个high-level简单易用的接口给client，隐藏其中实现细节。

### 使用场景
当系统比较复杂时，有很多相关的类有不同的方法实现，这时可以用facade将它们涵盖进去提供统一简单的接口让client使用它们。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/facade)和结构图
3个国家的user有各自的具体属性，通过一个facade类将3种user都包括进去并且提供统一接口给client进行访问。
![](/img/java_design_patterns/facade.png)

​     

## proxy

### 介绍
对一种对象提供代理来控制它。

### 使用场景
当需要对一个类添加功能时，可以用proxy代理它的接口，让client使用proxy而不是真正的类。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/proxy)和结构图
用ProxyUser代理RealUser来玩游戏，在proxy中限制一个user玩游戏的次数。
![](/img/java_design_patterns/proxy.png)

​     

# Architectural模式

## MVC
### 介绍
用于设计GUI和web frameworks，将系统分为view, controller和model三个部分。

### 使用场景
MVC常用在web框架中，比如Spring MVC。

### [代码](https://github.com/zhanghedr/design-pattern/tree/master/src/main/java/com/zhanghedr/mvc)和结构图
假设从数据库拿到name和email形成user对象，然后经过controller控制让user属性在view中显示出来。
![](/img/java_design_patterns/mvc.png)
