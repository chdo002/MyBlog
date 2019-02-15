---
title: NSArrary强引用问题
date: 2019-02-15 15:56:06
tags:
---

在iOS的本地通知功能中，有个细节。

一般使用通知功能`NSNotification`，都需要添加和移除观察者，否则会引起一些问题：

在iOS9以下，如果观察者已经被释放，但是没有移除出通知中心，那么当这个通知发出时，会引起野指针崩溃，iOS9以上对这个问题做了优化，没有手动移除的话，也不会发生什么，估计苹果也认为自动释放会显得智能一点。


关于iOS如何做到在观察者`dealloc`的时候，[自动移除观察者](https://juejin.im/entry/5a8fe5c551882518c0797ebe)，网上也有现成的案，这里只是通过这个事情联想到，数组强引用的问题。

Foundation中数组在元素被添加的时候(这里的数组指平常使用的NSArray和NSMutableArray)会强引用持有，就算使用`__weak`修饰也没有用，导致一些奇特的内存泄漏和循环引用问题。

那么除了业务注意的话，就是要找到一些若引用集合`	Weak Reference Collection`的实现方法了.


### 方法0：使用弱引用包装

```
NSValue *value1 = [NSValue valueWithNonretainedObject:_obj1];
[_array addObject:value1];
```

`NSValue`可以对某对象弱音引用的方法，我们再将value保存到数组中就可以了。
但是不建议使用`NSValue`，可以使用自定义的类来实现，因为`valueWithNonretainedObject`并不会判空，同时，释放掉的对象，也不会将引用置为空，导致野指针问题。

### 方法1：使用CoreFoundation

使用`CoreFoundation`中的`CFArrayCreateMutable`，可以实现弱引用数组。
但是需要小心内存释放问题，同时还要注意类型准换。
所以不建议使用此方法。


参考：

https://stackoverflow.com/questions/4692161/non-retaining-array-for-delegates
https://www.jianshu.com/p/5c98ac2dab58
https://www.jianshu.com/p/ed2030920ec4


### 方法2：使用NSPointerArray

`NSPointerArray`可以很好的解决数据类型和自动置空的问题

NSPointerArray提供`strongObjectsPointerArray`和`weakObjectsPointerArray`工厂，`weakObjectsPointerArray`就是我们需要的弱引用数组方法。

`NSPointerArray`也处理了元素释放导致数组元素个数不稳定的问题：添加了`allObjects`属性，代表所有未释放的对象，而原本的`count`则表示所有元素个数。

```
 _storage = [NSPointerArray weakObjectsPointerArray];

[_storage addPointer:(__bridge void *)(obj)];

[_storage pointerAtIndex:0]; //obj   此处返回的是对象指针，如果对象已经释放，则为nil.

```

参考：

https://yq.aliyun.com/articles/29434<br>
https://blog.csdn.net/kaiyuanheshang/article/details/52944565


### 方法3：使用NSHashTable和NSMapTable

`NSHashTable`和`NSMapTable`使用思路类似`NSPointerArray`,同时也有实现弱引用的工厂方法，用来满足弱引用的需求。

二者同`NSPointerArray`区别在于`NSHashTable`可以看成`NSSet`,`NSMapTable`可以看成`NSDictionary`。