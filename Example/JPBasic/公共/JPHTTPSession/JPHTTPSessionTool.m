//
//  JPHTTPSessionTool.m
//  WoLive
//
//  Created by 周健平 on 2018/3/28.
//  Copyright © 2018年 沃直播. All rights reserved.
//

#import "JPHTTPSessionTool.h"
#import "JPHTTPSessionManager.h"
#import <MJExtension/MJExtension.h>
//#import "TripleDES.h"

#import <CommonCrypto/CommonDigest.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

CGFloat const WLUploadImageMaxPixelWidth = 750.0; // 这是服务器能接受的最大像素值？
NSString *const WLUploadImageURLString = @"http://wotvnews.17wo.cn:8090/wovideo/backstage/uploadUserLogo";
NSString *const WLUploadImageName = @"userfile";

@implementation JPHTTPSessionTool

//#ifdef DEBUG
//
//#else
//
//#endif

//+ (NSString *)stitchApiURLStrWithPrefixURLType:(WLPrefixURLType)prefixURLType
//                                  suffixURLStr:(NSString *)suffixURLStr {
//    NSString *apiURLStr = WLDomainURL;
//    switch (prefixURLType) {
//        case WLWoliveType:
//            apiURLStr = [NSString stringWithFormat:@"%@/wolive", apiURLStr];
//            break;
//        default:
//            return apiURLStr;
//    }
//    if (suffixURLStr.length) {
//        if ([[suffixURLStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"/"]) {
//            apiURLStr = [NSString stringWithFormat:@"%@%@", apiURLStr, suffixURLStr];
//        } else {
//            apiURLStr = [NSString stringWithFormat:@"%@/%@", apiURLStr, suffixURLStr];
//        }
//    }
////    JPLog(@"请求的URL：%@", apiURLStr);
//    return apiURLStr;
//}
//
//+ (NSMutableDictionary *)setupParameter:(NSDictionary *)parameter {
//    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionary];
//    if (parameter && parameter.count) parameterDic.dictionary = parameter;
//    parameterDic[@"appName"] = WLAppName;
//    parameterDic[@"version"] = JPConstant.appVersion;
//
//    WLUserAccount *account = WLAccount;
//    if (account) {
//        if (!parameterDic[@"userid"]) {
//            NSString *userid = account.userid;
//            if (userid) {
//                parameterDic[@"userid"] = userid;
//            } else {
//                JPLog(@"缺失userid");
//            }
//        }
//        if (!parameterDic[@"mobile"]) {
//            NSString *mobile = account.mobile;
//            if (mobile) {
//                parameterDic[@"mobile"] = mobile;
//            } else {
//                JPLog(@"缺失mobile");
//            }
//        }
//    } else {
//        JPLog(@"account为空，没有登录");
//    }
//
//    return parameterDic;
//}
//
//+ (NSString *)encodeParameter:(NSDictionary *)parameter {
//
//    NSMutableString *parameterStr = [NSMutableString string];
//    [parameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        if (parameterStr.length) [parameterStr appendString:@";"];
//        NSString *objStr;
//        if ([obj isKindOfClass:[NSString class]]) {
//            objStr = obj;
//        } else if ([obj isKindOfClass:[NSDictionary class]] ||
//                   [obj isKindOfClass:[NSArray class]]){
//            objStr = [(NSObject *)obj mj_JSONString];
//        } else if ([obj isKindOfClass:[NSNumber class]]) {
//            objStr = [(NSNumber *)obj stringValue];
//        } else {
//            objStr = [NSString stringWithFormat:@"%@", obj];
//        }
//        if (objStr) [parameterStr appendFormat:@"%@=%@", key, objStr];
//    }];
//
//    NSString *desParam = [TripleDES encryptUseDES:parameterStr key:WLDESKEY];
//    desParam = [TripleDES encodeUrlString:desParam];
//    if (!desParam) desParam = @"";
//
////    JPLog(@"请求的参数：%@", parameter);
//    return desParam;
//}
//
//+ (NSString *)uploadImageFileName {
//    NSString *timeStr = [JPGreenwichDateFormatter stringFromDate:[NSDate date]];
//    return [NSString stringWithFormat:@"%@_%@_%@", WLAppName, timeStr, WLAccount.userid];
//}

+ (id)JSONObjectWithData:(NSData *)data error:(NSError **)error {
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    return [self removeNull:result];
}

+ (id)removeNull:(id)object {
    if ([object isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *dic = [object mutableCopy];
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSDictionary.class] ||
                [obj isKindOfClass:NSArray.class] ||
                [obj isKindOfClass:NSNull.class]) {
                dic[key] = [self removeNull:obj];
            }
        }];
        object = dic.copy;
    } else if ([object isKindOfClass:NSArray.class]) {
        NSMutableArray *array = [object mutableCopy];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSDictionary.class] ||
                [obj isKindOfClass:NSArray.class] ||
                [obj isKindOfClass:NSNull.class]) {
                array[idx] = [self removeNull:obj];
            }
        }];
        object = array.copy;
    } else if ([object isKindOfClass:NSNull.class]) {
        object = @"";
    }
    return object;
}

// 测试代码
//    NSDictionary *dic = @{@"0": [NSNull null],
//                          @"1": @[@0,
//                                  @{@"0": [NSNull null],
//                                    @"1": @[@0, @1, @2, [NSNull null]],
//                                    @"2": @{@"00": @"00", @"11": @[@0, @1, @2, [NSNull null]]},
//                                    @"3": @"3"},
//                                  @2,
//                                  [NSNull null]],
//                          @"2": @{@"00": @"00", @"11": @[@0, @1, @2, [NSNull null]]},
//                          @"3": @"3"};
//    NSLog(@"111 %@", dic);
//    dic = [self removeNull:dic];
//    NSLog(@"222 %@", dic);



+ (NSString *)urlWithHome {
    return @"https://www.yunke.com/interface/main/home";
}

+ (NSDictionary *)paramWithHome {
    NSDictionary * params = @{@"city":@"中国",
                              @"cityId":@0,
                              //                              @"condition":userDict[@"condition"],
                              @"condition":@"35,33,32,35,34",
                              //                              @"teacherSeach":userDict[@"teacherSeach"],
                              @"teacherSeach":@"1000,1000,1000"
                              };
    NSString *version = [self Version];
    
    //   获取当前的时间
    int liTime = [self getDateByInt];
    NSString *keymd5 = [self md5ForParamas:params time:liTime];
    NSDictionary *myparamses =@{
                                @"u":@"i",
                                @"v":version,
                                @"time":@(liTime),
                                @"params":params,
                                @"key":keymd5
//                                @"dinfo":[self getDinfo]
                                };
//    NSLog(@"%@",myparamses);

    return myparamses;
}

+ (NSString *)Version {
    
    NSString *string = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:string];
    NSString *version = [dic objectForKey:@"CFBundleVersion"];
    return version;
    
}

+ (int)getDateByInt {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormat dateFromString:[dateFormat stringFromDate:[NSDate date]]];
    NSTimeInterval dateInterval = [date timeIntervalSince1970];
    int liDate = (int) dateInterval;
    return liDate;
}

// 参数md5 key值
static NSString * const salt = @"gn1002015";
+ (NSString *)md5ForParamas:(NSDictionary *)paramas time:(int)aiTime {

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramas options:NSJSONReadingAllowFragments error:nil];
    // NSJSONReadingAllowFragments : 使用这个
    // NSJSONWritingPrettyPrinted 会有\n，不需要
    NSString *jsonParserString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *myString = [NSString stringWithFormat:@"%@%d%@",jsonParserString,aiTime, salt];
    
    NSString *keyMD5 = [self getMd5_32Bit_String:myString];
    NSString *keymd5 = [self getMd5_32Bit_String:keyMD5];
    
    return keymd5;
}

//  MD5
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString {
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}

@end
