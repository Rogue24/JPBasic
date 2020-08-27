//
//  NSSet+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSSet_CrashProtector
 *  @brief
 *  @discussion
 */

/**
可避免以下crash:

1.+ (instancetype)setWithObject:(ObjectType)object
2.+ (instancetype)setWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION
3.- (instancetype)initWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION
*/
@interface NSSet (WTVCrashProtector)

@end
