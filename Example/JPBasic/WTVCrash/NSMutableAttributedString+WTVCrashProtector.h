//
//  NSMutableAttributedString+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSMutableAttributedString_CrashProtector
 *  @brief
 *  @discussion
 */

/**
目前可避免以下方法crash:

NSConcreteMutableAttributedString:
1.- (instancetype)initWithString:(NSString *)str;
2.- (instancetype)initWithString:(NSString *)str attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;
3.- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr;

4. - (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
5.- (void)setAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs range:(NSRange)range;

6.- (void)addAttribute:(NSAttributedStringKey)name value:(id)value range:(NSRange)range;
7.- (void)addAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs range:(NSRange)range;
8.- (void)removeAttribute:(NSAttributedStringKey)name range:(NSRange)range;

9.- (void)replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString;
10.- (void)insertAttributedString:(NSAttributedString *)attrString atIndex:(NSUInteger)loc;(最终出发方法9)
11.- (void)appendAttributedString:(NSAttributedString *)attrString;(后续出发方法9,最终出发方法4)
12.- (void)deleteCharactersInRange:(NSRange)range;(最终出发方法9)
13.- (void)setAttributedString:(NSAttributedString *)attrString;(最终出发方法9)
*/
@interface NSMutableAttributedString (WTVCrashProtector)

@end
