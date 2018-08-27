---
title: iOS启动解析
date: 2018-08-27 17:58:10
tags:
---

> 出自[此处](https://www.jianshu.com/p/962002c6655f)

# 基本大纲

1. 应用的启动分为Pre-main和mian两部分
2. 在Pre-main中，可以大致分为load dylib->rebase->bind->Objc setup-> initializer，开发能掌握和度量的是initializer部分
3. 在开发阶段(Xcode)如何查看启动的每个阶段的时间---通过在Xcode中，设置Edit Scheme -> Run -> Argument汇总的环境变量,会在console中输出
4. 在应用上线后，统计Pre-mian的使用时间。利用的在加载动态库的一个顺序机制，定制自己的动态库，让他在第一个被加载，并在load函数中hook住所有可执行文件，然后统计出最终的每一个的时间，得到最后的时间（后续文章具体讲述）
5. Class Load 和 Static Initializers（+(void)load; + (void)initialize; 后续文章）
6. Xcode For Static Initializer

# Apple建议

> Apple suggest to aim for a total app launch time of under 400ms and you must do it in less than 20 seconds or the system will kill your app.

Apple建议应用的启动时间控制在400ms之下。并且必须在20s以内完成启动，否则系统则会kill掉应用程序。那么话说我们如何知道app的在启动到调用main()方法之前的时间呢？在WWDC 2016的提到了这方面的信息。

## Pre-main时间

从在屏幕上点击你的app icon开始，到应用执行到main()方法或者执行到applicationWillFinishLaunching的过程中，app执行了一系列的操作。在iOS10之前的系统中，我们无处得知其中的细节。而在iOS10系统中，可以通过简单在Xcode设置，在控制台就可以打印出Pre-main的具体信息细节。

通过Xcode中的Edit Scheme -> Run -> Argument，设置参数DYLD_PRINT_STATISTICS值为1

设置DYLD_PRINT_STATISTICS
这里使用的Objective-C项目，iPad Air2，系统iOS10.3

```
Total pre-main time:  74.37 milliseconds (100.0%)
   dylib loading time:  41.05 milliseconds (55.2%)
  rebase/binding time:   8.10 milliseconds (10.9%)
      ObjC setup time:   9.87 milliseconds (13.2%)
     initializer time:  15.23 milliseconds (20.4%)
     slowest intializers :
       libSystem.B.dylib :   6.58 milliseconds (8.8%)
libBacktraceRecording.dylib :   6.27 milliseconds (8.4%)
```

上文中可以看出总共消耗的时间为74.37ms。

* dylib loading time 载入动态库，这个过程中，会去装载app使用的动态库，而每一个动态库有它自己的依赖关系，所以会消耗时间去查找和读取。对于Apple提供的的系统动态库，做了高度的优化。而对于开发者定义导入的动态库，则需要在花费更多的时间。Apple官方建议尽量少的使用自定义的动态库，或者考虑合并多个动态库，其中一个建议是当大于6个的时候，则需要考虑合并它们

* rebase/binding time 重构和绑定，rebase会修正调整处理图像的指针，并且会设置指向绑定(binding)外部的图像指针。所以为了加快rebase/binding，则需要更少的做指针修复。当你的app当中有太多的Objective-C的类，方法选择器，和类别会增加这一部分的启动时间。有一个数据当大于20000个时候，会增加800ms的时间。另一点：当你的app中使用了很少的C++的虚拟函数，使用Swift会更加高效

* ObjC setup time 在Objective-C的运行时(runtime)，需要对类(class)，类别(category)进行注册，以及选择器的分配，所以参照rebase/binding time，尽量减少类的数量，可以达到减少这一部分的时间

* initializer time 这一份指代的是执行+initialize方法的时间。如果你执行了+load方法(不建议)，尽量使用+initialize代替。

