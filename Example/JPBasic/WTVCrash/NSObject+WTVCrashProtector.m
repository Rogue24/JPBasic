//
//  NSObject+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSObject+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@interface WTVUnrecognizedSelectorProtector: NSObject
@property (nonatomic, assign) Class aClass;
@property SEL selector;
@end

@implementation WTVUnrecognizedSelectorProtector

- (void)unrecognizedSelectorProtector {
    NSString *reason = [NSString stringWithFormat:@"class:[%@] not found selector:(%@)",NSStringFromClass(self.aClass.class),NSStringFromSelector(self.selector)];

       NSException *exception = [NSException exceptionWithName:@"Unrecognized Selector"
                                                        reason:reason
                                                      userInfo:nil];
    [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeSelector];
}
@end


@implementation NSObject (WTVCrashProtector)
- (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"NSObject");
        // 第二道防线和第三道防线,二选一
        // 第二道防线实现
//        [WTVCrashProtector swizzlingForClass:aClass
//                                 originalSel:@selector(forwardingTargetForSelector:)
//                                swizzlingSel:@selector(wtv_forwardingTargetForSelector:)];

        // 第三道防线
        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(methodSignatureForSelector:)
                                swizzlingSel:@selector(wtv_methodSignatureForSelector:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(forwardInvocation:)
                                swizzlingSel:@selector(wtv_forwardInvocation:)];
    });
}

- (id)wtv_forwardingTargetForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [NSMethodSignature methodSignatureForSelector:aSelector];
    if (!signature && ![self respondsToSelector:aSelector]) {
        WTVUnrecognizedSelectorProtector *obj  = [WTVUnrecognizedSelectorProtector new];
        obj.selector = aSelector;
        obj.aClass = self.class;
        IMP imp = class_getMethodImplementation([WTVUnrecognizedSelectorProtector class], @selector(unrecognizedSelectorProtector));
        class_addMethod([obj class], aSelector, imp, "v@:");
        return obj;
    }
    return [self wtv_forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)wtv_methodSignatureForSelector:(SEL)aSelector {

    NSMethodSignature *signature = [self wtv_methodSignatureForSelector:aSelector];
    if (!signature && ![self respondsToSelector:aSelector]) {
        return [WTVUnrecognizedSelectorProtector instanceMethodSignatureForSelector:@selector(unrecognizedSelectorProtector)];
    }
    return signature;
}

- (void)wtv_forwardInvocation:(NSInvocation *)anInvocation{
    @try {
        [self wtv_forwardInvocation:anInvocation];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeSelector];
    } @finally {

    }
}


@end
