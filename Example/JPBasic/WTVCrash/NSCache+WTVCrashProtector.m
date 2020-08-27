//
//  NSCache+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSCache+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSCache (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"NSCache");
        
        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(setObject:forKey:cost:)
                                swizzlingSel:@selector(wtv_NSCache_setObject:forKey:cost:)];
    });
}

#pragma mark - NSCache
- (void)wtv_NSCache_setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
    @try {
        [self wtv_NSCache_setObject:obj forKey:key cost:g];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSCache];
    } @finally {
        
    }
}
@end
