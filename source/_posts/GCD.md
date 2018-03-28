---
title: GCD
date: 2018-03-28 17:31:01
tags:
---

平时没有怎么用的概念，但是很重要，这里记一下



# 怎么让线程同步

## Dispatch Group


需要在大量任务都执行完成后，执行其他任务，可以用 Dispatch Group

```
// 可以理解为一个任务组，组内的任务完成后就会调用dispatch_group_notify
dispatch_group_t group = dispatch_group_create();
dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

dispatch_group_async(group, queue, ^{
    for (int i = 0; i < 1000; i++) {
    if (i == 999) {
        NSLog(@"11111111");
    }
}

});

dispatch_group_async(group, queue, ^{
    NSLog(@"22222222");
});

dispatch_group_async(group, queue, ^{
    NSLog(@"33333333");
});

dispatch_group_notify(group, queue, ^{
    NSLog(@"done");
});

```

## dispatch_barrier_sync 和 dispatch_barrier_async
![网上找到的](https://img-blog.csdn.net/20150726170216381)

```

dispatch_async(queue, ^{
    NSLog(@"1");
});

dispatch_async(queue, ^{
    NSLog(@"2");
});
dispatch_async(queue, ^{
    NSLog(@"3");
});


// dispatch_barrier_sync 这个和  dispatch_async与dispatch_sync之间的区别类似
dispatch_barrier_async(queue, ^{
    NSLog(@"000000");
});

dispatch_async(queue, ^{
    NSLog(@"4");
});

dispatch_async(queue, ^{
    NSLog(@"5");
});
dispatch_async(queue, ^{
    NSLog(@"6");
});
```

## dispatch_semaphore

```
1、dispatch_semaphore_create 创建一个semaphore  就是创建一个全局的变量，小于0时会阻塞当前线程
2、dispatch_semaphore_signal 发送一个信号       给信号量加1
3、dispatch_semaphore_wait 等待信号   给信号量减1
```
这个东西本质是就是立flag，让flag小于0，线程就阻塞了，只有让flag大于0，才能继续

网上的说明例子
```
// 创建队列组
dispatch_group_t group = dispatch_group_create();
// 创建信号量，并且设置值为10
dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
for (int i = 0; i < 100; i++){
// 由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，从而semaphore-1.当循环10此后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_group_async(group, queue, ^{
        NSLog(@"%i",i);
        sleep(2);
        // 每次发送信号则semaphore会+1，
        dispatch_semaphore_signal(semaphore);
    });
}

```

应用1 网络请求

```
_block BOOL isok = NO;

dispatch_semaphore_t sema = dispatch_semaphore_create(0);
Engine *engine = [[Engine alloc] init];
[engine queryCompletion:^(BOOL isOpen) {
    isok = isOpen;
    dispatch_semaphore_signal(sema);
} onError:^(int errorCode, NSString *errorMessage) {
    isok = NO;
    dispatch_semaphore_signal(sema);
}];
dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
// todo what you want to do after net callback
```

应用2  获取权限
```
//创建通讯簿的引用
addBook=ABAddressBookCreateWithOptions(NULL, NULL);
//创建一个出事信号量为0的信号
dispatch_semaphore_t sema=dispatch_semaphore_create(0);
//申请访问权限
ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error)
{
    //greanted为YES是表示用户允许，否则为不允许
    if (!greanted) {
        tip=1;
    }
    //发送一次信号
    dispatch_semaphore_signal(sema);

});
//等待信号触发
dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

```


