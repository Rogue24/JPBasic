//
//  JPManualOperation.m
//  JPBasic_Example
//
//  Created by aa on 2024/11/17.
//  Copyright © 2024 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPManualOperation.h"

@implementation JPManualOperation
{
    BOOL _isExecuting;
    BOOL _isFinished;
}

- (instancetype)init {
    if (self = [super init]) {
        _isExecuting = NO;
        _isFinished = NO;
    }
    return self;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isAsynchronous {
    return YES; // 异步操作
}

- (void)start {
    // 如果任务被取消，则直接完成
    if (self.isCancelled) {
        [self finish];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    // 执行任务
    if (self.executionBlock) {
        @jp_weakify(self);
        self.executionBlock(^{
            @jp_strongify(self);
            if (!self) return;
            if (self.isCancelled) {
                JPLog(@"任务已经被取消");
            }
            if (self->_isExecuting) {
                JPLog(@"任务执行完成，调用finish");
                [self finish];
            } else {
                JPLog(@"已经调用过finish");
            }
        });
    } else {
        [self finish];
    }
}

- (void)cancel {
    [super cancel];

    // 如果任务正在执行，可以选择立即完成
    if (_isExecuting) {
        JPLog(@"取消任务时立即调用 finish");
        [self finish];
    }
}

- (void)finish {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)dealloc {
    JPLog(@"JPManualOperation 死死死死 %@", self);
}

@end
