//
//  NSString+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSString+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

/*
initWithString导致的crash
 如果是[NSString alloc] initWithString 类为NSPlaceholderString
 如果是[NSMutableString alloc] initWithString 类为NSPlaceholderMutableString

 __NSCFString
 非常量 或者 [NSMutableString stringWithFormat:@"fs"];
 [[NSMutableString alloc] initWithString:@"fs"];
 [NSString stringWithFormat:] 大于7字节

 __NSCFConstantString
 @"fdsfsds"
 [[NSString alloc] initWithString:@"fs"];

 NSTaggedPointerString [NSString stringWithFormat:@"fs"]形式创建 当字节小于7(包含7)时是NSTaggedPointerString 大于7字节时是__NSCFString
 @"123456"0xa003635343332316  当字节大于7填满时并不会立即变成__NSCFString，而是采用一种压缩算法，当压缩之后大于7字节时才会变成__NSCFString ( @"1234567"为 0xa373635343332317 没有压缩， @"12345678"为 0xa007a87dcaecc2a8 开始压缩了）//第一位为a代表是字符串  b为NSNumber,当为NSNumber时最后一位表示(long 3 float为4，Int为2，double为5）

 想更多了解可以参考以下链接
 https://www.jianshu.com/p/e354f9137ba8
 http://www.cocoachina.com/ios/20150918/13449.html

 */
@implementation NSString (WTVCrashProtector)

+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        Class NSPlaceholderStringClass = NSClassFromString(@"NSPlaceholderString");
        [WTVCrashProtector swizzlingForClass:NSPlaceholderStringClass
                                originalSel:@selector(initWithString:)
                               swizzlingSel:@selector(wtv_NSPlaceholderString_initWithString:)];

        Class NSCFConstantStringClass = NSClassFromString(@"__NSCFConstantString");
        [self changeMethods:NSCFConstantStringClass];

        Class NSTaggedPointerStringClass = NSClassFromString(@"NSTaggedPointerString");
        [self changeMethods:NSTaggedPointerStringClass];

    });
}

+ (void)changeMethods:(Class)dClass {
    //hasPrefix
    [WTVCrashProtector swizzlingForClass:dClass
                             originalSel:@selector(hasPrefix:)
                            swizzlingSel:@selector(wtv_NSString_hasPrefix:)];

    //hasSuffix
    [WTVCrashProtector swizzlingForClass:dClass
                             originalSel:@selector(hasSuffix:)
                            swizzlingSel:@selector(wtv_NSString_hasSuffix:)];

    //substringFromIndex
    [WTVCrashProtector swizzlingForClass:dClass
                             originalSel:@selector(substringFromIndex:)
                            swizzlingSel:@selector(wtv_NSString_substringFromIndex:)];

    //substringToIndex
    [WTVCrashProtector swizzlingForClass:dClass
                             originalSel:@selector(substringToIndex:)
                            swizzlingSel:@selector(wtv_NSString_substringToIndex:)];

    //substringWithRange
    [WTVCrashProtector swizzlingForClass:dClass
                             originalSel:@selector(substringWithRange:)
                            swizzlingSel:@selector(wtv_NSString_substringWithRange:)];

    //characterAtIndex
    [WTVCrashProtector swizzlingForClass:dClass
                             originalSel:@selector(characterAtIndex:)
                            swizzlingSel:@selector(wtv_NSString_characterAtIndex:)];

    //stringByReplacingOccurrencesOfString:withString:options:range:
    [WTVCrashProtector swizzlingForClass:dClass
                             originalSel:@selector(stringByReplacingOccurrencesOfString:withString:options:range:)
                            swizzlingSel:@selector(wtv_NSString_stringByReplacingOccurrencesOfString:withString:options:range:)];

    //stringByReplacingCharactersInRange:withString:
    [WTVCrashProtector swizzlingForClass:dClass
                             originalSel:@selector(stringByReplacingCharactersInRange:withString:)
                            swizzlingSel:@selector(wtv_NSString_stringByReplacingCharactersInRange:withString:)];
}

#pragma mark - NSPlaceholderString
- (instancetype)wtv_NSPlaceholderString_initWithString:(NSString *)aString {
    id instance = nil;
    @try {
        instance = [self wtv_NSPlaceholderString_initWithString:aString];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];
    } @finally {
        return instance;
    }
}

#pragma mark - __NSCFConstantString, NSTaggedPointerString
- (BOOL)wtv_NSString_hasPrefix:(NSString *)str {
    BOOL hasPrefix = NO;
    @try {
        hasPrefix = [self wtv_NSString_hasPrefix:str];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];
    } @finally {
        return hasPrefix;
    }
}

- (BOOL)wtv_NSString_hasSuffix:(NSString *)str {
    BOOL hasSuffix = NO;
    @try {
        hasSuffix = [self wtv_NSString_hasSuffix:str];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];
    } @finally {
        return hasSuffix;
    }
}

- (NSString *)wtv_NSString_substringFromIndex:(NSUInteger)from {
    NSString *subString = nil;
    @try {
        subString = [self wtv_NSString_substringFromIndex:from];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];
    } @finally {
        return subString;
    }
}

- (NSString *)wtv_NSString_substringToIndex:(NSUInteger)index {
    NSString *subString = nil;
    @try {
        subString = [self wtv_NSString_substringToIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];
    } @finally {
        return subString;
    }
}

- (NSString *)wtv_NSString_substringWithRange:(NSRange)range {
    NSString *subString = nil;
    @try {
        subString = [self wtv_NSString_substringWithRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];
    } @finally {
        return subString;
    }
}

- (unichar)wtv_NSString_characterAtIndex:(NSUInteger)index {
    unichar characteristic;
    @try {
        characteristic = [self wtv_NSString_characterAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];
    } @finally {
        return characteristic;
    }
}


- (NSString *)wtv_NSString_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    NSString *newStr = nil;
    @try {
        newStr = [self wtv_NSString_stringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    } @catch (NSException *exception) {
       [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];

    } @finally {
        return newStr;
    }
}


- (NSString *)wtv_NSString_stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    NSString *newStr = nil;
    @try {
        newStr = [self wtv_NSString_stringByReplacingCharactersInRange:range withString:replacement];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSString];
//        newStr = nil;
    } @finally {
        return newStr;
    }
}

@end
