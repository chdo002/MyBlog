---
title: 利用Runtime替换方法
date: 2018-03-24 12:11:33
tags: runtime track 埋点
---

小组最近想要去掉taikingdata，自己做个用户行为跟踪的组件，要点是，不能影响应用的性能，做到无感知记录，不需要修改原来工程的代码，任务排到我这，小小调研下，决定利用runtime相关方法，现记录如下


## 记录button点击事件

>  Method Swizzling 

###### 核心代码

```
void swizzling(Class orignClass, SEL orignSelector, Class switchClass, SEL switchSelector){
    // 原来的方法
    Method orginMethod = class_getInstanceMethod(orignClass, orignSelector);
    // 原来的实现
    IMP originImp = method_getImplementation(orginMethod);
    // 新的方法
    Method switchMethod = class_getInstanceMethod(switchClass, switchSelector);
    // 给原来的方法换成新的实现
    method_exchangeImplementations(orginMethod, switchMethod);
    // 将旧的实现新的方法添加到类中
    class_addMethod(orignClass, switchSelector, originImp, method_getTypeEncoding(orginMethod));
}

```

此方法的目的，将目标类的某个需要监听的方法的实现，换成自己的实现，在自己的实现中，又会调回原来的方法的实现，这样包装一下就可以监听到了。
需要注意的一个细节是，原方法的参数列表是未知的，需要特殊处理，这边是监听button的点击事件，所以，就简单的判断了一下，可以覆盖到全部的情况。

###### 具体实现

```
// APP启动时，加载所有的类，会调用load 方法
+(void)load{
	/*
	先替换掉，button的addtarget方法，这样可以拿到点击的响应方法，然后替换他
	*/
    // 原来的方法
    SEL originSel = @selector(addTarget:action:forControlEvents:);
    // 自己的方法
    SEL switchSel = @selector(newAddTarget:action:forContrState:);
    swizzling(UIButton.class, originSel, TRACK.class, switchSel);
}


-(void)newAddTarget:(id)targ action:(SEL)ac forContrState:(UIControlEvents)eve{
	// 此时的self已经指向了UIButton,所以要调用newAddTarget 让他执行旧的实现
    [self newAddTarget:targ action:ac forContrState:eve];

    // 获得响应方法的参数，正确的实现方式是动态的实现hook方法，并制定参数，但是这里就简单实现了
    unsigned int paraCount = method_getNumberOfArguments(class_getInstanceMethod([targ class], ac));
    
    if (paraCount == 2) {  // 至少有两个参数 self:调方法的对象  _cmd:SEL 方法签名
        swizzling([targ class], ac, TRACK.class, @selector(tapAcion));
    } else { // 有多余的参数的话，则应该是多了个UIbutton
        swizzling([targ class], ac, TRACK.class, @selector(tapActionWithPara:));
    }
}

// 对应的替换方法
-(void)tapAcion{
    [self performSelector:@selector(tapAcion)];
    NSLog(@"监听到了");
}

-(void)tapActionWithPara:(UIButton *)but{
    [self performSelector:@selector(tapActionWithPara:) withObject:but];
    NSLog(@"监听到了2");
}
```
