//
//  YYAnimatedImageView+JPExtension.m
//  JPBasic_Example
//
//  Created by aa on 2021/2/19.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//

#import "YYAnimatedImageView+JPExtension.h"
#import "NSObject+JPExtension.h"
#import <objc/runtime.h>

@implementation YYAnimatedImageView (JPExtension)

+ (void)load {
    if (@available(iOS 14.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self jp_swizzleInstanceMethodsWithOriginalSelector:@selector(displayLayer:) swizzledSelector:@selector(jp_displayLayer:)];
        });
    }
}

- (void)jp_displayLayer:(CALayer *)layer {
    Ivar ivar = class_getInstanceVariable(self.class, "_curFrame");
    UIImage *_curFrame = object_getIvar(self, ivar);
    if (_curFrame) {
        layer.contents = (__bridge id)_curFrame.CGImage;
    } else {
        [super displayLayer:layer];
    }
}

@end
