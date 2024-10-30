//
//  JPBlock.m
//  JPBasic_Example
//
//  Created by 周健平 on 2021/2/17.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPBlock.h"

@implementation JPBlock

- (instancetype)init {
    if (self = [super init]) {
        JPLog(@"%s", __FUNCTION__);
    }
    return self;
}

- (void)dealloc {
    JPLog(@"%s", __FUNCTION__);
}

@end
