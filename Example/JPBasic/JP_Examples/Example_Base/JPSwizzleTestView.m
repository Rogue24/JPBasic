//
//  JPSwizzleTestView.m
//  JPBasic_Example
//
//  Created by aa on 2023/1/17.
//  Copyright © 2023 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPSwizzleTestView.h"
#import <objc/runtime.h>

@implementation JPSwizzleTestView

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(my_log));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(jp_log));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)my_log {
    JPLog(@"origin my_log %zd", self.tag);
}

- (void)jp_log {
    if (self.tag != 44) {
        [self jp_log];
        return;
    }
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:JPSwizzleTestView.class]) {
            // 1.子类没有重写my_log：走交换的方法 jp_log line -> 26 -> 28 -> 23
            // 2.子类有重写了my_log：走自己的方法 my_log line -> 53
            [(JPSwizzleTestView *)subview my_log];
            
            // 走原有的方法 my_log line -> 23
            [(JPSwizzleTestView *)subview jp_log];
        }
        JPLog(@"=======");
    }
    
    JPLog(@"hooked jp_log %zd", self.tag);
}

@end

@implementation JPSwizzleTestView2

- (void)my_log {
    // 会优先调用子类的方法，不会走交换后的方法
    JPLog(@"override my_log %zd", self.tag);
    
    // 除非调用super去调用（交换后的方法）
//    [super my_log];
}

@end
