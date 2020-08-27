//
//  NSMutableData+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSMutableData+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSMutableData (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"NSConcreteMutableData");

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(subdataWithRange:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableData_subdataWithRange:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(rangeOfData:options:range:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableData_rangeOfData:options:range:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(replaceBytesInRange:withBytes:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableData_replaceBytesInRange:withBytes:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(resetBytesInRange:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableData_resetBytesInRange:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(replaceBytesInRange:withBytes:length:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableData_replaceBytesInRange:withBytes:length:)];
    });
}

#pragma mark - NSConcreteMutableData
- (NSData *)wtv_NSConcreteMutableData_subdataWithRange:(NSRange)range {
    NSData *data = nil;
    @try {
        data = [self wtv_NSConcreteMutableData_subdataWithRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableData];
    } @finally {
        return data;
    }
}

- (NSRange)wtv_NSConcreteMutableData_rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange {
    NSRange range;
    @try {
        range = [self wtv_NSConcreteMutableData_rangeOfData:dataToFind options:mask range:searchRange];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableData];
    } @finally {
        return range;
    }
}

- (void)wtv_NSConcreteMutableData_replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes {
    @try {
        [self wtv_NSConcreteMutableData_replaceBytesInRange:range withBytes:bytes];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableData];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableData_resetBytesInRange:(NSRange)range {
    @try {
        [self wtv_NSConcreteMutableData_resetBytesInRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableData];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableData_replaceBytesInRange:(NSRange)range withBytes:(nullable const void *)replacementBytes length:(NSUInteger)replacementLength {
    @try {
        [self wtv_NSConcreteMutableData_replaceBytesInRange:range withBytes:replacementBytes length:replacementLength];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableData];
    } @finally {

    }
}
@end
