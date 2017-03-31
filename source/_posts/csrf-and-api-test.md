---
title: CSRF和API测试
date: 2017-02-08 01:53:03
categories: Tech
---

CSRF (Cross-site request forgery)、XSS (Cross-site scripting)和SQL注入是几个最著名的网络攻击，这里主要讲一下CSRF原理和如何在API测试中实现CSRF验证，也简单说明下XSS和SQL注入。

<!-- more -->

## CSRF攻击

简单来说CSRF就是攻击者欺骗用户访问某个危险网站B，由于`Same-origin policy`B站JS不能直接请求安全网站A，但如果是GET则简单的点击或者通过图片src加载就会上当，如果是POST则需要模仿表单提交，以用户的名义发送请求给A。如果用户最近登录过网站A还没有登出session cookie还在的话，那么这个用户未授权请求就会成功，而且还是在用户和网站A都不知情的情况下，攻击者可以模仿用户的身份对其进行一些改变状态的操作，这是很危险的，所以网站A需要有CSRF的防御机制，下面以Django举例。

Django内置了CSRF验证机制，Cookie-to-Header Token方法：

1. 用户登录后，除了session cookie，Django还会产生一个随机的`csrftoken` cookie
2. 在隐藏表单、HTTP header或POST body中也加入这个token，在Django中可以设`X-CSRFToken={csrftoken}`的header
3. Server验证cookie和header中两个token的值是否一致

使用了这种token验证的防御机制后，如果用户不小心点击了攻击者的链接，虽然他能利用网站A还存有的session验证用户身份，但是发出的请求只有cookie token而没有header token，服务器CSRF验证失败将会返回403 Forbidden错误。

根据[RFC 7231#section-4.2.1](https://tools.ietf.org/html/rfc7231.html#section-4.2.1)，安全的请求是只读、无危害的如GET，后端应该合理的实现GET请求，而对不安全的请求如POST/PUT/DELETE进行保护。

## XSS

XSS核心是在HTML页面注入恶意JS代码，假设在回复栏里输入恶意JS并且贴到HTML被浏览，比如`<script>alert('xss')</script>`，又或者是引用另外一个js src，会在页面打开时执行，也就是说跳过了`Same-origin policy`跨站执行了JS，JS可以做很多事，比如窃取用户的cookie。

## SQL注入

SQL注入和XSS理论上类似，也是通过给恶意输入，让server执行错误的SQL语句，比如夹杂着注释的参数。所以对用户输入必须进行严格校验。

## API测试验证CSRF

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