---
title: GCD之NSoperation
date: 2018-04-20 11:00:03
tags:
---

> NSOperation是基于GCD的面相对象封装，这里把重点计一下。

# NSoperation的dependency


任务依赖是NSoperation的重要功能，可以让GCD的任务同步更直观的实现出来，不过有些地方也需要注意。


```
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1-1: %@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2-1");
    }];
    
    [op1 addDependency:op2];
    
    [op2 start];
    [op1 start];

```

由于op1依赖于op2的完成，如果`[op1 start]`写在`[op2 start]`前面的话，

会抛出异常`-[__NSOperationInternal _start:]: receiver is not yet ready to execute`,

你可以这么写

```
   NSOperationQueue *qq = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1-1: %@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2-1");
        
        NSLog(@"2-3");
    }];
    
    [op1 addDependency:op2];
    
    [qq addOperation:op1];
    [qq addOperation:op2];
```

就不需要关心触发顺序的问题了，因为NSOperationQueue会帮你管理


# NSoperation的queuePriority

queuePriority是次于dependency的属性，在dependency没有指明的情况下，NSOperationQueue会依据NSOperation的queuePriority来决定执行先后。



# 异步任务的同步问题


看以下代码

```
 NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"start-1");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           NSLog(@"end-1");
        });
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"start-2");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"end-2");
        });
    }];
    
    [op1 addDependency:op2];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
```

输出

```
2018-04-23 09:27:57.391220+0800 testP[20559:439375] start-2
2018-04-23 09:27:57.391494+0800 testP[20559:439382] start-1
2018-04-23 09:27:59.583992+0800 testP[20559:439102] end-2
2018-04-23 09:27:59.584309+0800 testP[20559:439102] end-1
```


可以发现，operationqueue对异步任务是不能同步的，想要实现对异步任务的同步，就得重写NSOperation子类，也就是控制他的isFinished属性。

NSOperation是通过KVO isFinished/isExecuting等属性来判断任务的生命周期，重写这几个关键属性就可以了，上代码

```
@interface SubOperation:NSBlockOperation
{
    // 这是我们用来代替isFinishe的属性
    BOOL sub_isFinish;
}


-(void)stopOperation;
@end

@implementation SubOperation


// 重写isFinished，替换掉他
-(BOOL)isFinished{
    return sub_isFinish;
}

/*
 * 这里需要手动调用此方法，来告诉operation，需要调用isFinished来结束operation
 * 为什么没有直接调，setvalueforkey的方法呢，试试看就知道了
 */ 

-(void)stopOperation{
    [self willChangeValueForKey:@"isFinished"];
    sub_isFinish = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end
```



现在重新测试下，需要加上我们手动的方法，可以发现可以实现异步任务同步了
```
 NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    __block SubOperation *op1;
    op1 = [SubOperation blockOperationWithBlock:^{
        NSLog(@"start-1");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"end-1");
            [op1 stopOperation];
        });
    }];
    
    __block SubOperation *op2;
    op2 = [SubOperation blockOperationWithBlock:^{
        NSLog(@"start-2");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"end-2");
            [op2 stopOperation];
        });
    }];
    
    [op1 addDependency:op2];
    
    [queue addOperation:op1];
    [queue addOperation:op2];


2018-04-23 09:30:41.700824+0800 testP[20651:442268] start-2
2018-04-23 09:30:43.895327+0800 testP[20651:442214] end-2
2018-04-23 09:30:43.895927+0800 testP[20651:442271] start-1
2018-04-23 09:30:46.089130+0800 testP[20651:442214] end-1

```



# 参考链接

[iOS多线程：『NSOperation、NSOperationQueue』详尽总结](https://www.jianshu.com/p/4b1d77054b35")



