//
//  JPGCDSpecificTestViewController.m
//  JPBasic_Example
//
//  Created by aa on 2021/7/5.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//
//  通过 specific 给队列设置标识，可以用来判断某条线程是否在目标队列中

#import "JPGCDSpecificTestViewController.h"

@interface JPGCDSpecificTestViewController ()
@property (nonatomic, strong) dispatch_queue_t myQueue;
@end

@implementation JPGCDSpecificTestViewController

static void *queueKey1 = "queueKey1";
static void *queueKey2 = "queueKey2";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
    self.myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_queue_set_specific(self.myQueue, queueKey1, &queueKey1, NULL);
    dispatch_queue_set_specific(dispatch_get_main_queue(), queueKey2, &queueKey2, NULL);
    
    if (dispatch_queue_get_specific(self.myQueue, queueKey1)) {
        JPLog(@"myQueue 存在 queueKey1");
    } else {
        JPLog(@"myQueue 不存在 queueKey1");
    }
    if (dispatch_queue_get_specific(self.myQueue, queueKey2)) {
        JPLog(@"myQueue 存在 queueKey2");
    } else {
        JPLog(@"myQueue 不存在 queueKey2");
    }
    
    if (dispatch_queue_get_specific(dispatch_get_main_queue(), queueKey1)) {
        JPLog(@"mainQueue 存在 queueKey1");
    } else {
        JPLog(@"mainQueue 不存在 queueKey1");
    }
    if (dispatch_queue_get_specific(dispatch_get_main_queue(), queueKey2)) {
        JPLog(@"mainQueue 存在 queueKey2");
    } else {
        JPLog(@"mainQueue 不存在 queueKey2");
    }
    
    UIButton *btn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = JPScaleBoldFont(20);
        [btn setTitle:@"Check" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(check) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(100, 100, 200, 100);
        btn.backgroundColor = JPRandomColor;
        btn;
    });
    [self.view addSubview:btn];
}

- (void)check {
    JPLog(@"%@", [NSThread currentThread]);
    
    if (dispatch_get_specific(queueKey1)) {
        JPLog(@"当前线程在 myQueue 里面");
    } else {
        JPLog(@"当前线程不在 myQueue 里面");
        
        dispatch_async(self.myQueue, ^{
            [self check];
        });
    }
    
    if (dispatch_get_specific(queueKey2)) {
        JPLog(@"当前线程在 mainQueue 里面");
    } else {
        JPLog(@"当前线程不在 mainQueue 里面");
    }
    
    JPLog(@"-----------------");
}
    

@end
