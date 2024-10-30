//
//  JPBlock.h
//  JPBasic_Example
//
//  Created by 周健平 on 2021/2/17.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPBlock : NSObject
@property (nonatomic, copy) void (^myBlock)(JPBlock *bbb);
@end

NS_ASSUME_NONNULL_END
