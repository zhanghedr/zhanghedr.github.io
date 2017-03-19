---
title: REST 与 SOAP
date: 2017-03-12 00:02:24
categories: Tech
---

一个好的API设计是非常重要的，它连接了前端和第三方开发者，REST和SOAP是API开发中的两种架构，基于资源和HTTP方法的REST成为了互联网开发的主流选择，本文主要讨论REST特性，同时对比两种实现。

<!-- more -->

# REST

REST的优点主要有以下四点：

- URL表示对应资源，一般只有名词没有动词。
- 使用标准HTTP方法(GET/POST/PUT/DELETE等)抽象化接口，对于同一资源无需自定义对其的增查删改方法。
- Request和response的payload支持多种格式，常见的有`JSON`和`XML`，一般推荐用`JSON`。
- 可以根据HTTP Header缓存GET请求，注意保证GET不会改变状态。

## API Root URL

常用的URL是`https://api.example.com/v1`，其构成为：

- HTTPS协议保证数据安全
- api subdomain独立出API URL
- example.com网站域名
- v1表示API版本，为了兼容老用户和新用户

## URL资源

URL中的资源是名词，HTTP方法代表对资源的动作，如果要请求的资源是用户，资源集可以用`/people`，单个资源用`/people/{username}`，根据不同的HTTP方法有：

- `GET /people` : 获取和返回用户列表
- `POST /people` : 创建单个用户，返回新建用户
- `GET /people/{username}` : 获取和返回单个用户
- `PUT /people/{username}` : 更新单个用户，提供整个model属性，返回更新用户
- `PATCH /people/{username}`  : 更新单个用户，提供要更新的model属性，返回更新用户
- `DELETE /people/{username}` : 删除单个用户，返回空
- `GET /people/{username}/videos` : 获取和返回单个用户的视频列表

## 分页

在获取资源列表的时候，如果符合条件的列表太大会对服务器造成很大压力，并且请求时间会很长，Pagination能很好解决这个问题，常用`LIMIT`对资源table限制resultset。

## 状态码

合理的状态码也是好的设计一部分，这里列举一些常见的，完整列表可以在[RFC2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html)查看。

- **200** OK
- **400** Bad Request
- **401** Unauthorized
- **403** Forbidden
- **404** Not Found
- **405** Method Not Allowed
- **500** Internal Server Error
- **503** Service Unavailable

## 授权

如果是第三方API则需要授权才能使用，一般使用[OAuth 2.0](https://tools.ietf.org/html/rfc6749)实现，很多框架都带OAuth工具包，具体步骤可以参见各大公司的API文档。如果是作为用户使用，需要先在公司开发平台注册一个key，作为使用其API的授权。

## Content Type

前面提到REST优点之一就是请求和响应payload支持多种格式，一般支持JSON，其次是XML，当然你也可以支持HTML/CSV等格式，对应不同的需求。

## HTTP Request Response

简单POST请求创建用户例子：

``` Sh
POST /v1/people HTTP/1.1
Host: api.example.com
Content-Type: application/json
Accept: application/json
 
{
  "username": "zhanghedr",
  "email": "example@gmail.com",
  "bio": "Software Engineer"
}
```

``` Sh
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Date: Sun, 12 Mar 2017 18:26:00 GMT
Server: WSGIServer/0.2 CPython/3.5.3
Content-Length: 24
 
{
  "id": 52,
  "username": "zhanghedr",
  "email": "example@gmail.com",
  "bio": "Software Engineer"
}
```

​      

# SOAP

前面提到REST的优点也就是SOAP的缺点，SOAP主要特性有以下四点：

- URL不表示对应资源，不同的资源请求URL是相同的。
- 所有的请求都通过HTTP POST实现。
- 请求的资源和操作方法定义在POST payload SOAP message中，需要解析才能知道。
- 只支持XML数据格式，在很多场景有局限性。

## SOAP Message

因为SOAP所有的请求全部定义在其XML message中，所以其结构和内容显得格外重要，它主要由三部分构成：

- Envelope，XML root，必填
- Header，头信息，可不填
- Body，请求资源、方法和变量，必填

下面是请求的一个例子，响应也是类似结构返回对应请求XML。

```xml
<?xml version="1.0"?>
<soap:Envelope
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope/" soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
    <soap:Header></soap:Header>
    <soap:Body xmlns:m="http://www.example.org/abc">
        <m:getUserById>
            <m:id>1</m:id>
        </m:getUserById>
    </soap:Body>
</soap:Envelope>
```

可以看到getUserById方法被定义在了SOAP message中，而URL`https://api.example.com/v1`没有包括任何信息，可以使用这一个ROOT URL通过不同的message实现所有API功能，这种不灵活的方式造成了SOAP在互联网中越来越少的应用。

​          

# 参考资料

https://bourgeois.me/rest/

https://www.ibm.com/developerworks/cn/webservices/0907_rest_soap/

