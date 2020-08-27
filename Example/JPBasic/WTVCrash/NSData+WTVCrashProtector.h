//
//  NSData+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSData_CrashProtector
 *  @brief
 *  @discussion
 */

/*
可防止以下crash:
 
1.- (NSData *)subdataWithRange:(NSRange)range;
2.- (NSRange)rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange

*/
@interface NSData (WTVCrashProtector)

@end
