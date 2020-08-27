//
//  NSMutableDictionary+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSMutableDictionary_CrashProtector
 *  @brief
 *  @discussion
 */

/**
目前可避免以下crash:
 
1.- (void)setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)aKey(iOS11之前调用下标的方法会触发该方法,例如dict[@"key"] = @"value")
2.- (void)setObject:(nullable ObjectType)obj forKeyedSubscript:(KeyType <NSCopying>)key(iOS11之后（含11)调用下标的方法会触发该方法,例如dict[@"key"] = @"value")
3.- (void)removeObjectForKey:(KeyType)aKey
*/
@interface NSMutableDictionary (WTVCrashProtector)

@end
