---
title: RunLoop应用
date: 2018-04-25 17:25:02
tags:
---


> 网上关于runloop的解析已经更丰富了，这里只记录runloop的实践部分


RunLoop

# 干嘛的

为了实现线程不退出，可以随时接受消息执行任务，
node.js 的事件处理，windows程序的消息循环，iOS、OSX的RunLoop都是这种机制

线程和runloop一一对应，关系保存在全局字典中

主线程自带runloop，无需创建，新建的线程需要手动对应runloop，不让执行完成就结束了



# 常驻线程

常驻线程的意义，我理解是用来处理需要在子线程长期处理的事情，比如说记日志，埋点，IO数据处理等等之类。

这样想的话其实和NSOperationqueue或者GCD实现一个串行队列应该没有什么区别。

代码

```

static NSThread *workThread;


-(void)initThread{

	workThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];

	[workThread start];
}
	

// 让子线程runloop跑起来，防止线程结束
-(void)run{

    [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while (!_stopRunning) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}


// 这段代码直接复制自weex
// 在子线程执行代码
+ (void)_performBlockOnBridgeThread:(void (^)(void))block
{
    if ([NSThread currentThread] == workThread) {
        block();
    } else {
        [self performSelector:@selector(_performBlockOnBridgeThread:)
                     onThread:[self jsThread]
                   withObject:[block copy]
                waitUntilDone:NO];
    }
}


```


# runloop  observer

可以通过CFRunLoopAddObserver，给runloop添加观察者，具体实践如下


这是CDChatList中的一段代码，主要是为了实现，label在scrollview滚动时，去除选中文字的样式，如果不用runloop也是可以用通知或者其他的代理形式实现，但是会有一定的耦合

```
    currentMode = CFRunLoopCopyCurrentMode(CFRunLoopGetMain());

     __weak typeof(self) weakS = self;
    // 这里监听了所有的runloop事件，然后在回调中过滤出滚动事件，因为滚动事件会一直回调，所以这里需要特别处理，只观察进入滚动的时机
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (weakS) {
            __strong typeof(weakS) strongS = weakS;
            CFComparisonResult rest = CFStringCompare(strongS->currentMode, CFRunLoopCopyCurrentMode(CFRunLoopGetMain()), kCFCompareBackwards);
            if (rest != kCFCompareEqualTo) {
                strongS->currentMode = CFRunLoopCopyCurrentMode(CFRunLoopGetMain());
                if ((NSString *)CFBridgingRelease(strongS->currentMode) == UITrackingRunLoopMode) {
                    [strongS scrollDidScroll];
                }
            }
        }
    });
    
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
```




下面是YYTransaction中相关的代码，具有类似的实现，这里监听的目的应该是在runloop将要进入休眠时，把不需要立即执行的任务执行，以达到async的效果。

在AsyncDisplayKit中也有类似的用法

```
static NSMutableSet *transactionSet = nil;

static void YYRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactionSet.count == 0) return;
    NSSet *currentSet = transactionSet;
    transactionSet = [NSMutableSet new];
    [currentSet enumerateObjectsUsingBlock:^(YYTransaction *transaction, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transaction.target performSelector:transaction.selector];
#pragma clang diagnostic pop
    }];
}

static void YYTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [NSMutableSet new];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,      // repeat
                                           0xFFFFFF,  // after CATransaction(2000000)
                                           YYRunLoopObserverCallBack, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}
```


