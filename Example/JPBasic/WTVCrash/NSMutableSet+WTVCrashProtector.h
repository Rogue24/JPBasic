//
//  NSMutableSet+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSMutableSet_CrashProtector
 *  @brief
 *  @discussion
 */
/**
可避免以下crash:
 
1.+ (instancetype)setWithObject:(ObjectType)object
2.- (instancetype)initWithObjects:(ObjectType)firstObj
3.- (void)setWithObjects:(ObjectType)firstObj
4.- (void)addObject:(ObjectType)object;
5.- (void)removeObject:(ObjectType)object;
*/
@interface NSMutableSet (WTVCrashProtector)

@end
