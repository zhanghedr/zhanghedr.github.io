---
title: 搭建一个Hexo博客
date: 2016-12-07 23:15:03
categories: Tech
---
这几天弄了一个自己的博客，对于每一步的选择搜索了大量帖子，这里列出我觉得还不错的方案，NameSilo + DNSPod + Github Pages + Hexo。

<!-- more -->

## 空间
首先先考虑把博客托管到哪里，可以购买VPS，也可以放在云服务上如AWS和阿里云，我选择放在Github Pages。因为考虑到只是静态页面，通过Pages可以非常简单的把静态博客publish到username.github.io上，而且Github上的username.github.io repo还能作为codebase进行版本控制，非常方便。虽然已经有很多教程，但是推荐大家还是直接去[官网](https://pages.github.com/)看教程，非常简单就几步。

## 架构
大家推荐不错的有hexo, pelican, typecho, farbox, ghost等，我觉得都挺好的，毕竟博客的关键还是在于内容吧。但在选择博客架构时，有人会因为不熟悉Node.js而没有选择Hexo，我想说安装hexo是非常简单的过程，完全不知道Node.js也能用。只需要你安装Node.js和Git就能用npm来安装hexo了，这里不讨论过多细节，还是推荐大家去看[官方文档](https://hexo.io/docs/index.html)，非常快就能在本地安装好hexo。

## 主题
对于主题可能大家选择上很纠结，我用了next，虽然已经烂大街了，但是真的非常简洁漂亮，而且有3种样式可供选择，查看所有hexo官方主题点[这里](https://hexo.io/themes/)。对于主题配置，看过[next官方文档](http://theme-next.iissnan.com/getting-started.html)基本上就能满足你80%需求了。

## 部署
hexo已经提供内置的部署配置，只需要配置好repo就能一键部署。当然如果你需要更灵活的方式，可以自己写个script来部署。

## 域名
至此你应该就能在username.github.io看到自己的博客online了，现在可以给你的博客注册一个域名。因为听说国内的域名要备案所以我就没考虑，对于域名商看了很多推荐，大家普遍推荐的有NameSilo, GANDI, uniregistry，普遍不推荐的有Godaddy, 1&1(这家虽然便宜但千万别用，血的教训)。我选了推荐最多的NameSilo，续费的价格也不会坑，注意用$1 OFF的折扣，网上一搜就有。

## DNS解析服务器
注册域名时唯一要注意的就是在注册过程中就选你的NameServers，因为用国外的DNS解析很慢，大家普遍推荐用国内的[DNSPod](https://www.dnspod.cn/)，只需要填下面两个地址在NameServers里。
```
F1G1NS1.DNSPOD.NET
F1G1NS2.DNSPOD.NET
```
注册完成后再回到DNSPod添加你的域名，并添加CNAME记录。我这里选择www子域名作为主站，所以让顶级域名zhanghedr.com跳转到www.zhanghedr.com，然后用CNAME解析www.zhanghedr.com到username.github.io。DNSPod对于每个选项有详细解释，感觉比AWS Route 53清楚很多，至此你只需要等待一会就能看到DNS设置生效，我只等了几分钟。

## 常见配置
这里列出一些常见的主站_config.yml配置key
- title
- description
- author
- language
- theme
- deploy

常见主题_config.yml配置key
- favicon
- menu
- scheme
- social
- avatar
- sidebar
- highlight_theme
- baidu_analytics
- google_analytics
- duoshuo_shortname
- disqus_shortname
- busuanzi_count

## 常用指令

hexo new "blog name"

hexo generate

hexo server

hexo clean

hexo deploy

## 添加版权信息

1. 创建`/scripts/tail.js`
2. 创建`/tail.md` 
3. 更新`_config.yml`

## Even主题个性化

- 更换`/even/source/favicon.ico`
- Optional: 安装本地搜索模块`npm install hexo-generator-search --save`
- Optional: 更新padding - `/even/source/css/_custom/_custom.scss`
- Optional: 更新`/even/layout/_partial/_post/copyright.swig`

## 新设备设置

在另一台设备设置环境，`npm install`即可

下载主题而不是clone，从而commit主题文件