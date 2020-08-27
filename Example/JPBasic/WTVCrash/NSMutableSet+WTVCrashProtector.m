//
//  NSMutableSet+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSMutableSet+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSMutableSet (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"__NSSetM");

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(addObject:)
                                swizzlingSel:@selector(wtv_NSSetM_addObject:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(removeObject:)
                                swizzlingSel:@selector(wtv_NSSetM_removeObject:)];
    });
}

#pragma mark - __NSSetM
- (void)wtv_NSSetM_addObject:(id)object {
    @try {
        [self wtv_NSSetM_addObject:object];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableSet];
    } @finally {

    }
}

- (void)wtv_NSSetM_removeObject:(id)object {
    @try {
        [self wtv_NSSetM_removeObject:object];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableSet];
    } @finally {

    }
}
@end
