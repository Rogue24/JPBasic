//
//  NSMutableAttributedString+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSMutableAttributedString+WTVCrashProtector.h"
#import "WTVCrashProtector.h"
@implementation NSMutableAttributedString (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dClass = NSClassFromString(@"NSConcreteMutableAttributedString");
        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(initWithString:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_initWithString:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(initWithString:attributes:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_initWithString:attributes:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(initWithAttributedString:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_initWithAttributedString:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(replaceCharactersInRange:withString:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_replaceCharactersInRange:withString:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(setAttributes:range:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_setAttributes:range:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(addAttribute:value:range:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_addAttribute:value:range:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(addAttributes:range:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_addAttributes:range:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(removeAttribute:range:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_removeAttribute:range:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(replaceCharactersInRange:withAttributedString:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_replaceCharactersInRange:withAttributedString:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(insertAttributedString:atIndex:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_insertAttributedString:atIndex:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(appendAttributedString:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_appendAttributedString:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(deleteCharactersInRange:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_deleteCharactersInRange:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(setAttributedString:)
                                swizzlingSel:@selector(wtv_NSConcreteMutableAttributedString_setAttributedString:)];

    });
}

#pragma mark - NSConcreteMutableAttributedString
- (instancetype)wtv_NSConcreteMutableAttributedString_initWithString:(NSString *)str {
    id instance = nil;
    @try {
        instance = [self wtv_NSConcreteMutableAttributedString_initWithString:str];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {
        return instance;
    }
}

- (instancetype)wtv_NSConcreteMutableAttributedString_initWithString:(NSString *)str attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs {
    id instance = nil;
    @try {
        instance = [self wtv_NSConcreteMutableAttributedString_initWithString:str attributes:attrs];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {
        return instance;
    }
}

- (instancetype)wtv_NSConcreteMutableAttributedString_initWithAttributedString:(NSAttributedString *)attrStr {
    id instance = nil;
    @try {
        instance = [self wtv_NSConcreteMutableAttributedString_initWithAttributedString:attrStr];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {
        return instance;
    }
}

- (void)wtv_NSConcreteMutableAttributedString_replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    @try {
        [self wtv_NSConcreteMutableAttributedString_replaceCharactersInRange:range withString:str];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_setAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs range:(NSRange)range {
    @try {
        [self wtv_NSConcreteMutableAttributedString_setAttributes:attrs range:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_addAttribute:(NSAttributedStringKey)name value:(id)value range:(NSRange)range {
    @try {
        [self wtv_NSConcreteMutableAttributedString_addAttribute:name value:value range:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_addAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs range:(NSRange)range {
    @try {
        [self wtv_NSConcreteMutableAttributedString_addAttributes:attrs range:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_removeAttribute:(NSAttributedStringKey)name range:(NSRange)range {
    @try {
        [self wtv_NSConcreteMutableAttributedString_removeAttribute:name range:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString {
    @try {
        [self wtv_NSConcreteMutableAttributedString_replaceCharactersInRange:range withAttributedString:attrString];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_insertAttributedString:(NSAttributedString *)attrString atIndex:(NSUInteger)loc {
    @try {
        [self wtv_NSConcreteMutableAttributedString_insertAttributedString:attrString atIndex:loc];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_appendAttributedString:(NSAttributedString *)attrString {
    @try {
        [self wtv_NSConcreteMutableAttributedString_appendAttributedString:attrString];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_deleteCharactersInRange:(NSRange)range {
    @try {
        [self wtv_NSConcreteMutableAttributedString_deleteCharactersInRange:range];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}

- (void)wtv_NSConcreteMutableAttributedString_setAttributedString:(NSAttributedString *)attrString {
    @try {
        [self wtv_NSConcreteMutableAttributedString_setAttributedString:attrString];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSMutableAttributedString];
    } @finally {

    }
}
@end
