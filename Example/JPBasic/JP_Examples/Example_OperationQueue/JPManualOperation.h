//
//  JPManualOperation.h
//  JPBasic_Example
//
//  Created by aa on 2024/11/17.
//  Copyright © 2024 zhoujianping24@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPManualOperation : NSOperation
@property (nonatomic, copy, nullable) void (^executionBlock)(void (^completion)(void));
@end

NS_ASSUME_NONNULL_END
