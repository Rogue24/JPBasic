//
//  NSSet+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSSet+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSSet (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WTVCrashProtector swizzlingForClass:NSClassFromString(@"__NSPlaceholderSet")
                                 originalSel:@selector(initWithObjects:count:)
                                swizzlingSel:@selector(wtv_NSPlaceholderSet_initWithObjects:count:)];
    });
}
#pragma mark - __NSPlaceholderSet
- (instancetype)wtv_NSPlaceholderSet_initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt {
    id instance = nil;
    @try {
        instance = [self wtv_NSPlaceholderSet_initWithObjects:objects count:cnt];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSSet];
        NSUInteger newIndex = 0;
        id newObjects[cnt];
        for (int i = 0; i < cnt; i++) {
            if (objects[i]) {
                newObjects[newIndex] = objects[i];
                newIndex++;
            }
        }
        instance = [self wtv_NSPlaceholderSet_initWithObjects:newObjects count:newIndex];
    } @finally {
        return instance;
    }
}
@end
