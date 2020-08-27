//
//  NSUserDefaults+WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "NSUserDefaults+WTVCrashProtector.h"
#import "WTVCrashProtector.h"

/*
可避免以下方法  key=nil时的crash

 - (void)setObject:(nullable id)value forKey:(NSString *)defaultName;
 - (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
 - (void)setFloat:(float)value forKey:(NSString *)defaultName;
 - (void)setDouble:(double)value forKey:(NSString *)defaultName;
 - (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
 - (void)setURL:(nullable NSURL *)url forKey:(NSString *)defaultName API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

 - (nullable id)objectForKey:(NSString *)defaultName;
 - (nullable NSString *)stringForKey:(NSString *)defaultName;
 - (nullable NSArray *)arrayForKey:(NSString *)defaultName;
 - (nullable NSDictionary<NSString *, id> *)dictionaryForKey:(NSString *)defaultName;
 - (nullable NSData *)dataForKey:(NSString *)defaultName;
 - (nullable NSArray<NSString *> *)stringArrayForKey:(NSString *)defaultName;
 - (NSInteger)integerForKey:(NSString *)defaultName;
 - (float)floatForKey:(NSString *)defaultName;
 - (double)doubleForKey:(NSString *)defaultName;
 - (BOOL)boolForKey:(NSString *)defaultName;
*/

@implementation NSUserDefaults (WTVCrashProtector)

+ (void)wtv_openCrashProtector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = NSClassFromString(@"NSUserDefaults");

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(setObject:forKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_setObject:forKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(setInteger:forKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_setInteger:forKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(setFloat:forKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_setFloat:forKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(setDouble:forKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_setDouble:forKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(setBool:forKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_setBool:forKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(setURL:forKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_setURL:forKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(objectForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_objectForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(stringForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_stringForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(arrayForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_arrayForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(dictionaryForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_dictionaryForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(dataForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_dataForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(stringArrayForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_stringArrayForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(integerForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_integerForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(floatForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_floatForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(doubleForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_doubleForKey:)];

        [WTVCrashProtector swizzlingForClass:aClass
                                 originalSel:@selector(boolForKey:)
                                swizzlingSel:@selector(wtv_NSUserDefaults_boolForKey:)];

    });
}

// 这里使用try catch无效,defaultName为空就会崩溃
#pragma mark - NSUserDefaults
- (void)wtv_NSUserDefaults_setObject:(nullable id)value forKey:(NSString *)defaultName {
    defaultName ? [self wtv_NSUserDefaults_setObject:value forKey:defaultName]: [self recordCrashLogWithSelector:_cmd];
}

- (void)wtv_NSUserDefaults_setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    defaultName ? [self wtv_NSUserDefaults_setInteger:value forKey:defaultName]: [self recordCrashLogWithSelector:_cmd];
}

- (void)wtv_NSUserDefaults_setFloat:(float)value forKey:(NSString *)defaultName {
    defaultName ? [self wtv_NSUserDefaults_setFloat:value forKey:defaultName]: [self recordCrashLogWithSelector:_cmd];
}

- (void)wtv_NSUserDefaults_setDouble:(double)value forKey:(NSString *)defaultName {
    defaultName ? [self wtv_NSUserDefaults_setDouble:value forKey:defaultName]: [self recordCrashLogWithSelector:_cmd];
}

- (void)wtv_NSUserDefaults_setBool:(BOOL)value forKey:(NSString *)defaultName {
    defaultName ? [self wtv_NSUserDefaults_setBool:value forKey:defaultName]: [self recordCrashLogWithSelector:_cmd];
}

- (void)wtv_NSUserDefaults_setURL:(nullable NSURL *)value forKey:(NSString *)defaultName {
    defaultName ? [self wtv_NSUserDefaults_setURL:value forKey:defaultName]: [self recordCrashLogWithSelector:_cmd];
}

- (nullable id)wtv_NSUserDefaults_objectForKey:(NSString *)defaultName {
    id object = nil;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_objectForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

 - (nullable NSString *)wtv_NSUserDefaults_stringForKey:(NSString *)defaultName {
    NSString *object = nil;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_stringForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

 - (nullable NSArray *)wtv_NSUserDefaults_arrayForKey:(NSString *)defaultName {
    NSArray *object = nil;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_arrayForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

 - (nullable NSDictionary<NSString *, id> *)wtv_NSUserDefaults_dictionaryForKey:(NSString *)defaultName {
    NSDictionary<NSString *, id> *object = nil;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_dictionaryForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

 - (nullable NSData *)wtv_NSUserDefaults_dataForKey:(NSString *)defaultName {
    NSData *object = nil;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_dataForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

- (nullable NSArray<NSString *> *)wtv_NSUserDefaults_stringArrayForKey:(NSString *)defaultName {
    NSArray<NSString *> *object = nil;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_stringArrayForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

 - (NSInteger)wtv_NSUserDefaults_integerForKey:(NSString *)defaultName {
    NSInteger object = 0;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_integerForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

 - (float)wtv_NSUserDefaults_floatForKey:(NSString *)defaultName {
    float object = 0;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_floatForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

- (double)wtv_NSUserDefaults_doubleForKey:(NSString *)defaultName {
    double object = 0;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_doubleForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

- (BOOL)wtv_NSUserDefaults_boolForKey:(NSString *)defaultName {
    BOOL object = NO;
    if (defaultName) {
        object = [self wtv_NSUserDefaults_boolForKey:defaultName];
    } else {
        [self recordCrashLogWithSelector:_cmd];
    }
    return object;
}

- (void)recordCrashLogWithSelector:(SEL)cmd {
    NSString *reason = [NSString stringWithFormat:@"NSUserDefaults's selector %@ key  can`t be nil", NSStringFromSelector(cmd)];
    NSException *exception = [NSException exceptionWithName:reason reason:reason userInfo:nil];
    [WTVCrashProtector crashProtectorWithException:exception crashType:WTVCrashProtectorTypeNSUSerDefault];
}
@end
