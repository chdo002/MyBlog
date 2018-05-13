---
title: Shell脚本
date: 2018-05-13 14:17:17
tags:
---

> 最近一段时间用的Cocoapods做项目组件化，意外的打开了以前不太注意的脚本大门，现在记录如下：

 xcode 中的build phrase 用来控制项目的编译过程，你按下CMD+B或者CMD+R，他就按照从上到下的执行一遍，我想要在编译前或者编译后执行一些操作，就可以在合适的位置添加脚本，shell或者Python等都可以。

 xcode 内置了一些宏变量方便脚本,如下:
 ```
    BUILT_PRODUCTS_DIR:  build成功后的，最终产品路径－－可以在Build Settings参数的Per-configuration Build Products Path项里设置.
    TARGET_NAME: 目标工程名称
    SRCROOT:工程文件（比如Nuno.xcodeproj）的路径 
    CURRENT_PROJECT_VERSION:当前工程版本号

    其他
    PRODUCT_NAME
    SYMROOT
    BUILD_DIR
    BUILD_ROOT
    CONFIGURATION_BUILD_DIR
    CONFIGURATION_TEMP_DIR
    SDK_NAME
    CONFIGURATION
    TARGET_NAME
    EXECUTABLE_NAME
    IPHONEOS_DEPLOYMENT_TARGET
    ACTION
    CURRENTCONFIG_SIMULATOR_DIR
    CURRENTCONFIG_DEVICE_DIR
 ``` 

一个简单的shell脚本可以直接在当前路径下执行  ./xxxx.sh, 执行前要赋权 chmod +x xxxx.sh

如果要在全局要执行这个脚本，则要添加全局变量

全局变量添加在 ~/.bash_profile 下，其他好像不怎么用(就我目前所知😝)，写下你的文件路径 `export xxxx="/usr/local/bin/xxx"`

这个文件可以是脚本文件，也可以是执行文件，然后执行 `source ~/.bash_profile`，就可以立即让这个路径生效，不然要重启，让系统读下这个文件。

echo $PATH 显示当前PATH环境变量

