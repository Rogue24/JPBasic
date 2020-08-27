//
//  NSCache+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSCache_CrashProtector
 *  @brief
 *  @discussion
 */

/**
可避免以下crash

1.- (void)setObject:(ObjectType)obj forKey:(KeyType)key; // 0 cost
2.- (void)setObject:(ObjectType)obj forKey:(KeyType)key cost:(NSUInteger)g;
*/
@interface NSCache (WTVCrashProtector)

@end
