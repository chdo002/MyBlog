---
layout: tags
title: weex
date: 2017-10-08 20:40:23
tags:  weex
---

------

[weex官网](http://weex.apache.org)

------

## 集成

### iOS

> 推荐用Cocoapods

只用到一个包 WeexSDK

## Android

build.gradle 中添加依赖
```
compile 'com.android.support:recyclerview-v7:23.1.1'
compile 'com.android.support:support-v4:23.1.1'
compile 'com.android.support:appcompat-v7:23.1.1'
compile 'com.alibaba:fastjson:1.1.46.android'
compile 'com.taobao.android:weex_sdk:0.5.1@aar'
```
注意各自版本更新

------

## Vue

   --[Vue文档](https://cn.vuejs.org/v2/guide/)

------

## 已解决问题

- [x] switch这个标签，如果checked绑定来了data中的某个属性，则在change被触发时，也要及时更改掉checked绑定的属性，否则会出现问题（比如，再次修改绑定属性，发现switch没有相应更改）



------

## 待解决问题

- [ ] iOS11中在复杂页面情况下出现自动布局在后台进行的错误
- [ ] js调用Android 原生Java方法回调怎么写，还没有试
