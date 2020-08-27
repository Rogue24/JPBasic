//
//  NSDictionary+WTVCrashProtector.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @class        NSDictionary_CrashProtector
 *  @brief
 *  @discussion
 */

/**

 目前可避免以下crash  NSDictionary和NSMutableDictionary 调用 objectForKey： key为nil不会崩溃

 1.+ (instancetype)dictionaryWithObjects:(const ObjectType _Nonnull [_Nullable])objects forKeys:(const KeyType <NSCopying> _Nonnull [_Nullable])keys count:(NSUInteger)cnt会调用2中的方法
 2.- (instancetype)initWithObjects:(const ObjectType _Nonnull [_Nullable])objects forKeys:(const KeyType _Nonnull [_Nullable])keys count:(NSUInteger)cnt;
 3. @{@"key1":@"value1",@"key2":@"value2"}也会调用2中的方法
 4. - (instancetype)initWithObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType <NSCopying>> *)keys;
 */

@interface NSDictionary (WTVCrashProtector)

@end
