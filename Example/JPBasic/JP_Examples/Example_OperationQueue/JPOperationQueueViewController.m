//
//  JPOperationQueueViewController.m
//  JPBasic_Example
//
//  Created by aa on 2024/11/17.
//  Copyright © 2024 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPOperationQueueViewController.h"
#import "JPManualOperation.h"
#import "JPNormalOperation.h"
#import <FunnyButton-Swift.h>

@interface JPOperationQueueViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, weak) NSOperation *operation1;
@end

@implementation JPOperationQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
    self.queue = [[NSOperationQueue alloc] init];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self removeFunnyActions];
    
    @jp_weakify(self);
    
    /// 自定义`NSOperation`一旦被启动，就会自动执行任务，至少要到任务完成，`operation`才会自动销毁；
    /// 如果队列调用了`waitUntilAllOperationsAreFinished`，那就只能等到所有任务完成，才会销毁；
    /// 如果手动调用`cancel`，任务只是标记了取消（可以让队列提前结束`waitUntilAllOperationsAreFinished`），还是会继续执行直至完成，
    /// 所以手动取消`operation`不会马上被销毁，
    ///
    /// `NSBlockOperation`的取消形同虚设，不会让队列提前结束`waitUntilAllOperationsAreFinished`。
    ///
    
    [self addFunnyActionWithName:@"JPManualOperation 开始任务" work:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @jp_strongify(self);
            
            JPLog(@"所有任务开始！！！%@", [NSThread currentThread]);
            
            JPManualOperation *operation1 = [[JPManualOperation alloc] init];
            operation1.executionBlock = ^(void (^completion)(void)) {
                JPLog(@"任务1 开始 %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:20]; // 模拟任务耗时
                JPLog(@"任务1 完成 %@", [NSThread currentThread]);
                completion(); // 手动完成
            };
            [self.queue addOperation:operation1];
            self.operation1 = operation1;
            
            JPManualOperation *operation2 = [[JPManualOperation alloc] init];
            operation2.executionBlock = ^(void (^completion)(void)) {
                JPLog(@"任务2 开始 %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:11]; // 模拟任务耗时
                JPLog(@"任务2 完成 %@", [NSThread currentThread]);
                completion(); // 手动完成
            };
            [self.queue addOperation:operation2];
            
            JPManualOperation *operation3 = [[JPManualOperation alloc] init];
            operation3.executionBlock = ^(void (^completion)(void)) {
                JPLog(@"任务3 开始 %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:13]; // 模拟任务耗时
                JPLog(@"任务3 完成 %@", [NSThread currentThread]);
                completion(); // 手动完成
            };
            [self.queue addOperation:operation3];
            
            [self.queue waitUntilAllOperationsAreFinished];
            JPLog(@"所有任务结束！！！%@", [NSThread currentThread]);
        });
    }];
    
    [self addFunnyActionWithName:@"JPNormalOperation 开始任务" work:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @jp_strongify(self);
            
            JPLog(@"所有任务开始！！！%@", [NSThread currentThread]);
            
            JPNormalOperation *operation1 = [JPNormalOperation blockOperationWithBlock:^{
                JPLog(@"任务1 开始 %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:20]; // 模拟任务耗时
                JPLog(@"任务1 完成 %@", [NSThread currentThread]);
            }];
            [self.queue addOperation:operation1];
            self.operation1 = operation1;
            
            JPNormalOperation *operation2 = [JPNormalOperation blockOperationWithBlock:^{
                JPLog(@"任务2 开始 %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:11]; // 模拟任务耗时
                JPLog(@"任务2 完成 %@", [NSThread currentThread]);
            }];
            [self.queue addOperation:operation2];
            
            JPNormalOperation *operation3 = [JPNormalOperation blockOperationWithBlock:^{
                JPLog(@"任务3 开始 %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:13]; // 模拟任务耗时
                JPLog(@"任务3 完成 %@", [NSThread currentThread]);
            }];
            [self.queue addOperation:operation3];
            
            [self.queue waitUntilAllOperationsAreFinished];
            JPLog(@"所有任务结束！！！%@", [NSThread currentThread]);
        });
    }];
    
    [self addFunnyActionWithName:@"取消第一个任务" work:^{
        @jp_strongify(self);
        if (self.operation1) {
            JPLog(@"取消第一个任务，不用等20s那么久了");
            [self.operation1 cancel];
        }
    }];
    
    [self addFunnyActionWithName:@"取消全部任务" work:^{
        @jp_strongify(self);
        [self.queue cancelAllOperations];
    }];
}

- (void)dealloc {
    JPLog(@"JPOperationQueueViewController 死死死死");
}

@end
