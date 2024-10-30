//
//  JPGCDSemaphoreTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2019/12/10.
//  Copyright © 2019 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPGCDSemaphoreTestViewController.h"

@interface JPGCDSemaphoreTestViewController ()
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation JPGCDSemaphoreTestViewController

static dispatch_semaphore_t semaphore_;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    JPLog(@"hello!");
}

- (void)dealloc {
    JPLog(@"%s", __func__);
}

// 退出并销毁操作，点了就pop吧
- (IBAction)action1:(id)sender {
    if (!semaphore_) semaphore_ = dispatch_semaphore_create(1);
    [self handle:@"任务a"];
    [self handle:@"任务b"];
    [self handle:@"任务c"];
    [self handle:@"任务d"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handle:(NSString *)name {
//    @jp_weakify(self);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        JPLog(@"%@准备开始 %@", name, semaphore_);
        
        dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
        
//        @jp_strongify(self);
//        if (!self) {
        if (!weakSelf) {
            JPLog(@"%@ 我死了 别继续了 %@", name, [NSThread currentThread]);
            dispatch_semaphore_signal(semaphore_);
            return;
        }
        
        JPLog(@"%@开始 %@", name, [NSThread currentThread]);
        sleep(3);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            JPLog(@"%@结束 %@", name, [NSThread currentThread]);
            dispatch_semaphore_signal(semaphore_);
        });
    });
}

// 证明semaphore的初始值并不是固定的最大值
// semaphoreCount：信号量剩余数，仅供参考
- (IBAction)action2:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 初始化0个
        __block NSInteger semaphoreCount = 0;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        semaphoreCount += 1;
        dispatch_semaphore_signal(semaphore);
        
        semaphoreCount += 1;
        dispatch_semaphore_signal(semaphore);
        
        NSLog(@"初始化信号量为0，signal两次，瞧瞧可不可以同时使用两条线程");
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL isNoSemaphore = semaphoreCount <= 0;
            if (isNoSemaphore) JPLog(@"任务a 没有信号量，卡住a线程，等到有信号量 --- %zd", semaphoreCount);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (isNoSemaphore) JPLog(@"任务a 有信号量了，a线程继续 --- %zd", semaphoreCount);
            if (semaphoreCount > 0) semaphoreCount -= 1;
            
            JPLog(@"任务a开始 %@", [NSThread currentThread]);
            sleep(2);
            
            semaphoreCount += 1;
            JPLog(@"任务a结束 --- %zd", semaphoreCount);
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL isNoSemaphore = semaphoreCount <= 0;
            if (isNoSemaphore) JPLog(@"任务b 没有信号量，卡住b线程，等到有信号量 --- %zd", semaphoreCount);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (isNoSemaphore) JPLog(@"任务b 有信号量了，b线程继续 --- %zd", semaphoreCount);
            if (semaphoreCount > 0) semaphoreCount -= 1;

            JPLog(@"任务b开始 %@", [NSThread currentThread]);
            sleep(3);
            
            semaphoreCount += 1;
            JPLog(@"任务b结束 --- %zd", semaphoreCount);
            dispatch_semaphore_signal(semaphore);
        });
        
        sleep(1);
        NSLog(@"可以看到开始了两个任务，明显这个初始值并不是固定的");
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL isNoSemaphore = semaphoreCount <= 0;
            if (isNoSemaphore) JPLog(@"任务c 没有信号量，卡住c线程，等到有信号量 --- %zd", semaphoreCount);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (isNoSemaphore) JPLog(@"任务c 有信号量了，c线程继续 --- %zd", semaphoreCount);
            if (semaphoreCount > 0) semaphoreCount -= 1;

            JPLog(@"任务c开始 %@", [NSThread currentThread]);
            sleep(3);
            
            semaphoreCount += 1;
            JPLog(@"任务c结束 --- %zd", semaphoreCount);
            dispatch_semaphore_signal(semaphore);
        });
    });
}

// 证明semaphoreCount至少要有1才可以执行代码，只要是0，dispatch_semaphore_wait就会等卡住线程等着
- (IBAction)action22:(id)sender {
    self.semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(self.semaphore);
    dispatch_semaphore_signal(self.semaphore);
    dispatch_semaphore_signal(self.semaphore); // 3
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER); // 3 - 1 = 2
    JPLog(@"hello1111!");
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER); // 2 - 1 = 1
    JPLog(@"hello2222!");
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER); // 1 - 1 = 0
    JPLog(@"hello3333!");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        JPLog(@"继续吧! 信号量+1!");
        long result = dispatch_semaphore_signal(self.semaphore); // 加1，主线程继续
        JPLog(@"如果【有】线程被唤醒，则此函数返回非零。--- %zd!", result);
        /*
         * PS: dispatch_semaphore_signal 会返回一个结果，文档解释为：
         * This function returns non-zero if a thread is woken. Otherwise, zero is returned. 如果线程被唤醒，则此函数返回非零。否则，返回零。
         * 这里执行后会有一条线程被唤醒，所以返回1，前面的3次signal()返回的都是0，说明没有线程被唤醒，不过信号量的确是有+1的。
         */
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);  // 等于0，等着
    JPLog(@"hello4444!");
}

// 阻塞当前线程等另一线程做完再继续
// semaphoreCount：信号量剩余数，仅供参考
- (IBAction)action3:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        JPLog(@"子线程任务开始 %@", [NSThread currentThread]);

        __block NSInteger semaphoreCount = 0;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            JPLog(@"其他线程任务开始 %zd %@", semaphoreCount, [NSThread currentThread]);
            sleep(3);

            semaphoreCount += 1;
            JPLog(@"其他线程任务结束 %zd %@", semaphoreCount, [NSThread currentThread]);
            dispatch_semaphore_signal(semaphore);
        });

        BOOL isNoSemaphore = semaphoreCount <= 0;
        if (isNoSemaphore) JPLog(@"没有信号量，卡住子线程，等到有信号量 --- %zd", semaphoreCount);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (isNoSemaphore) JPLog(@"有信号量了，子线程继续 --- %zd", semaphoreCount);
        if (semaphoreCount > 0) semaphoreCount -= 1;

        JPLog(@"子线程任务继续 %@", [NSThread currentThread]);
        sleep(3);
        JPLog(@"子线程任务结束 %@", [NSThread currentThread]);
    });
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        JPLog(@"子线程任务开始 %@", [NSThread currentThread]);
//
//        JPLog(@"先卡住子线程");
//
//        // 这样只会在当前线程执行，如果用dispatch_async虽然是新开线程但是不会卡住当前线程
//        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//            JPLog(@"其他线程任务开始 %@", [NSThread currentThread]);
//            sleep(3);
//            JPLog(@"其他线程任务结束 %@", [NSThread currentThread]);
//        });
//
//        JPLog(@"子线程任务继续 %@", [NSThread currentThread]);
//        sleep(3);
//        JPLog(@"子线程任务结束 %@", [NSThread currentThread]);
//    });
}

// 最基本的同步用法
- (IBAction)action4:(id)sender {
    self.semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        JPLog(@"任务a打算开始 %@", [NSThread currentThread]);
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        
        JPLog(@"任务a开始 %@", [NSThread currentThread]);
        sleep(3);
        
        JPLog(@"任务a结束 %@", [NSThread currentThread]);
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        JPLog(@"任务b打算开始 %@", [NSThread currentThread]);
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);

        JPLog(@"任务b开始 %@", [NSThread currentThread]);
        sleep(3);
        
        JPLog(@"任务b结束 %@", [NSThread currentThread]);
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        JPLog(@"任务c打算开始 %@", [NSThread currentThread]);
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        
        JPLog(@"任务c开始 %@", [NSThread currentThread]);
        sleep(3);
        
        JPLog(@"任务c结束 %@", [NSThread currentThread]);
        dispatch_semaphore_signal(self.semaphore);
    });
}


@end
