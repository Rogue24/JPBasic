//
//  WTVCrashProtectorDefine.h
//  WoTV
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhanglinan. All rights reserved.
//

#ifndef WTVCrashProtectorDefine_h
#define WTVCrashProtectorDefine_h

typedef NS_ENUM(NSInteger, WTVCrashProtectorLogType) {
    WTVCrashProtectorLogTypeAll,
    WTVCrashProtectorLogTypeNone
};

typedef NS_OPTIONS(NSInteger, WTVCrashProtectorType) {
    /// unregolize selector
    WTVCrashProtectorTypeSelector                  = 1 << 0,
    WTVCrashProtectorTypeNSUSerDefault             = 1 << 15,
    WTVCrashProtectorTypeNSCache                   = 1 << 16,
    
    /// containtor
    WTVCrashProtectorTypeNSArray                   = 1 << 1,
    WTVCrashProtectorTypeNSMutableArray            = 1 << 2,

    WTVCrashProtectorTypeNSDictionary              = 1 << 3,
    WTVCrashProtectorTypeNSMutableDictionary       = 1 << 4,

    WTVCrashProtectorTypeNSString                  = 1 << 5,
    WTVCrashProtectorTypeNSMutableString           = 1 << 6,

    WTVCrashProtectorTypeNSAttributedString         = 1 << 7,
    WTVCrashProtectorTypeNSMutableAttributedString  = 1 << 8,

    WTVCrashProtectorTypeNSSet                     = 1 << 9,
    WTVCrashProtectorTypeNSMutableSet              = 1 << 10,

    WTVCrashProtectorTypeNSOrderSet                = 1 << 11,
    WTVCrashProtectorTypeNSMutableOrderSet         = 1 << 12,

    WTVCrashProtectorTypeNSData                      = 1 << 13,
    WTVCrashProtectorTypeNSMutableData               = 1 << 14,

    WTVCrashProtectorTypeArraryContainer =
    WTVCrashProtectorTypeNSArray |
    WTVCrashProtectorTypeNSMutableArray,

    WTVCrashProtectorTypeDictionaryContainer =
    WTVCrashProtectorTypeNSDictionary |
    WTVCrashProtectorTypeNSMutableDictionary,

    WTVCrashProtectorTypeStringContainer =
    WTVCrashProtectorTypeNSString |
    WTVCrashProtectorTypeNSMutableString,

    WTVCrashProtectorTypeAttributedStringContainer =
    WTVCrashProtectorTypeNSAttributedString |
    WTVCrashProtectorTypeNSMutableAttributedString,

    WTVCrashProtectorTypeSetContainer =
    WTVCrashProtectorTypeNSSet |
    WTVCrashProtectorTypeNSMutableSet,

    WTVCrashProtectorTypeOrderSetContainer =
    WTVCrashProtectorTypeNSOrderSet |
    WTVCrashProtectorTypeNSMutableOrderSet,

    WTVCrashProtectorTypeDataContainer =
    WTVCrashProtectorTypeNSData |
    WTVCrashProtectorTypeNSMutableData,

    /// all type
    WTVCrashProtectorTypeAll =
    WTVCrashProtectorTypeSelector |
    WTVCrashProtectorTypeNSUSerDefault |
    WTVCrashProtectorTypeNSCache |
    WTVCrashProtectorTypeArraryContainer |
    WTVCrashProtectorTypeDictionaryContainer |
    WTVCrashProtectorTypeStringContainer |
    WTVCrashProtectorTypeAttributedStringContainer |
    WTVCrashProtectorTypeSetContainer |
    WTVCrashProtectorTypeOrderSetContainer |
    WTVCrashProtectorTypeDataContainer
};

typedef void(^WTVCrashProtectorBlock)(NSString *crashReport, WTVCrashProtectorType crashType);
#endif /* WTVCrashProtectorDefine_h */
