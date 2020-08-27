//
//  NSOrderedSet+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSOrderedSet_CrashProtector
 *  @brief
 *  @discussion
 */

/**
可避免以下crash:

1.- (instancetype)initWithObjects:(const ObjectType _Nonnull [_Nullable])objects count:(NSUInteger)cnt
2.- (ObjectType)objectAtIndex:(NSUInteger)idx

*/
@interface NSOrderedSet (WTVCrashProtector)

@end
