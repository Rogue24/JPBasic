//
//  NSMutableString+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSMutableString_CrashProtector
 *  @brief
 *  @discussion
 */
/**
 可以避免以下crash:
 
 NSPlaceholderMutableString:
 1.- (instancetype)initWithString:(NSString *)aString;

__NSCFString:
 1.- (BOOL)hasPrefix:(NSString *)str;
 2.- (BOOL)hasSuffix:(NSString *)str;
 3.- (NSString *)substringFromIndex:(NSUInteger)from;
 4.- (NSString *)substringToIndex:(NSUInteger)to;
 5.- (NSString *)substringWithRange:(NSRange)range;
 6.- (unichar)characterAtIndex:(NSUInteger)index;
 7.- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;
 8.- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement;

 9.- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString;
 10,- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
 11.- (void)insertString:(NSString *)aString atIndex:(NSUInteger)loc;
 12.- (void)deleteCharactersInRange:(NSRange)range;
 13.- (void)appendString:(NSString *)aString;
 14.- (void)setString:(NSString *)aString;
 */

@interface NSMutableString (WTVCrashProtector)

@end
