---
title: Maven小结
date: 2018-05-21 22:56:35
categories: Java
---

Apache Maven基于POM(Project Object Model)文件，主要用于Java工程管理，极大简化了工程的构建过程，并标准化。

<!-- more -->

# POM

POM文件主要元素：

| 元素         | 描述                        |
| ------------ | --------------------------- |
| project      | 根元素                      |
| modelVersion | POM对象模型版本             |
| groupId      | 组织或部门的项目            |
| artifactId   | 项目下的maven项目，唯一标识 |
| version      | maven项目版本               |
| packaging    | 打包方式，jar、war、 pom等  |
| name         | maven项目名称               |
| description  | maven项目描述               |

# 依赖机制

### 传递性依赖

项目中直接依赖的jar包，一般也会依赖很多其他的jar包，那么maven会把这种间接依赖引入，作为传递性依赖。

### 依赖优先级

多层级依赖情况下，很可能出现依赖冲突，maven会保证只有一个版本在存在，这时maven会依次按照2个原则引入依赖：

1. 最短路径原则：依赖层级路径最短的jar包会被引入到项目中
2. 第一声明者优先：如果路径长短一样，那么看其本身或上级依赖的声明顺序，也就是从上到下的代码顺序

### 优化依赖

- `mvn dependency:list`，可以查看项目中已解析依赖
- `mvn dependency:tree`，形成树状依赖结构，更直观，比如使用`mvn dependency:tree | grep SNAPSHOT`来查看所有快照版本
- `mvn dependency:analyze`，用于分析项目中依赖存在的问题
  - Used undeclared dependencies found，未声明但使用的依赖，未显示声明而使用的传递性依赖，如果某个传递性依赖被删除则使用版本可能变化，有潜在风险，最好显示声明保证第一优先级
  - Unused declared dependencies found，声明但未使用的依赖，这种依赖大概率可以删除，但需要进一步看该依赖被其他依赖使用到，以及删除带来的风险

# 聚合和继承

### 聚合

一个项目经常会有多个模块，而根目录也经常会有parent模块的pom文件，聚合了module1、module2、module3等，同时每个子模块声明parent模块，这样就可以一次构建多个模块，比如：

```Xml
<project>
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.zhanghedr.project</groupId>
    <artifactId>webserver-parent</artifactId>
    <packaging>pom</packaging>
    <version>1.0-SNAPSHOT</version>
    
    <modules>
       <module>webserver-service</module>
       <module>webserver-api</module>  
       <module>webserver-dao</module>
       <module>webserver-util</module>
    </modules>
</project>
```

### 继承

多个模块可以继承parent模块的依赖配置，通过`<dependencies>`和`<dependencyManagement>`元素实现，`<dependencies>`会使所有子模块都继承jar包，而`<dependencyManagement>`更加灵活，子模块不需要指定版本来引入依赖管理元素中指定好的依赖，子模块通过声明来选择继承自己需要的哪些依赖。

# 仓库

Maven分为本地仓库和远程仓库，Maven会先在本地仓库查找依赖，如果本地没有或更新版本，会去远程仓库下载到本地使用。

- 本地仓库是项目本地jar包仓库
- 远程仓库包括多个公开和私有的仓库

# 构件版本

- RELEASE，稳定发布版本，不可覆盖，用于发布时
- SNAPSHOT，快照版本，可以覆盖，也可以引用其中某个日期发布的快照版本，只应用于内部或开发时

# Maven执行

- `mvn clean`，清除target
- `mvn compile`，编译至target
- `mvn test`，执行test目录下的单元测试
- `mvn package`，按照打包方式打包，输出对应的包至target
- `mvn install`，按照打好的包安装至本地库中使用
- `mvn -U clean install`，强制更新依赖，比如SNAPSHOT
- `mvn deploy`，上传至私服

# 常见问题

现在各种IDE有很多针对POM分析的工具可以使用，比如IDEA的Maven -> Show Dependencies，可以看到依赖关系节点图，搜索要找的依赖。

- 依赖冲突，`mvn dependency:tree`或IDEA等工具找到冲突依赖exclude掉，保留下想要的版本
- 升级依赖，存在一定风险，有可能依赖方删减了代码直接报错；依赖修改了实现；依赖Java版本升级发布环境低不支持调用报错，得经过充分测试
- 删减依赖，如果项目和各依赖都没有使用到，可以删除；如果项目未使用但有依赖使用到了，导致该已解析依赖版本变化，带来风险
- 传递性依赖JDK版本高于线上环境JDK，导致tomcat启动失败

applicationContext.xml引入依赖包配置文件，有时需要引入jar包里的bean配置来完成调用，因为这些文件不会被自动加载到spring中，需要手动通过`<import resource="classpath*:spring/*.xml"/>`加载，classpath后加*代表加载所有匹配的文件，不加则加载遇到的第一个文件，这样会带来风险：

- bean重名问题，可以将依赖配置bean名字根据项目取
- 可能载入多个同路径同名文件，导致更多bean重名问题

 