//
//  NSMutableArray+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSMutableArray+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSMutableArray (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // __NSPlaceholderArray
        [WTVCrashProtector swizzlingForClass:objc_getClass("__NSPlaceholderArray")
                                 originalSel:@selector(initWithObjects:count:)
                                swizzlingSel:@selector(wtv_NSPlaceholderArray_initWithObjects:count:)];
        
        // __NSArrayM
        Class NSArrayMClass = NSClassFromString(@"__NSArrayM");

        //因为11.0以上系统才会调用此方法，所以大于11.0才交换此方法
        if (@available(iOS 11.0, *)) {
            [WTVCrashProtector swizzlingForClass:NSArrayMClass
                                     originalSel:@selector(objectAtIndexedSubscript:)
                                    swizzlingSel:@selector(wtv_NSArrayM_objectAtIndexedSubscript:)];
        }

        [WTVCrashProtector swizzlingForClass:NSArrayMClass
                                 originalSel:@selector(insertObject:atIndex:)
                                swizzlingSel:@selector(wtv_NSArrayM_insertObject:atIndex:)];

        [WTVCrashProtector swizzlingForClass:NSArrayMClass
                                 originalSel:@selector(removeObjectAtIndex:)
                                swizzlingSel:@selector(wtv_NSArrayM_removeObjectAtIndex:)];

        [WTVCrashProtector swizzlingForClass:NSArrayMClass
                                 originalSel:@selector(removeObjectsInRange:)
                                swizzlingSel:@selector(wtv_NSArrayM_removeObjectsInRange:)];

        [WTVCrashProtector swizzlingForClass:NSArrayMClass
                                 originalSel:@selector(replaceObjectAtIndex:withObject:)
                                swizzlingSel:@selector(wtv_NSArrayM_replaceObjectAtIndex:withObject:)];

        // __NSCFArray
        Class NSCFArrayClass = NSClassFromString(@"__NSCFArray");
        // 因为11.0以上系统才会调用此方法，所以大于11.0才交换此方法
        if (@available(iOS 11.0, *)) {
            [WTVCrashProtector swizzlingForClass:NSCFArrayClass
                                     originalSel:@selector(objectAtIndexedSubscript:)
                                    swizzlingSel:@selector(wtv_NSCFArray_objectAtIndexedSubscript:)];
        }

        [WTVCrashProtector swizzlingForClass:NSCFArrayClass
                                 originalSel:@selector(insertObject:atIndex:)
                                swizzlingSel:@selector(wtv_NSCFArray_insertObject:atIndex:)];

        [WTVCrashProtector swizzlingForClass:NSCFArrayClass
                                 originalSel:@selector(removeObjectAtIndex:)
                                swizzlingSel:@selector(wtv_NSCFArray_removeObjectAtIndex:)];

        [WTVCrashProtector swizzlingForClass:NSCFArrayClass
                                 originalSel:@selector(removeObjectsInRange:)
                                swizzlingSel:@selector(wtv_NSCFArray_removeObjectsInRange:)];

        [WTVCrashProtector swizzlingForClass:NSCFArrayClass
                                 originalSel:@selector(replaceObjectAtIndex:withObject:)
                                swizzlingSel:@selector(wtv_NSCFArray_replaceObjectAtIndex:withObject:)];

    });

}

#pragma mark - __NSPlaceholderArray
- (instancetype)wtv_NSPlaceholderArray_initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt {
    id instance = nil;
    @try {
        instance = [self wtv_NSPlaceholderArray_initWithObjects:objects count:cnt];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSArray];

        // 对异常数据处理
        NSInteger newObjcetsIndex = 0;
        id newObjects[cnt];
        for (int i = 0; i < cnt; i++) {
            if (objects[i] != nil) {
                newObjects[newObjcetsIndex] = objects[i];
                newObjcetsIndex++;
            }
        }
        instance = [self wtv_NSPlaceholderArray_initWithObjects:newObjects count:newObjcetsIndex];
    } @finally {
        return instance;
    }
}


#pragma mark - __NSArrayM
- (id)wtv_NSCFArray_objectAtIndexedSubscript:(NSUInteger)idx {
    id object = nil;
    @try {
        object = [self wtv_NSCFArray_objectAtIndexedSubscript:idx];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {
        return object;
    }
}

//- (id)wtv_NSArrayM_objectAtIndex:(NSUInteger)index {
//    id object = nil;
//    @try {
//        object = [self wtv_NSArrayM_objectAtIndex:index];
//    } @catch (NSException *exception) {
//        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
//    } @finally {
//        return object;
//    }
//}

- (void)wtv_NSArrayM_insertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self wtv_NSArrayM_insertObject:anObject atIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {

    }
}

- (void)wtv_NSArrayM_removeObjectAtIndex:(NSUInteger)index {
    @try {
        [self wtv_NSArrayM_removeObjectAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {

    }
}

- (void)wtv_NSArrayM_removeObjectsInRange:(NSRange)range {
    @try {
        [self wtv_NSArrayM_removeObjectsInRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {

    }
}

- (void)wtv_NSArrayM_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    @try {
        [self wtv_NSArrayM_replaceObjectAtIndex:index withObject:anObject];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {

    }
}

#pragma mark - __NSCFArray
- (id)wtv_NSArrayM_objectAtIndexedSubscript:(NSUInteger)idx {
    id object = nil;
    @try {
        object = [self wtv_NSArrayM_objectAtIndexedSubscript:idx];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {
        return object;
    }
}

//- (id)wtv_NSCFArray_objectAtIndex:(NSUInteger)index {
//    id object = nil;
//    @try {
//        object = [self wtv_NSCFArray_objectAtIndex:index];
//    } @catch (NSException *exception) {
//        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
//    } @finally {
//        return object;
//    }
//}

- (void)wtv_NSCFArray_insertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self wtv_NSCFArray_insertObject:anObject atIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {

    }
}

- (void)wtv_NSCFArray_removeObjectAtIndex:(NSUInteger)index {
    @try {
        [self wtv_NSCFArray_removeObjectAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {

    }
}

- (void)wtv_NSCFArray_removeObjectsInRange:(NSRange)range {
    @try {
        [self wtv_NSCFArray_removeObjectsInRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {

    }
}

- (void)wtv_NSCFArray_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    @try {
        [self wtv_NSCFArray_replaceObjectAtIndex:index withObject:anObject];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableArray];
    } @finally {

    }
}

@end
