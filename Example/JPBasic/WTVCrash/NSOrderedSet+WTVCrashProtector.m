//
//  NSOrderedSet+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSOrderedSet+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSOrderedSet (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WTVCrashProtector swizzlingForClass:NSClassFromString(@"__NSPlaceholderOrderedSet")
                                 originalSel:@selector(initWithObjects:count:)
                                swizzlingSel:@selector(wtv_NSPlaceholderOrderedSet_initWithObjects:count:)];

        [WTVCrashProtector swizzlingForClass:NSClassFromString(@"__NSOrderedSetI")
                                 originalSel:@selector(objectAtIndex:)
                                swizzlingSel:@selector(wtv_NSOrderedSetI_objectAtIndex:)];
    });
}

#pragma mark - __NSPlaceholderOrderedSet
- (instancetype)wtv_NSPlaceholderOrderedSet_initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt {
    id instance = nil;
    @try {
        instance = [self wtv_NSPlaceholderOrderedSet_initWithObjects:objects count:cnt];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSOrderSet];
        NSUInteger newIndex = 0;
        id newObjects[cnt];
        for (int i = 0; i < cnt; i++) {
            if (objects[i]) {
                newObjects[newIndex] = objects[i];
                newIndex++;
            }
        }
        instance = [self wtv_NSPlaceholderOrderedSet_initWithObjects:newObjects count:newIndex];
    } @finally {
        return instance;
    }
}

#pragma mark - __NSOrderedSetI
- (id)wtv_NSOrderedSetI_objectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self wtv_NSOrderedSetI_objectAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSOrderSet];
    } @finally {
        return object;
    }
}
@end
