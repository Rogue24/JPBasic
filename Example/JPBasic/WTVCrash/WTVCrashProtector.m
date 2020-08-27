//
//  WTVCrashProtector.m
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#import "WTVCrashProtector.h"
#import <mach-o/dyld.h>

/// 默认打印所有日志
static WTVCrashProtectorLogType log_type = WTVCrashProtectorLogTypeAll;

static WTVCrashProtectorBlock crashProtectorBlock;

/// 给NSObject添加额外的声明
@interface NSObject (WTVCrashProtector)
+ (void)wtv_openCrashProtector;
+ (void)wtv_openMRCCrashProtector;
+ (void)wtv_openKVOCrashProtector;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (WTVCrashProtector)
@end
#pragma clang diagnostic pop

@implementation WTVCrashProtector

+ (void)openCrashProtectorWithIsDebug:(BOOL)isDebug
                           crashBlock:(WTVCrashProtectorBlock)block {
    [WTVCrashProtector openCrashProtectorWithIsDebug:isDebug
                                               types:WTVCrashProtectorTypeSelector |
                                                     WTVCrashProtectorTypeNSUSerDefault |
                                                     WTVCrashProtectorTypeNSCache |
                                                     WTVCrashProtectorTypeArraryContainer |
                                                     WTVCrashProtectorTypeDictionaryContainer |
                                                     WTVCrashProtectorTypeStringContainer |
                                                     WTVCrashProtectorTypeAttributedStringContainer |
                                                     WTVCrashProtectorTypeSetContainer |
                                                     WTVCrashProtectorTypeOrderSetContainer |
                                                     WTVCrashProtectorTypeDataContainer
                                          crashBlock:block];
}

+ (void)openCrashProtectorWithIsDebug:(BOOL)isDebug
                                types:(WTVCrashProtectorType)types
                           crashBlock:(WTVCrashProtectorBlock)block {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log_type = isDebug ? WTVCrashProtectorLogTypeAll : WTVCrashProtectorLogTypeNone;

        if (types & WTVCrashProtectorTypeSelector) {
            [NSObject wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSUSerDefault) {
            [NSUserDefaults wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSCache) {
            [NSCache wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSArray) {
            [NSArray wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSMutableArray) {
            [NSMutableArray wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSDictionary) {
            [NSDictionary wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSMutableDictionary) {
            [NSMutableDictionary wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSString) {
            [NSString wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSMutableString) {
            [NSMutableString wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSAttributedString) {
            [NSAttributedString wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSMutableAttributedString) {
            [NSMutableAttributedString wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSSet) {
            [NSSet wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSMutableSet) {
            [NSMutableSet wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSOrderSet) {
            [NSOrderedSet wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSMutableOrderSet) {
            [NSMutableOrderedSet wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSData) {
            [NSData wtv_openCrashProtector];
        }

        if (types & WTVCrashProtectorTypeNSMutableData) {
            [NSMutableData wtv_openCrashProtector];
        }

        crashProtectorBlock = block;
    });
}

/**
 自定义崩溃信息
 @param exception 异常信息
 @param crashType 崩溃类型
 */
+ (void)crashProtectorWithException:(NSException *)exception crashType:(WTVCrashProtectorType)crashType {
    /// 获取线程堆栈信息集合
    NSArray *callStackSymbols = (exception.callStackSymbols.count > 0) ? exception.callStackSymbols : [NSThread callStackSymbols];
    NSString *callStackSymbolsStr = [callStackSymbols componentsJoinedByString:@"\r\n"];

    long slide = -1;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
            slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }

    // 转化为16进制 0x1内存地址标识, %08lx 8位十六进制
    NSString *hexString = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithFormat:@"0x1%08lx", slide]];
    
    // 异常报告
    NSString *crashReport = [NSString stringWithFormat:@"\r\n name:%@ \r\n slideAddress:%@ \r\n reason:%@ \r\n callStackSymbols:%@ \r\n", exception.name, hexString, exception, callStackSymbolsStr];
    
    if (crashProtectorBlock) {
        crashProtectorBlock(crashReport, crashType);
    }

    if (log_type == WTVCrashProtectorLogTypeAll) {
        NSLog(@"%@", crashReport);
        assert(NO && "检测到崩溃,q详情请查看上面的信息");
    }

}

#pragma mark - method swizzling
+ (void)swizzlingForClass:(Class)cls originalSel:(SEL)originalSelector swizzlingSel:(SEL)swizzlingSelector {
    Class class = cls;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzlingMethod = class_getInstanceMethod(class, swizzlingSelector);

    BOOL isAddedMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));

    if (isAddedMethod) {
        class_replaceMethod(class, swizzlingSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzlingMethod);
    }
}
@end
