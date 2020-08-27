//
//  NSMutableDictionary+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSMutableDictionary+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSMutableDictionary (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class NSDictionaryMClass = NSClassFromString(@"__NSDictionaryM");
        [WTVCrashProtector swizzlingForClass:NSDictionaryMClass
                                 originalSel:@selector(setObject:forKeyedSubscript:)
                                swizzlingSel:@selector(wtv_NSDictionaryM_setObject:forKeyedSubscript:)];

        [WTVCrashProtector swizzlingForClass:NSDictionaryMClass
                                 originalSel:@selector(setObject:forKey:)
                                swizzlingSel:@selector(wtv_NSDictionaryM_setObject:forKey:)];

        [WTVCrashProtector swizzlingForClass:NSDictionaryMClass
                                 originalSel:@selector(removeObjectForKey:)
                                swizzlingSel:@selector(wtv_NSDictionaryM_removeObjectForKey:)];

        Class NSCFDictionaryClass = NSClassFromString(@"__NSCFDictionary");
        [WTVCrashProtector swizzlingForClass:NSCFDictionaryClass
                                 originalSel:@selector(setObject:forKey:)
                                swizzlingSel:@selector(wtv_NSCFDictionary_setObject:forKey:)];

        [WTVCrashProtector swizzlingForClass:NSCFDictionaryClass
                                 originalSel:@selector(removeObjectForKey:)
                                swizzlingSel:@selector(wtv_NSCFDictionary_removeObjectForKey:)];
    });
}

#pragma mark - __NSDictionaryM
- (void)wtv_NSDictionaryM_setObject:(nullable id)obj forKeyedSubscript:(id <NSCopying>)key {
    @try {
       [self wtv_NSDictionaryM_setObject:obj forKeyedSubscript:key];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableDictionary];
    } @finally {

    }
}

- (void)wtv_NSDictionaryM_setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    @try {
        [self wtv_NSDictionaryM_setObject:anObject forKey:aKey];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableDictionary];
    } @finally {

    }
}

- (void)wtv_NSDictionaryM_removeObjectForKey:(id)aKey {
    @try {
        [self wtv_NSDictionaryM_removeObjectForKey:aKey];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableDictionary];
    } @finally {

    }
}

#pragma mark - __NSCFDictionary
- (void)wtv_NSCFDictionary_setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    @try {
        [self wtv_NSCFDictionary_setObject:anObject forKey:aKey];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableDictionary];
    } @finally {

    }
}

- (void)wtv_NSCFDictionary_removeObjectForKey:(id)aKey {
    @try {
        [self wtv_NSCFDictionary_removeObjectForKey:aKey];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableDictionary];
    } @finally {

    }
}
@end
