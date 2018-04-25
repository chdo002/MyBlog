---
title: RunLoop应用
date: 2018-04-25 17:25:02
tags:
---


> 网上关于runloop的解析已经更丰富了，这里只记录runloop的实践部分


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


# 常驻线程