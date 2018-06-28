---
title: 网络传输协议
date: 2017-04-01 17:36:07
categories: Tech
---

![tcp](/img/osi_tcp.jpeg)

<!-- more -->

## 四层/七层负载均衡

根据负载均衡作用在OSI(Open Systems Interconnection)模型的位置不同，可以分为四层、七层：

- 四层：作用于传输层(TCP)，基于IP:PORT进行请求**转发**，将请求转发到Nginx
- 七层：作用于应用层(HTTP)，基于URL进行请求**代理**，分配请求到真实的服务器

负载均衡器又分为软件和硬件：

- 软件：Nginx(七层)、LVS(四层)、HAProxy，价格低配置简单
- 硬件：F5(四层)、Array，缺点是价格和维护成本高

早期流量不大直接用Nginx的HTTP七层负载均衡即可，配置简单成本低；后期可以逐步使用F5、LVS等性能更高的负载均衡器，并采用Keepalived双机热备方案，一个简单例子：

1. 浏览器DNS域名解析IP
2. F5四层负载均衡
3. Nginx七层负载均衡
4. 真实服务器响应请求

## TCP

### TCP/IP模型

- **应用层**：HTTP、TLS/SSL、SSH、FTP
- **传输层 **：TCP、UDP
- **网络层 **：IP (IPv4, IPv6)，主要负责寻址和数据包的传输
- **网络接口层**：对实际的网络媒体的管理

### TCP握手

![tcp](/img/internet_communication_protocol/tcp.jpg)

IP主要负责寻址和数据包的传输，TCP实现了在IP层之上可靠、有序、准确的传输数据包，相反UDP不可靠无序但速度快。TCP传输建立需要三次握手，关闭需要四次握手，通过两端的sockets完成，有connect/accept/read/write/close方法，每次发送同步或结束信号SYN/FIN都要等待ACK确认。

TCP建立连接过程：

1. 服务端处于LISTEN监听状态
2. 客户端发送SYN=x同步信号请求连接，客户端处于SYN_SENT状态
3. 服务端同时返回ACK=x+1和SYN=y信号，服务端处于SYN_RECEIVED状态
4. 客户端再发送一个ACK=y+1的确认信号，客户端和服务端都收到ACK确认信号后，都处于ESTABLISHED连接建立状态

TCP关闭连接过程：

1. 客户端发送FIN结束信号请求关闭，客户端处于FIN_WAIT_1状态
2. 服务端返回ACK确认信号，并处于等待socket关闭的CLOSE_WAIT状态，而客户端也进入FIN_WAIT_2的服务端FIN等待状态
3. 服务端继续返回FIN结束信号，处于LAST_ACK等待最后ACK状态，而客户端处于TIME_WAIT等待自动关闭
4. 客户端返回ACK，连接关闭进入CLOSED状态

**关闭连接需要多一次握手因为在服务端返回时不能同时返回ACK和FIN，服务端socket不会立即关闭，而是先返回ACK表示接收到客户端关闭信号，而过会才能返回FIN服务端关闭信号。**

### TCP保证有序可靠

- 通过序列号和确认号计数
- 发送者和接受者计算TCP报文段的头和数据部分的校验和，验证报文的完整性
- 重发丢失的数据包
- 舍弃重复的数据包

### TCP长短连接

- 短连接：建立连接——数据传输——关闭连接
- 长连接：建立连接——数据传输...（保持连接）...数据传输——关闭连接，节省建立和断开时间，如数据库连接

### Socket

Socket本身不是协议，而是TCP/UDP传输协议的实现接口API，用于两个节点建立和关闭连接、发送和接收数据。

## HTTP

### HTTP构成

- 请求方法 + URI + HTTP版本
- HTTP头（包含Cookie)
- HTTP体（POST参数）
- HTTP状态码

HTTP是无状态的，通过request和response交互，必须是客户端请求服务端，服务端是被动的，新的Websocket协议解决这个问题。浏览器总是先解析HTML，然后根据其中资源需要继续请求js/css/img。

### HTTP方法

GET, HEAD(与GET一样但只返回响应头而不返回响应体), POST(创建或更新), PUT(更新), DELETE

安全方法：不会对资源造成改变，GET/HEAD

幂等：多次请求和单次请求效果相同，GET/HEAD/PUT/DELETE

### HTTP状态码

- [1xx消息](https://zh.wikipedia.org/wiki/HTTP%E7%8A%B6%E6%80%81%E7%A0%81#1xx.E6.B6.88.E6.81.AF)：请求已被服务器接收，需要继续处理
- [2xx成功](https://zh.wikipedia.org/wiki/HTTP%E7%8A%B6%E6%80%81%E7%A0%81#2xx.E6.88.90.E5.8A.9F)：请求已成功被服务器理解并接受
- [3xx重定向](https://zh.wikipedia.org/wiki/HTTP%E7%8A%B6%E6%80%81%E7%A0%81#3xx.E9.87.8D.E5.AE.9A.E5.90.91)：响应重定向的资源，需要后续请求才能完成
- [4xx客户端错误](https://zh.wikipedia.org/wiki/HTTP%E7%8A%B6%E6%80%81%E7%A0%81#4xx.E8.AF.B7.E6.B1.82.E9.94.99.E8.AF.AF)：请求含有词法错误或者无法被执行
- [5xx服务器错误](https://zh.wikipedia.org/wiki/HTTP%E7%8A%B6%E6%80%81%E7%A0%81#5xx.E6.9C.8D.E5.8A.A1.E5.99.A8.E9.94.99.E8.AF.AF)：服务器在处理某个正确请求时发生错误

常见的有：

- 301 永久重定向，在响应头里指明Location重定向URI
- 302 临时重定向，在响应头里指明Location重定向URI
- 304 HTTP缓存过期后验证ETag值，如果相同则响应Not Modified可以继续使用浏览器缓存无需下载
- 400 Bad Request 明显的请求格式错误
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 405 Method Not Allowed
- 500 Internal Server Error，无错误信息
- 502 Bad Gateway，代理服务器执行请求时，无法收到上游服务器响应
- 503 Service Unavailable，服务器过载无法完成请求

### HTTPS

HTTPS是基于TLS/SSL的HTTP，防止明文被窃听、内容篡改、域名假冒、保证性能，采用443而非80端口。**TLS/SSL在握手阶段首先通过非对称加密算法(RSA)交换一个随机会话密匙，然后在传输阶段通过会话密匙和对称加密算法进行数据的加密和解密工作，并用hash算法保护数据完整性**：

- **网站方从CA(公认的证书认证机构)购买签名后的数字证书文件，包含public key和private key**，然后在服务器上部署这两个密匙
- 用户访问HTTPS网站时，服务器先发送public key，浏览器验证其签名CA是否是在预先安装的权威CA列表里
- 拿到公钥的一方先生成随机的会话密钥，然后利用公钥加密它；再把加密结果发给对方，对方用私钥解密；于是双方都得到了会话密钥
- 两方用交换过的会谈密钥和对称加密算法将交换的数据做加密和解密，并用hash算法保护数据完整性

**在密匙交换阶段不能使用对称加密是因为：对称加密双方都得用同一个密匙，如果被截取就不行了；而非对称加密双方用的不同的两个public/private密匙，只传输public被截取了也没关系。**

**HTTPS一般是验证服务端的身份而客户端没有限制，但某些公司还需要验证客户端的身份进行访问控制**，比如浏览器必须安装了keystore才能访问某些交易页面。

### HTTP长短连接

长连接指数据传输完成了保持TCP连接不断开，等待在同域名下继续用这个通道传输数据，避免了多次TCP的三次握手建立连接和四次握手关闭连接的开销，相反的就是短连接。HTTP 1.1默认所有连接都是长连接，无需使用头`Connection: keep-alive`。

**多个HTTP请求串行使用一个TCP长连接，减少了延迟。但串行的请求/响应并发性不足，所以浏览器还是会对一个域名开启最多6-8个TCP连接，来保证HTTP的并发请求和响应，如果超过了这个限制，会把请求放入队列中等待。**为了避免最大TCP连接的并发性限制，可以把js/css/img资源放在另外一个域名从而和其他域名的资源并发访问，限制是为了浏览器线程资源、服务器负载能力、避免DDoS攻击。

### HTTP 2.0

- 二进制分帧传输数据而非文本，提高传输性能
- **多路复用**，真正实现了单个TCP长连接的HTTP并发请求和响应，即不用多域名、资源合并解决方案了
- 头压缩，减少流量
- 服务端推送，服务端可以在发送HTML时主动推送其它资源如js/css，而不用等到浏览器解析到相应位置再发起请求

## WebSocket

基于TCP的协议，不同于HTTP，服务器不再被动的接收浏览器的请求，而是在有新数据时就主动推送给浏览器，适用于多人聊天、消息推送等场景，优于客户端Ajax轮询的解决方式。

## 一次完整的HTTP请求

1. 浏览器DNS域名解析，会依次查浏览器DNS缓存、OS缓存、hosts文件、DNS系统调用
2. 拿到IP地址后，通过3次握手，建立用户IP和域名IP的TCP连接
3. 浏览器发起HTTP请求
4. 服务器响应HTTP请求，浏览器得到HTML文档
5. 浏览器解析HTML代码，并发请求HTML中的资源
6. 服务器根据静态和动态资源响应请求，返回静态文件或动态数据
7. 浏览器对页面进行渲染呈现给用户

## 参考

[四层、七层负载均衡的区别](https://www.jianshu.com/p/fa937b8e6712)

[详解https是如何确保安全的？](http://www.wxtlife.com/2016/03/27/%E8%AF%A6%E8%A7%A3https%E6%98%AF%E5%A6%82%E4%BD%95%E7%A1%AE%E4%BF%9D%E5%AE%89%E5%85%A8%E7%9A%84%EF%BC%9F/)