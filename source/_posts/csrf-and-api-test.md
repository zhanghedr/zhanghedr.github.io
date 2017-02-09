---
title: CSRF和API测试
date: 2017-02-08 01:53:03
categories: Tech
---

CSRF (Cross-site request forgery)是最著名的网络攻击之一，又被称作XSRF，这里讲一下其原理和如何在API测试中实现CSRF验证。

<!-- more -->

# CSRF攻击原理

简单来说CSRF就是攻击者欺骗用户访问某个危险网站B，在网站B里含有攻击者代码，以用户的名义发送请求给安全的网站A。如果用户最近登录过网站A还没有logout，session cookie还在的话，那么这个用户未授权请求就会成功，而且还是在用户和网站A都不知情的情况下，这个请求可以是GET或POST等，等于说攻击者可以模仿用户的身份对其进行一些更新删除操作，这个无疑是非常危险的，所以网站A需要有CSRF的防御机制，下面以Django举例。

Django内置了CSRF验证机制，也就是Cookie-to-Header Token方法：

1. 用户登录后，除了session cookie，Django还会产生一个随机的`csrftoken` cookie
2. 前端在发送不安全的请求前，比如POST，设`X-CSRFToken`header，value是csrftoken
3. Server验证cookie和这个请求header中的token值是否一致

使用了这种防御机制之后，如果用户不小心点击了攻击者的链接，虽然他能利用网站A还存有的session验证用户身份，但是发出的请求header中没有CSRF Token或者不同，服务器CSRF验证失败这个请求将会返回403 Forbidden错误，从而阻止了攻击。

根据[RFC 7231#section-4.2.1](https://tools.ietf.org/html/rfc7231.html#section-4.2.1)，安全的请求是只读、无危害的如GET，后端应该合理的实现GET请求，而对不安全的请求如POST/PUT/DELETE进行保护。

# API测试验证CSRF

这里以Django和[Postman](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop?hl=en)举例，Postman是一款很方便的HTTP API测试Chrome插件。

1. 安装[Postman Interceptor](https://chrome.google.com/webstore/detail/postman-interceptor/aicmkgpgakddgnaphhhpliifpcfhicfo?hl=en)插件，使Postman可以共享浏览器cookie，从而更方便测试，安装完成后在Postman右上角开启interceptor，这样就能看到浏览器中的cookies了

2. Postman右上角新建环境

3. 新建login请求，并在test中加入下面script，获取CRSF cookie并且设置为postman环境变量

   ```js
   var crsf_cookie = postman.getResponseCookie("csrftoken");
   postman.setEnvironmentVariable("csrf_token", crsf_cookie.value);
   ```

4. 新建要测试的POST请求，添加CRSF token header，比如django：

   ```sh
   X-CSRFToken : {{csrf_token}}
   ```

5. 先发送login请求，然后发送要测试的POST请求

这样POST请求就能自动抓取环境中的CSRF token作为其header发送出去验证了，无需每次都手动设置。