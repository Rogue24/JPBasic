//
//  NSMutableOrderedSet+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSMutableOrderedSet_CrashProtector
 *  @brief
 *  @discussion
 */
/**
可避免以下crash:

1. - (void)addObject:(ObjectType)anObject
2. - (void)insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;
3. - (id)objectAtIndex:(NSUInteger)index( 包含   array[index]  形式  )
4. - (void)removeObjectAtIndex:(NSUInteger)index
5.- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(ObjectType)object
*/
@interface NSMutableOrderedSet (WTVCrashProtector)

@end
