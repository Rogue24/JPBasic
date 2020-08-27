//
//  NSDictionary+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

// 类继承关系
// __NSDictionaryI              继承于 NSDictionary
// __NSSingleEntryDictionaryI   继承于 NSDictionary
// __NSDictionary0              继承于 NSDictionary
// __NSFrozenDictionaryM        继承于 NSDictionary
// __NSPlaceholderDictionary    继承于 NSMutableDictionary
// __NSDictionaryM              继承于 NSMutableDictionary
// __NSCFDictionary             继承于 NSMutableDictionary
// NSMutableDictionary          继承于 NSDictionary
// NSDictionary                 继承于 NSObject


/*
 大概和NSArray类似  也是iOS8之前都是__NSDictionaryI，如果是json转过来的对象为__NSCFDictionary，其他的参考NSArray

 __NSSingleEntryDictionaryI
 @{@"key":@"value"} 此种形式创建而且仅一个可以为__NSSingleEntryDictionaryI
 __NSDictionaryM
 NSMutableDictionary创建都为__NSDictionaryM
 __NSDictionary0
 除__NSDictionaryM外 不管什么方式创建0个key都为__NSDictionary0
 __NSDictionaryI
 @{@"key":@"value",@"key2",@"value2"}此种方式创建多于1个key，或者initWith创建都是__NSDictionaryI
 */

/*
 特殊类型
1. __NSCFDictionary 以下情况生成
 沙盒即使存储的是可变的得到的也是不可变的，当然还有其他情况得到这种类型的字典
 [[NSUserDefaults standardUserDefaults] setObject:[NSMutableDictionary dictionary] forKey:@"name"];
 NSMutableDictionary *dict=[[NSUserDefaults standardUserDefaults] objectForKey:@"name"];

2.__NSFrozenDictionaryM  以下情况生成

 NSMutableDictionary *dict=[[NSMutableDictionary dictionary] copy];
 [dict setObject:@"fsd" forKey:value];

*/

#import "NSDictionary+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSDictionary (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dClass = NSClassFromString(@"__NSPlaceholderDictionary");
        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(initWithObjects:forKeys:count:)
                                swizzlingSel:@selector(wtv_NSPlaceholderDictionary_initWithObjects:forKeys:count:)];

        [WTVCrashProtector swizzlingForClass:dClass
                                 originalSel:@selector(initWithObjects:forKeys:)
                                swizzlingSel:@selector(wtv_NSPlaceholderDictionary_initWithObjects:forKeys:)];
    });
}

#pragma mark - __NSPlaceholderDictionary
- (instancetype)wtv_NSPlaceholderDictionary_initWithObjects:(id _Nonnull const [])objects forKeys:(id<NSCopying> _Nonnull const [])keys count:(NSUInteger)cnt {
    id instance = nil;
    @try {
        instance = [self wtv_NSPlaceholderDictionary_initWithObjects:objects forKeys:keys count:cnt];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSDictionary];
        NSUInteger index = 0;
        id newObjects[cnt];
        id newKeys[cnt];

        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newKeys[index] = keys[i];
                index++;
            }
        }
        instance = [self wtv_NSPlaceholderDictionary_initWithObjects:newObjects forKeys:newKeys count:index];
    } @finally {
        return instance;
    }
}

- (instancetype)wtv_NSPlaceholderDictionary_initWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys {
    id instance = nil;
    @try {
        instance = [self wtv_NSPlaceholderDictionary_initWithObjects:objects forKeys:keys];
    } @catch (NSException *exception) {
         [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSDictionary];

        NSUInteger count = MIN(objects.count, keys.count);
        NSMutableArray *newObjects = [NSMutableArray array];
        NSMutableArray *newKeys = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            if (objects[i] && keys[i]) {
                [newObjects addObject:objects[i]];
                [newKeys addObject:keys[i]];
            }
        }
        instance = [self wtv_NSPlaceholderDictionary_initWithObjects:newObjects forKeys:newKeys];
    } @finally {
        return instance;
    }
}
@end
