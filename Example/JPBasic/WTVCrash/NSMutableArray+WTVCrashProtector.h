//
//  NSMutableArray+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSMutableArray_CrashProtector
 *  @brief
 *  @discussion
 */

/**
   可避免以下crash
   1. - (void)addObject:(ObjectType)anObject(实际调用2的方法)
   2. - (void)insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;
   3. - (id)objectAtIndex:(NSUInteger)index( 包含   array[index]  形式  )(此方法Crash防护在NSMutableArray+MRCCrashProtector文件下)
   4. - (void)removeObjectAtIndex:(NSUInteger)index
   5. - (void)replaceObjectAtIndex:(NSUInteger)index
   6. - (void)removeObjectsInRange:(NSRange)range
   7. - (instancetype)initWithObjects:(const ObjectType _Nonnull [_Nullable])objects count:(NSUInteger)cnt
*/
@interface NSMutableArray (WTVCrashProtector)

@end
