//
//  JPBBBViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/7/7.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPBBBViewController.h"
#import "JPBlock.h"

@interface JPBBBViewController ()
@property (nonatomic, copy) void (^block)(void);
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) JPBlock *myBlock;
@end

@implementation JPBBBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    JPBlock *bbb = [[JPBlock alloc] init];
    bbb.myBlock = ^(JPBlock * _Nonnull kbbb) {
        // 函数里面的对象引用不是原本的引用，函数拿到时是进行了引用拷贝
        JPLog(@"123123123 %@", kbbb);
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        bbb.myBlock(bbb);
    });
    
    return;
    
#pragma mark - GCD的block是系统持有的 不会有循环引用
    
    @jp_weakify(self);
    
    self.queue = dispatch_queue_create("abc", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), self.queue, ^{
////        JPLog(@"block --- %@", self);
//        JPLog(@"block --- %@", weak_self);
//    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        JPLog(@"block --- %@", self);
//        JPLog(@"block --- %@", weak_self);
//    });
    
    void (^block)(void) = ^{
        JPLog(@"123123123 --- %@", weak_self);
    };
    
//    self.block = ^{
//        JPLog(@"block --- %@", weak_self);
//    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), self.queue, ^{
//        JPLog(@"block --- %@", self);
        
        JPLog(@"block --- %@", block);
        block();
        
//        JPLog(@"block --- %@", self.block);
//        self.block();
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    JPLog(@"%s", __func__);
}

- (void)dealloc {
    JPLog(@"%s", __func__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
