//
//  JPBarrierViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/4/10.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPBarrierViewController.h"

@interface JPBarrierViewController ()
@property (nonatomic, strong) dispatch_queue_t recordModelQueue;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger count;
@end

@implementation JPBarrierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    self.recordModelQueue = dispatch_queue_create("recordModelQueue", DISPATCH_QUEUE_CONCURRENT);
    
    UIButton *btn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = JPScaleBoldFont(20);
        [btn setTitle:@"写" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(write) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(100, 100, 200, 100);
        btn.backgroundColor = JPRandomColor;
        btn;
    });
    [self.view addSubview:btn];
    
    self.timer = [NSTimer timerWithTimeInterval:0.2 target:JPTargetProxy(self) selector:@selector(timerHandle) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerHandle {
    dispatch_async(self.recordModelQueue, ^{
        JPLog(@"async read %zd --- %@", self.count, [NSThread currentThread]);
    });
    
    dispatch_sync(self.recordModelQueue, ^{
        JPLog(@"sync read %zd --- %@", self.count, [NSThread currentThread]);
    });
}

- (void)write {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JPLog(@"sync write start --- %@", [NSThread currentThread]);
        for (NSInteger i = 0; i < 5; i++) {
            dispatch_barrier_sync(self.recordModelQueue, ^{
                self.count += 1;
                JPLog(@"sync write %zd --- %@", self.count, [NSThread currentThread]);
            });
        }
        for (NSInteger i = 0; i < 5; i++) {
            dispatch_barrier_sync(self.recordModelQueue, ^{
                self.count += 1;
                JPLog(@"sync write %zd --- %@", self.count, [NSThread currentThread]);
            });
        }
    });
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        JPLog(@"async write start --- %@", [NSThread currentThread]);
//
//        for (NSInteger i = 0; i < 5; i++) {
//            dispatch_barrier_async(self.recordModelQueue, ^{
//                self.count += 1;
//                JPLog(@"async write %zd --- %@", self.count, [NSThread currentThread]);
//            });
//        }
//
//        for (NSInteger i = 0; i < 5; i++) {
//            dispatch_barrier_async(self.recordModelQueue, ^{
//                self.count += 1;
//                JPLog(@"async write %zd --- %@", self.count, [NSThread currentThread]);
//            });
//        }
//    });
}

@end
