//
//  NSObject+JPExtension.h
//  WoTV
//
//  Created by 周健平 on 2018/7/23.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JPExtension)
+ (NSString *)jp_className;
- (NSString *)jp_className;

+ (BOOL)jp_isMetaClass;
+ (Class)jp_metaClass;
- (Class)jp_metaClass;

+ (void)jp_lookIvarList;
- (void)jp_lookIvarList;

+ (void)jp_lookPropertyList;
- (void)jp_lookPropertyList;

+ (void)jp_lookMethodList;
- (void)jp_lookMethodList;

+ (NSInteger)jp_instanceSize;
- (NSInteger)jp_instanceSize;

- (NSInteger)jp_mallocSize;
@end
