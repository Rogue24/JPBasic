//
//  NSArray+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

// 类继承关系
// __NSArrayI                 继承于 NSArray
// __NSSingleObjectArrayI     继承于 NSArray
// __NSArray0                 继承于 NSArray
// __NSFrozenArrayM           继承于 NSArray
// __NSPlaceholderArray       继承于 NSMutableArray
// __NSArrayM                 继承于 NSMutableArray
// __NSCFArray                继承于 NSMutableArray
// NSMutableArray             继承于 NSArray
// NSArray                    继承于 NSObject

// < = iOS 8:下都是__NSArrayI 如果是通过json转成的id 为__NSCFArray
//iOS9 @[] 是__NSArray0  @[@"fd"]是__NSArrayI
//iOS10以后(含10): 分 __NSArrayI、  __NSArray0、__NSSingleObjectArrayI


//__NSArrayM   NSMutableArray创建的都为__NSArrayM
//__NSArray0   除__NSArrayM 0个元素都为__NSArray0
// __NSSingleObjectArrayI @[@"fds"]只有此形式创建而且仅一个元素为__NSSingleObjectArrayI
//__NSArrayI   @[@"fds",@"fsd"]方式创建多于1个元素 或者 arrayWith创建都是__NSArrayI


//__NSCFArray
//arr@[11]
// >=11 调用 [__NSCFArray objectAtIndexedSubscript:]
// < 11  调用 [__NSCFArray objectAtIndex:]

//__NSArrayI
//arr@[11]
// >=11  调用 [__NSArrayI objectAtIndexedSubscript:]
// < 11  调用 [__NSArrayI objectAtIndex:]

//__NSArray0
//arr@[11]   不区分系统调用的是  [__NSArray0 objectAtIndex:]

//__NSSingleObjectArrayI
//arr@[11] 不区分系统 调用的是  [__NSSingleObjectArrayI objectAtIndex:]

//不可变数组
// <  iOS11： arr@[11]  调用的是[__NSArrayI objectAtIndex:]
// >= iOS11： arr@[11]  调用的是[__NSArrayI objectAtIndexedSubscript:]
//  任意系统   [arr objectAtIndex:111]  调用的都是[__NSArrayM objectAtIndex:]

//可变数组
// <  iOS11： arr@[11]  调用的是[__NSArrayM objectAtIndex:]
// >= iOS11： arr@[11]  调用的是[__NSArrayM objectAtIndexedSubscript]
//  任意系统   [arr objectAtIndex:111]  调用的都是[__NSArrayI objectAtIndex:]

/* 特殊类型
1.__NSFrozenArrayM  应该和__NSFrozenDictionaryM类似，但是没有找到触发条件

2.__NSCFArray 以下情况获得

[[NSUserDefaults standardUserDefaults] setObject:[NSMutableArray array] forKey:@"name"];
NSMutableArray *array=[[NSUserDefaults standardUserDefaults] objectForKey:@"name"];

*/


#import "NSArray+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

@implementation NSArray (WTVCrashProtector)
+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        [WTVCrashProtector swizzlingForClass:objc_getClass("__NSSingleObjectArrayI")
                                 originalSel:@selector(objectAtIndex:)
                                swizzlingSel:@selector(wtv_NSSingleObjectArrayI_objectAtIndex:)];

        [WTVCrashProtector swizzlingForClass:objc_getClass("__NSArrayI")
                                 originalSel:@selector(objectAtIndex:)
                                swizzlingSel:@selector(wtv_NSArrayI_objectAtIndex:)];

        [WTVCrashProtector swizzlingForClass:objc_getClass("__NSArrayI")
                                 originalSel:@selector(objectAtIndexedSubscript:)
                                swizzlingSel:@selector(wtv_NSArrayI_objectAtIndexedSubscript:)];

        [WTVCrashProtector swizzlingForClass:objc_getClass("__NSArray0")
                                 originalSel:@selector(objectAtIndex:)
                                swizzlingSel:@selector(wtv_NSArray0_objectAtIndex:)];
    });
}

#pragma mark - __NSSingleObjectArrayI
- (id)wtv_NSSingleObjectArrayI_objectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self wtv_NSSingleObjectArrayI_objectAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSArray];
    } @finally {
        return object;
    }
}

#pragma mark - __NSArrayI
- (id)wtv_NSArrayI_objectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self wtv_NSArrayI_objectAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSArray];
    } @finally {
        return object;
    }
}

- (id)wtv_NSArrayI_objectAtIndexedSubscript:(NSUInteger)idx {
    id object = nil;
    @try {
        object = [self wtv_NSArrayI_objectAtIndexedSubscript:idx];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSArray];
    } @finally {
        return object;
    }
}

#pragma mark - __NSArray0
- (id)wtv_NSArray0_objectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self wtv_NSArray0_objectAtIndex:index];
    } @catch (NSException *exception) {
        [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSArray];
    } @finally {
        return object;
    }
}
@end
