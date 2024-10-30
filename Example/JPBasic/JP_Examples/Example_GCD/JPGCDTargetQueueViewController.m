//
//  JPGCDTargetQueueViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/21.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPGCDTargetQueueViewController.h"

@interface JPGCDTargetQueueViewController ()
@property (nonatomic, strong) dispatch_queue_t serialQueue1;
@property (nonatomic, strong) dispatch_queue_t serialQueue2;
@property (nonatomic, strong) dispatch_queue_t serialQueue3;
@property (nonatomic, strong) dispatch_queue_t serialQueue4;
@property (nonatomic, strong) dispatch_queue_t serialQueue5;
@property (nonatomic, strong) dispatch_queue_t serialQueue6;

@property (nonatomic, strong) dispatch_queue_t concurrentQueue1;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue2;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue3;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue4;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue5;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue6;
@end

@implementation JPGCDTargetQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serialQueue1 = dispatch_queue_create("serialQueue1", DISPATCH_QUEUE_SERIAL);
    self.serialQueue2 = dispatch_queue_create("serialQueue2", DISPATCH_QUEUE_SERIAL);
    self.serialQueue3 = dispatch_queue_create("serialQueue3", DISPATCH_QUEUE_SERIAL);
    self.serialQueue4 = dispatch_queue_create("serialQueue4", DISPATCH_QUEUE_SERIAL);
    self.serialQueue5 = dispatch_queue_create("serialQueue5", DISPATCH_QUEUE_SERIAL);
    self.serialQueue6 = dispatch_queue_create("serialQueue6", DISPATCH_QUEUE_SERIAL);
    
    // 创建另一个名字一样的队列，那也是两个不同的队列
//    dispatch_queue_t queue1 = dispatch_queue_create("serialQueue1", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (NSInteger i = 0; i < 10; i++) {
//            dispatch_async(self.serialQueue1, ^{
//                JPLog(@"1 --- %zd %@", i, [NSThread currentThread]);
//                sleep(1);
//            });
//        }
//        for (NSInteger i = 0; i < 10; i++) {
//            dispatch_async(queue1, ^{
//                JPLog(@"2 --- %zd %@", i, [NSThread currentThread]);
//                sleep(2);
//            });
//        }
//    });
//    return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JPLog(@"111 %@", [NSThread currentThread]);
        dispatch_sync(self.serialQueue1, ^{
            JPLog(@"222 %@", [NSThread currentThread]);
        });
        for (NSInteger i = 0; i < 10; i++) {
            dispatch_async(self.serialQueue1, ^{
                JPLog(@"1 %zd %@", i, [NSThread currentThread]);
            });
        }
        
        sleep(3);
        
        for (NSInteger i = 0; i < 10; i++) {
            dispatch_async(self.serialQueue1, ^{
                JPLog(@"2 %zd %@", i, [NSThread currentThread]);
            });
        }
        
        JPLog(@"333 %@", [NSThread currentThread]);
    });
    return;
    
    self.concurrentQueue1 = dispatch_queue_create("concurrentQueue1", DISPATCH_QUEUE_CONCURRENT);
    self.concurrentQueue2 = dispatch_queue_create("concurrentQueue2", DISPATCH_QUEUE_CONCURRENT);
    self.concurrentQueue3 = dispatch_queue_create("concurrentQueue3", DISPATCH_QUEUE_CONCURRENT);
    self.concurrentQueue4 = dispatch_queue_create("concurrentQueue4", DISPATCH_QUEUE_CONCURRENT);
    self.concurrentQueue5 = dispatch_queue_create("concurrentQueue5", DISPATCH_QUEUE_CONCURRENT);
    self.concurrentQueue6 = dispatch_queue_create("concurrentQueue6", DISPATCH_QUEUE_CONCURRENT);
    
    // dispatch_set_target_queue：将队列丢入目标队列管理
    
    // 例子1：多个（不管是串行还是并行的）队列丢入到一个串行队列中管理，全部任务都会一个一个地排队执行
    dispatch_queue_t targetQueue = dispatch_queue_create("targetQueue", DISPATCH_QUEUE_SERIAL);
    // 多个串行队列：
    // 设置前：全部队列一起开始，顺序不确定，每个队列里面的任务会排队执行，队列之间互不相干
    // 设置后：全部队列的任务都会一个一个地排队执行
    dispatch_set_target_queue(self.serialQueue3, targetQueue);
    dispatch_set_target_queue(self.serialQueue4, targetQueue);
    // 多个并行队列：
    // 设置前：全部队列一起开始，顺序不确定，每个队列里面的任务也是一起开始，也是顺序不确定
    // 设置后：全部队列的任务都会一个一个地排队执行
    dispatch_set_target_queue(self.concurrentQueue3, targetQueue);
    dispatch_set_target_queue(self.concurrentQueue4, targetQueue);
    
    // 例子2：给自定义队列设置优先级 --- 优先级只有全局并发队列可以设置，那就将自定义队列丢到目标优先级的全局并发队列
    // 设置前：全部队列一起开始，顺序不确定，队列之间互不相干
    // 设置后：保证优先级高的队列的任务先执行
    dispatch_set_target_queue(self.serialQueue5, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    dispatch_set_target_queue(self.serialQueue6, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    dispatch_set_target_queue(self.concurrentQueue5, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    dispatch_set_target_queue(self.concurrentQueue6, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
}

- (IBAction)before:(id)sender {
    JPLog(@"-----------------------serial before-----------------------");
    dispatch_async(self.serialQueue1, ^{
        NSLog(@"serialQueue1 000 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue1 000 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.serialQueue1, ^{
        NSLog(@"serialQueue1 111 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue1 111 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.serialQueue2, ^{
        NSLog(@"serialQueue2 000 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue2 000 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.serialQueue2, ^{
        NSLog(@"serialQueue2 111 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue2 111 out --- %@", [NSThread currentThread]);
    });
}

- (IBAction)after:(id)sender {
    NSLog(@"-----------------------serial after-----------------------");
    dispatch_async(self.serialQueue3, ^{
        NSLog(@"serialQueue3 000 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue3 000 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.serialQueue3, ^{
        NSLog(@"serialQueue3 111 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue3 111 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.serialQueue4, ^{
        NSLog(@"serialQueue4 000 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue4 000 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.serialQueue4, ^{
        NSLog(@"serialQueue4 111 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue4 111 out --- %@", [NSThread currentThread]);
    });
}

- (IBAction)before2:(id)sender {
    NSLog(@"-----------------------concurrent before-----------------------");
    dispatch_async(self.concurrentQueue1, ^{
        NSLog(@"concurrentQueue1 000 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue1 000 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.concurrentQueue1, ^{
        NSLog(@"concurrentQueue1 111 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue1 111 out --- %@", [NSThread currentThread]);
    });
    
    dispatch_async(self.concurrentQueue2, ^{
        NSLog(@"concurrentQueue2 000 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue2 000 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.concurrentQueue2, ^{
        NSLog(@"concurrentQueue2 111 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue2 111 out --- %@", [NSThread currentThread]);
    });
}

- (IBAction)after2:(id)sender {
    NSLog(@"-----------------------concurrent after-----------------------");
    dispatch_async(self.concurrentQueue3, ^{
        NSLog(@"concurrentQueue3 000 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue3 000 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.concurrentQueue3, ^{
        NSLog(@"concurrentQueue3 111 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue3 111 out --- %@", [NSThread currentThread]);
    });
    
    dispatch_async(self.concurrentQueue4, ^{
        NSLog(@"concurrentQueue4 000 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue4 000 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.concurrentQueue4, ^{
        NSLog(@"concurrentQueue4 111 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue4 111 out --- %@", [NSThread currentThread]);
    });
}

- (IBAction)before3:(id)sender {
    dispatch_async(self.serialQueue1, ^{
        NSLog(@"serialQueue1 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue1 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.serialQueue2, ^{
        NSLog(@"serialQueue2 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue2 out --- %@", [NSThread currentThread]);
    });
    
    dispatch_async(self.concurrentQueue1, ^{
        NSLog(@"concurrentQueue1 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue1 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.concurrentQueue2, ^{
        NSLog(@"concurrentQueue2 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue2 out --- %@", [NSThread currentThread]);
    });
}

- (IBAction)after3:(id)sender {
    dispatch_async(self.serialQueue5, ^{
        NSLog(@"serialQueue5 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue5 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.serialQueue6, ^{
        NSLog(@"serialQueue6 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"serialQueue6 out --- %@", [NSThread currentThread]);
    });
    
    dispatch_async(self.concurrentQueue5, ^{
        NSLog(@"concurrentQueue5 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue5 out --- %@", [NSThread currentThread]);
    });

    dispatch_async(self.concurrentQueue6, ^{
        NSLog(@"concurrentQueue6 in --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"concurrentQueue6 out --- %@", [NSThread currentThread]);
    });
}
@end
