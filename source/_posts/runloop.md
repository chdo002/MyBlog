---
title: runloop
date: 2018-03-28 10:39:25
tags:
---


RunLoop

# 干嘛的

为了实现线程不退出，可以随时接受消息执行任务，
node.js 的事件处理，windows程序的消息循环，iOS、OSX的RunLoop都是这种机制

线程和runloop一一对应，关系保存在全局字典中

主线程自带runloop，无需创建，新建的线程需要手动对应runloop，不让执行完成就结束了
