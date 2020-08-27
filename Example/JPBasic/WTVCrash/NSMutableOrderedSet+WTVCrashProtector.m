//
//  NSMutableOrderedSet+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSMutableOrderedSet+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSMutableOrderedSet (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"__NSOrderedSetM");

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(addObject:)
                                swizzlingSel:@selector(wtv_NSOrderedSetM_addObject:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(insertObject:atIndex:)
                                swizzlingSel:@selector(wtv_NSOrderedSetM_insertObject:atIndex:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(objectAtIndex:)
                                swizzlingSel:@selector(wtv_NSOrderedSetM_objectAtIndex:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(removeObjectAtIndex:)
                                swizzlingSel:@selector(wtv_NSOrderedSetM_removeObjectAtIndex:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(replaceObjectAtIndex:withObject:)
                                swizzlingSel:@selector(wtv_NSOrderedSetM_replaceObjectAtIndex:withObject:)];
    });
}

#pragma mark - __NSOrderedSetM
- (void)wtv_NSOrderedSetM_addObject:(id)anObject {
    @try {
        [self wtv_NSOrderedSetM_addObject:anObject];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableOrderSet];
    } @finally {

    }
}

- (void)wtv_NSOrderedSetM_insertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self wtv_NSOrderedSetM_insertObject:anObject atIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableOrderSet];
    } @finally {

    }
}

- (id)wtv_NSOrderedSetM_objectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self wtv_NSOrderedSetM_objectAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableOrderSet];
    } @finally {
        return object;
    }
}

- (void)wtv_NSOrderedSetM_removeObjectAtIndex:(NSUInteger)index {
    @try {
        [self wtv_NSOrderedSetM_removeObjectAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableOrderSet];
    } @finally {

    }
}

- (void)wtv_NSOrderedSetM_replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object {
    @try {
        [self wtv_NSOrderedSetM_replaceObjectAtIndex:idx withObject:object];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableOrderSet];
    } @finally {

    }
}
@end
