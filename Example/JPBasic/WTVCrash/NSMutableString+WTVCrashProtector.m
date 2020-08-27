//
//  NSMutableString+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSMutableString+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSMutableString (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        Class NSPlaceholderMutableStringClass = NSClassFromString(@"NSPlaceholderMutableString");
        // initWithString
        [WTVCrashProtector swizzlingForClass:NSPlaceholderMutableStringClass
                                 originalSel:@selector(initWithString:)
                                swizzlingSel:@selector(wtv_NSPlaceholderMutableString_initWithString:)];

        Class NSCFStringClass = NSClassFromString(@"__NSCFString");
        // hasPrefix
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(hasPrefix:)
                                swizzlingSel:@selector(wtv_NSCFString_hasPrefix:)];

        // hasSuffix
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(hasSuffix:)
                                swizzlingSel:@selector(wtv_NSCFString_hasSuffix:)];

        // substringFromIndex
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(substringFromIndex:)
                                swizzlingSel:@selector(wtv_NSCFString_substringFromIndex:)];

        // substringToIndex
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(substringToIndex:)
                                swizzlingSel:@selector(wtv_NSCFString_substringToIndex:)];

        //substringWithRange
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(substringWithRange:)
                                swizzlingSel:@selector(wtv_NSCFString_substringWithRange:)];

        //characterAtIndex
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(characterAtIndex:)
                                swizzlingSel:@selector(wtv_NSCFString_characterAtIndex:)];

        //stringByReplacingOccurrencesOfString:withString:options:range:
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(stringByReplacingOccurrencesOfString:withString:options:range:)
                                swizzlingSel:@selector(wtv_NSCFString_stringByReplacingOccurrencesOfString:withString:options:range:)];

        //stringByReplacingCharactersInRange:withString:
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(stringByReplacingCharactersInRange:withString:)
                                swizzlingSel:@selector(wtv_NSCFString_stringByReplacingCharactersInRange:withString:)];

        //replaceCharactersInRange:withString:
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(replaceCharactersInRange:withString:)
                                swizzlingSel:@selector(wtv_NSCFString_replaceCharactersInRange:withString:)];

        //replaceOccurrencesOfString:withString:options:range:
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(replaceOccurrencesOfString:withString:options:range:)
                                swizzlingSel:@selector(wtv_NSCFString_replaceOccurrencesOfString:withString:options:range:)];

        //insertString:atIndex:
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(insertString:atIndex:)
                                swizzlingSel:@selector(wtv_NSCFString_insertString:atIndex:)];

        //deleteCharactersInRange:
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(deleteCharactersInRange:)
                                swizzlingSel:@selector(wtv_NSCFString_deleteCharactersInRange:)];

        //appendString:
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(appendString:)
                                swizzlingSel:@selector(wtv_NSCFString_appendString:)];

        //setString:
        [WTVCrashProtector swizzlingForClass:NSCFStringClass
                                 originalSel:@selector(setString:)
                                swizzlingSel:@selector(wtv_NSCFString_setString:)];
    });
}

#pragma mark - NSPlaceholderMutableString
- (instancetype)wtv_NSPlaceholderMutableString_initWithString:(NSString *)aString {
    id instance = nil;
    @try {
        instance = [self wtv_NSPlaceholderMutableString_initWithString:aString];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return instance;
    }
}

#pragma mark - __NSCFString
- (BOOL)wtv_NSCFString_hasPrefix:(NSString *)str {
    BOOL hasPrefix = NO;
    @try {
        hasPrefix = [self wtv_NSCFString_hasPrefix:str];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return hasPrefix;
    }
}

- (BOOL)wtv_NSCFString_hasSuffix:(NSString *)str {
    BOOL hasSuffix = NO;
    @try {
        hasSuffix = [self wtv_NSCFString_hasSuffix:str];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return hasSuffix;
    }
}

- (NSString *)wtv_NSCFString_substringFromIndex:(NSUInteger)from {
    NSString *subString = nil;
    @try {
        subString = [self wtv_NSCFString_substringFromIndex:from];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return subString;
    }
}

- (NSString *)wtv_NSCFString_substringToIndex:(NSUInteger)index {
    NSString *subString = nil;
    @try {
        subString = [self wtv_NSCFString_substringToIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return subString;
    }
}

- (NSString *)wtv_NSCFString_substringWithRange:(NSRange)range {
    NSString *subString = nil;
    @try {
        subString = [self wtv_NSCFString_substringWithRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return subString;
    }
}

- (unichar)wtv_NSCFString_characterAtIndex:(NSUInteger)index {
    unichar characteristic;
    @try {
        characteristic = [self wtv_NSCFString_characterAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return characteristic;
    }
}

- (NSString *)wtv_NSCFString_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    NSString *newStr = nil;
    @try {
        newStr = [self wtv_NSCFString_stringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    } @catch (NSException *exception) {
       [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return newStr;
    }
}

- (NSString *)wtv_NSCFString_stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    NSString *newStr = nil;
    @try {
        newStr = [self wtv_NSCFString_stringByReplacingCharactersInRange:range withString:replacement];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return newStr;
    }
}

- (void)wtv_NSCFString_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    @try {
        [self wtv_NSCFString_replaceCharactersInRange:range withString:aString];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {

    }
}

- (NSUInteger)wtv_NSCFString_replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    NSUInteger number = 0;
    @try {
        number = [self wtv_NSCFString_replaceOccurrencesOfString:target withString:replacement options:options range:searchRange];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {
        return number;
    }
}

- (void)wtv_NSCFString_insertString:(NSString *)aString atIndex:(NSUInteger)loc {
    @try {
        [self wtv_NSCFString_insertString:aString atIndex:loc];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {

    }
}

- (void)wtv_NSCFString_deleteCharactersInRange:(NSRange)range {
    @try {
        [self wtv_NSCFString_deleteCharactersInRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {

    }
}

- (void)wtv_NSCFString_appendString:(NSString *)aString {
    @try {
        [self wtv_NSCFString_appendString:aString];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {

    }
}

- (void)wtv_NSCFString_setString:(NSString *)aString {
    @try {
        [self wtv_NSCFString_setString:aString];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableString];
    } @finally {

    }
}
@end
