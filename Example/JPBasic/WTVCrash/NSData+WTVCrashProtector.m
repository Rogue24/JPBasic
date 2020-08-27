//
//  NSData+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSData+WTVCrashProtector.h"
#import "WTVCrashProtector.h"
/*
1. _NSZeroData
   [NSData data]空data

2.NSConcreteMutableData
   [NSMutableData data];

3.NSConcreteData
   [NSJSONSerialization dataWithJSONObject:[NSMutableDictionary dictionary] options:0 error:nil]

4._NSInlineData
     [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"https://www.baidu.com/"]]

5.__NSCFData
*/

@implementation NSData (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class NSZeroDataClass = NSClassFromString(@"_NSZeroData");

        [WTVCrashProtector swizzlingForClass:NSZeroDataClass
                                 originalSel:@selector(subdataWithRange:)
                                swizzlingSel:@selector(wtv_NSZeroData_subdataWithRange:)];

        [WTVCrashProtector swizzlingForClass:NSZeroDataClass
                                 originalSel:@selector(rangeOfData:options:range:)
                                swizzlingSel:@selector(wtv_NSZeroData_rangeOfData:options:range:)];

        Class NSConcreteDataClass = NSClassFromString(@"NSConcreteData");

        [WTVCrashProtector swizzlingForClass:NSConcreteDataClass
                                 originalSel:@selector(subdataWithRange:)
                               swizzlingSel:@selector(wtv_NSConcreteData_subdataWithRange:)];

        [WTVCrashProtector swizzlingForClass:NSConcreteDataClass
                                 originalSel:@selector(rangeOfData:options:range:)
                                swizzlingSel:@selector(wtv_NSConcreteData_rangeOfData:options:range:)];

        Class NSInlineDataClass = NSClassFromString(@"_NSInlineData");

        [WTVCrashProtector swizzlingForClass:NSInlineDataClass
                                 originalSel:@selector(subdataWithRange:)
                                swizzlingSel:@selector(wtv_NSInlineData_subdataWithRange:)];

        [WTVCrashProtector swizzlingForClass:NSInlineDataClass
                                 originalSel:@selector(rangeOfData:options:range:)
                                swizzlingSel:@selector(wtv_NSInlineData_rangeOfData:options:range:)];

        Class NSCFDataClass = NSClassFromString(@"__NSCFData");

        [WTVCrashProtector swizzlingForClass:NSCFDataClass
                                 originalSel:@selector(subdataWithRange:)
                                swizzlingSel:@selector(wtv_NSCFDataClass_subdataWithRange:)];

        [WTVCrashProtector swizzlingForClass:NSCFDataClass
                                 originalSel:@selector(rangeOfData:options:range:)
                                swizzlingSel:@selector(wtv_NSCFDataClass_rangeOfData:options:range:)];
    });
}

#pragma mark - _NSZeroData
- (NSData *)wtv_NSZeroData_subdataWithRange:(NSRange)range {
    NSData *data = nil;
    @try {
        data = [self wtv_NSZeroData_subdataWithRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSData];
    } @finally {
        return data;
    }
}

- (NSRange)wtv_NSZeroData_rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange {
    NSRange range;
    @try {
        range = [self wtv_NSZeroData_rangeOfData:dataToFind options:mask range:searchRange];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSData];
    } @finally {
        return range;
    }
}

#pragma mark - NSConcreteData
- (NSData *)wtv_NSConcreteData_subdataWithRange:(NSRange)range {
    NSData *data = nil;
    @try {
        data = [self wtv_NSConcreteData_subdataWithRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSData];
    } @finally {
        return data;
    }
}

- (NSRange)wtv_NSConcreteData_rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange {
    NSRange range;
    @try {
        range = [self wtv_NSConcreteData_rangeOfData:dataToFind options:mask range:searchRange];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSData];
    } @finally {
        return range;
    }
}

#pragma mark - _NSInlineData
- (NSData *)wtv_NSInlineData_subdataWithRange:(NSRange)range {
    NSData *data = nil;
    @try {
        data = [self wtv_NSInlineData_subdataWithRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSData];
    } @finally {
        return data;
    }
}

- (NSRange)wtv_NSInlineData_rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange {
    NSRange range;
    @try {
        range = [self wtv_NSInlineData_rangeOfData:dataToFind options:mask range:searchRange];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSData];
    } @finally {
        return range;
    }
}

#pragma mark - __NSCFData
- (NSData *)wtv_NSCFDataClass_subdataWithRange:(NSRange)range {
    NSData *data = nil;
    @try {
        data = [self wtv_NSCFDataClass_subdataWithRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSData];
    } @finally {
        return data;
    }
}

- (NSRange)wtv_NSCFDataClass_rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange {
    NSRange range;
    @try {
        range = [self wtv_NSCFDataClass_rangeOfData:dataToFind options:mask range:searchRange];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSData];
    } @finally {
        return range;
    }
}
@end
