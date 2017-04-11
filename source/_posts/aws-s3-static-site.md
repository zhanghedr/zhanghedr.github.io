---
title: AWS S3托管静态网站
date: 2017-04-11 01:15:51
categories: Tech
---

AWS S3云存储不但可以放文件，还可以托管静态网站，当然GitHub是个不错的选择，这里讲下简单几步将静态网站部署到S3上。

<!-- more -->

假设域名是www.example.com，步骤如下：

1. 创建一个**S3 bucket**，名字必须和域名一样
2. 上传静态网站内容到**bucket**
3. 设置里开启静态网站hosting
4. 设置**index**页面
5. 添加公共访问许可**bucket policy**，以JSON格式如下

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::www.example.com/*"
      ]
    }
  ]
}
```

