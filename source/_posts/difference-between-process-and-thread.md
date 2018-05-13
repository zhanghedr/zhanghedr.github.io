---
title: 进程和线程的区别
date: 2017-01-04 00:09:59
categories: Tech
---
进程(process)和线程(thread)是操作系统里最基本的概念之一，在算法题和工作上碰到这个问题，决定做一个总结。这里打个简单的比方，如果操作系统是一座工厂，CPU是生产机器，工厂里的调度员调度机器去生产某个产品，一个产品流水线是一个进程，每个流水线上的一个工人是一个线程。

- 单进程单线程：一个工人在一个流水线上工作
- 单进程多线程：多个工人在一个流水线上工作
- 多进程单线程：多个流水线，每个有一个工人工作
- 多进程多线程：多个流水线，每个有多个工人工作

<!-- more -->

## 什么是进程
进程可以理解为一个程序，操作系统会分配CPU、内存等环境给要执行的进程，一个CPU同一时间只能执行一个进程，当这个进程执行完或它被分配的执行时间结束后，CPU就会执行下一个进程，如果它还没有执行完，那么CPU在之后再轮回到它时会从上一次结束的点继续执行。

现代电脑的CPU都很强大，电脑上不可能同一时间只能运行一个程序，操作系统会调度多进程运行多个程序从而充分利用CPU，比如我们同时打开了QQ、Chrome和Sublime就是三个进程。

## 什么是线程
虽然进程实现了操作系统上多个程序的并发，但对于一个程序运行来说，以blocking的形式运行难免会出现问题，如果一个进程在某个点阻塞，如果它的阻塞不会影响后续的代码，那么我们完全可以提前运行后面的程序而不必等其阻塞恢复，我们希望在一个进程里有多个工人并发同时工作以进一步增加效率，这里的工人就是线程。比如Word有多个线程，一个线程负责输入，一个线程负责显示，还有线程负责自动保存，这让我们感觉到输入和显示同时发生。

## 进程和线程的区别
- 一个操作系统可以包含多个进程，一个进程可以包含多个线程
- 多进程分别拥有不同的内存，而同一进程下的多个线程共享同一部分内存，因此线程之间可以读写同样的数据变量

## 参考资料
http://www.cnblogs.com/hazir/archive/2011/05/09/2447287.html