//
//  NSString+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSString_CrashProtector
 *  @brief
 *  @discussion
 */
/**
 可以避免以下crash:
 
 NSPlaceholderString:
 1.- (instancetype)initWithString:(NSString *)aString;

__NSCFConstantString和NSTaggedPointerString:
 1.- (BOOL)hasPrefix:(NSString *)str;
 2.- (BOOL)hasSuffix:(NSString *)str;
 3.- (NSString *)substringFromIndex:(NSUInteger)from;
 4.- (NSString *)substringToIndex:(NSUInteger)to;
 5.- (NSString *)substringWithRange:(NSRange)range;
 6.- (unichar)characterAtIndex:(NSUInteger)index;
 7.- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement(实际上调用的是8方法)
 8.- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;
 9.- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement;
 */
@interface NSString (WTVCrashProtector)

@end
