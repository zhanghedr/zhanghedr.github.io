---
title: HTTP Caching
date: 2017-03-20 20:34:57
categories: Tech
---

缓存是Web重要的组成部分，从浏览器开始到数据库的整个流程里，可以使用多种不同的缓存方案，本文主要是整理和学习Google开发者文章[HTTP Caching](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching#cache-control)的内容，讲一下基于HTTP/1.1的浏览器缓存，本文所有图片均引自于这篇Google文章。

<!-- more -->

浏览器是用户Web入口，大家知道刷新或者后退一个页面时响应很快，这是因为浏览器使用了本地磁盘的缓存资源，避免了去网站服务器GET请求和重新下载资源，这样减少了延迟也节省了流量，对js/css/img等静态资源进行尽可能长时间的合理cache，能大大提高网站性能。浏览器通过HTTP headers决定缓存策略，缓存主要由以下几个headers控制：

- `Cache-Control` 用于控制cache作用范围、条件和持续时间
- `ETag` 在cache过期后用于检验资源是否更新的token，通常是文件hash值
- `Expires` GMT格式的cache过期时间

其中`Cache-Control`和`ETag`开始于HTTP/1.1，提供了更加全面优先级更高的缓存控制，用于接替之前类似`Expires`的headers，其中`Cache-Control: max-age`描述cache持续时间。这样就可以理解为：

`Expires = now() + Cache-Control.max-age`，下面是`Cache-Control`的几种常见属性：

- **max-age**: 缓存持续时间，单位秒 
- **public**: 允许被浏览器和中介cache
- **private**: 浏览器可以cache，但中介不能，如CDN
- **no-cache**: 浏览器每次都必须请求server通过Etag检查资源是否改变了，如果没变则使用本地副本，保证使用最新资源，同时利用cache避免重复下载
- **no-store**: 禁止浏览器和任何中介缓存cache副本

根据上面的属性Google总结了下面这个decision tree：

![](/img/http_caching/decision_tree.png)

那么接下来会发生下面几种情况：

### 本地Cache未过期

这无疑是最佳情况，因为浏览器甚至都不用访问server，直接调用本地磁盘副本就行了，减少了延迟也节省了流量。下图所示，GET文件缓存120秒，在cache还未过期时会返回`200 OK (from disk cache)`。

![](/img/http_caching/cache_control.png)

### 本地Cache过期后的ETag重新验证

下图所示，假设120秒过期后又发出了同样的请求，浏览器先查看Cache-Control和Expires发现本地副本已过期，这时会提供`If-None-Match: {ETag}`的header请求server校验最新的文件`ETag`值，如果相同则返回`304 Not Modified`告诉浏览器本地副本可以继续使用120秒。这里虽然存在一个请求响应往返过程，但不需要重新下载文件节省了流量，而且续了浏览器cache周期。

![](/img/http_caching/etag.png)

### 本地Cache未过期但想强制用户使用最新版

有时候cache的js/css还没过期，但是此时前端dev有一个很重要的更新想让用户马上使用，肯定不可能说让用户去清除浏览器缓存，这时候需要改变资源的URL让用户强制下载新资源，比如加入版本号签名到文件名中style.**x234dff**.css。

![](/img/http_caching/cache_hierarchy.png)

上图可以看到HTML文件是no-cache的，代表每次都必须去server查看是否有变动，而css文件缓存有效期1年，如果引用的css的URL(文件名)改变了，那么新的css版本和HTML会重新下载。

### 总结

根据HTTP缓存可以总结以下几点：

- 根据资源更新频率不同设置不同的max-age，通常在1个星期以上，不常更新的文件(如library)可以直接设为1年
- 保持URL稳定，如果同一个资源使用了不同的URL，将会被多次下载和保存
- 保证服务器提供ETag，用于重新验证过期的缓存
- 让public的文件同时缓存于CDN以减少延迟

Google开发者还推出了[PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/)对网站性能打分，并提供相关优化建议，大家可以试一下。