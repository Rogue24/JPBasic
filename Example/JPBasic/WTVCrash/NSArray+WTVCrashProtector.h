//
//  NSArray+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSArray_CrashProtector
 *  @brief
 *  @discussion
 */

/**
   可避免以下crash
   1. - (id)objectAtIndex:(NSUInteger)index( 包含   array[index]  形式  )
*/
@interface NSArray (WTVCrashProtector)
@end
