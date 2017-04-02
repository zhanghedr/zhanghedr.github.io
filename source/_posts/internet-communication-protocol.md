---
title: 网络传输协议
date: 2017-04-01 17:36:07
categories: Tech
---

Web中接触最多的就是HTTP协议，但还有一些底层协议，按层高到低排列举例：

- **应用层 (Application)**：HTTP、TLS/SSL、SSH、FTP
- **传输层 (Transport)**：TCP、UDP
- **网络层 (Internet)**：IP (IPv4, IPv6)
- **链接层 (Link)**：IEEE 802.11‎ 

<!-- more -->

### IP

IP主要负责寻址和数据包的传输

### TCP

TCP实现了在IP层之上可靠、有序、准确的传输数据包，因为太广泛的应用也常说TCP/IP，相反UDP不可靠但速度快。TCP传输建立需要三次握手，关闭需要四次握手，如下图所示：

![tcp](/img/internet_communication_protocol/tcp.jpg)

### HTTP

HTTP经过多年已经有多个版本了1.0, 1.1, 2.0，包含HTTP方法、URI、HTTP版本、header、body、status code等。HTTP是无状态的，通过request和response交互，必须是客户端请求服务端，而不能反过来，服务端是被动的。新的Websocket协议解决这个问题，服务端可以主动的响应客户端了。

而HTTPS是基于TLS/SSL协议的HTTP，数据经过了加密且传输的两方身份经过了验证，大大提高了HTTP的安全性。

### Socket

Socket本身不是协议，而是TCP/UDP传输协议的实现接口API，用于两个节点建立和关闭连接、发送和接收数据。

### TCP长连接

HTTP是基于TCP传输通信的，首先TCP打开一个连接，然后HTTP在其中发送请求和接收响应，结束后TCP关闭连接，这是一个TCP短连接。一个页面有很多动态和静态资源请求，每次建立和关闭会消耗很多资源和时间，HTTP 1.0通过在响应头的`Connection: keep-alive`建立长连接，但HTTP 1.1已经默认所有连接都是长连接了，在一个HTTP请求完成后连接不会关闭，后续的请求可以继续用这个连接直到timeout，这样不会产生过多连接减少负担，当然长连接也需要消耗服务器一定资源去管理和维持。

### 长轮询

对于时间敏感的通讯应用，在访问不高的情况下简单用JS写一个Ajax循环轮询请求即可，但其实很多请求是无效浪费的。对于访问量大的应用，可以用长轮询方式，客户端向服务器发送Ajax请求，server会挂起请求监测是否有消息，有新消息或超时才返回响应关闭连接，这样减少了无用的请求。