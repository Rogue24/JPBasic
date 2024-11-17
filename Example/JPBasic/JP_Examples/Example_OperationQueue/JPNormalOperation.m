//
//  JPNormalOperation.m
//  JPBasic_Example
//
//  Created by aa on 2024/11/17.
//  Copyright © 2024 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPNormalOperation.h"

@implementation JPNormalOperation

- (void)start {
    JPLog(@"start %@", self);
    [super start];
}

- (void)cancel {
    JPLog(@"cancel %@", self);
    [super cancel];
}

- (void)dealloc {
    JPLog(@"JPNormalOperation 死死死死 %@", self);
}

@end

