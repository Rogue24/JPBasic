//
//  NSAttributedString+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSAttributedString_CrashProtector
 *  @brief
 *  @discussion
 */
/**
目前可避免以下方法crash:
 
 NSConcreteAttributedString:
 1.- (instancetype)initWithString:(NSString *)str;
 2.- (instancetype)initWithString:(NSString *)str attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;(最终调用方法1)
 3.- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr;(最终调用方法1)
*/
@interface NSAttributedString (WTVCrashProtector)

@end
