//
//  WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTVCrashProtectorDefine.h"
#import <objc/runtime.h>

/*!
 *  @class        WTVCrashProtector
 *  @brief
 *  @discussion
 */
@interface WTVCrashProtector : NSObject

+ (void)openCrashProtectorWithIsDebug:(BOOL)isDebug
                           crashBlock:(WTVCrashProtectorBlock)block;

+ (void)openCrashProtectorWithIsDebug:(BOOL)isDebug
                                types:(WTVCrashProtectorType)types
                           crashBlock:(WTVCrashProtectorBlock)block;

/**
 自定义崩溃信息
 @param exception 异常信息
 @param crashType 崩溃类型
 */
+ (void)crashProtectorWithException:(NSException *)exception crashType:(WTVCrashProtectorType)crashType;

/**
 method swizzling 交互方法
 @param cls 类
 @param originalSelector 原始方法
 @param swizzlingSelector 替换方法
 */
+ (void)swizzlingForClass:(Class)cls originalSel:(SEL)originalSelector swizzlingSel:(SEL)swizzlingSelector;
@end
