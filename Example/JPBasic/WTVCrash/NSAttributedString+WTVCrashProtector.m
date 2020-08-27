//
//  NSAttributedString+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSAttributedString+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSAttributedString (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class NSConcreteAttributedStringClass = NSClassFromString(@"NSConcreteAttributedString");

        [WTVCrashProtector swizzlingForClass:NSConcreteAttributedStringClass
                                 originalSel:@selector(initWithString:)
                                swizzlingSel:@selector(wtv_NSConcreteAttributedString_initWithString:)];

        [WTVCrashProtector swizzlingForClass:NSConcreteAttributedStringClass
                                 originalSel:@selector(initWithString:attributes:)
                                swizzlingSel:@selector(wtv_NSConcreteAttributedString_initWithString:attributes:)];

        [WTVCrashProtector swizzlingForClass:NSConcreteAttributedStringClass
                                 originalSel:@selector(initWithAttributedString:)
                                swizzlingSel:@selector(wtv_NSConcreteAttributedString_initWithAttributedString:)];
    });
}

#pragma mark - NSConcreteAttributedString
- (instancetype)wtv_NSConcreteAttributedString_initWithString:(NSString *)str {
    id instance = nil;
    @try {
        instance = [self wtv_NSConcreteAttributedString_initWithString:str];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSAttributedString];
    } @finally {
        return instance;
    }
}

- (instancetype)wtv_NSConcreteAttributedString_initWithString:(NSString *)str attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs {
    id instance = nil;
    @try {
        instance = [self wtv_NSConcreteAttributedString_initWithString:str attributes:attrs];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSAttributedString];
    } @finally {
        return instance;
    }
}

- (instancetype)wtv_NSConcreteAttributedString_initWithAttributedString:(NSAttributedString *)attrStr {
    id instance = nil;
    @try {
        instance = [self wtv_NSConcreteAttributedString_initWithAttributedString:attrStr];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSAttributedString];
    } @finally {
        return instance;
    }
}
@end
