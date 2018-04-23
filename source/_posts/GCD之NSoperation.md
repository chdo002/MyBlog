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





# 参考链接

[iOS多线程：『NSOperation、NSOperationQueue』详尽总结](https://www.jianshu.com/p/4b1d77054b35")



