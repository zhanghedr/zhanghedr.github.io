---
title: Session 和 Cookie
date: 2017-03-29 00:21:52
categories: Tech
---

Session是抽象概念，而cookie是实现会话最常用的方式，cookie保存在客户端而session保存在服务端，因为HTTP的无状态性，可以用cookie来记录前后请求的状态，session就是典型的例子，又或者如购物车，也可以用来记录用户偏好、行为分析等。

<!-- more -->

## Cookie

Cookie通过Server返回HTTP响应头设置比如：

`Set-Cookie: wd=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT; Max-Age=-1490916428; path=/; domain=.facebook.com`

然后浏览器在接下来发送请求时会在header中带上cookies比如：

`Cookie: theme=light; sessionToken=abc123`

如果用户浏览器禁用cookie，可以在请求时把cookie放到HTTP URL或POST body中。不同子域名或端口可以共享Cookie。

### Cookie属性

下面是facebook登录页面chrome显示的cookies：

![facebook](/img/session_and_cookie/facebook.jpg)

可以看到分别有以下属性：

- Name / Value
- Domain / Path
- Expires / Max-Age
- Size
- HTTP
- Secure
- SameSite

### Cookie分类

下面是常见Cookie分类：

- `Session cookie` 未设置过期时间的cookie，浏览器关闭后就被删除了，在`Expires / Max-Age`属性中为`Session`。
- `Persistent cookie` 设置了过期时间的cookie，在浏览器关闭后依然保存，在`Expires / Max-Age`属性中可以看到过期时间，到期删除或用户手动删除。用于跟踪多个请求的状态，比如session。
- `Secure cookie ` 只能在HTTPS加密协议下传输，即上图属性`Secure`打钩的cookie。
- `HttpOnly cookie` 不能被前端JS访问，即上图属性`HTTP`打钩的cookie。
- `SameSite cookie` 只能在same site的情况下发送，即上图属性`SameSite`打钩的cookie。

## Session

HTTP是无状态协议，也就是说在用户登录后的HTTP请求不知道之前登录过没有，在登录时可以在cookie中保存一个server产生的无规律字符串session_id，同时把session_id=session保存在服务端，可以是内存或数据库，session对象包含了用户信息，如user_id、expire_time、last_activity等，这样每次请求server都可以用中间件或装饰器，通过cookie中的session_id得到session从而验证用户身份和信息。比如可以在某站登录后手动删除浏览器cookie，再刷新页面会被logout。

## 参考资料

https://en.wikipedia.org/wiki/HTTP_cookie

https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies