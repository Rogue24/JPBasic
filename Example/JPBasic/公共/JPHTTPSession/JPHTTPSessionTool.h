//
//  JPHTTPSessionTool.h
//  WoLive
//
//  Created by 周健平 on 2018/3/28.
//  Copyright © 2018年 沃直播. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN CGFloat const WLUploadImageMaxPixelWidth;
UIKIT_EXTERN NSString *const WLUploadImageURLString;
UIKIT_EXTERN NSString *const WLUploadImageName;
#define WLUploadImageFileName [JPHTTPSessionTool uploadImageFileName]

@interface JPHTTPSessionTool : NSObject

//+ (NSString *)stitchApiURLStrWithPrefixURLType:(WLPrefixURLType)prefixURLType
//                                  suffixURLStr:(NSString *)suffixURLStr;
//
//+ (NSMutableDictionary *)setupParameter:(NSDictionary *)parameter;
//
//+ (NSString *)encodeParameter:(NSDictionary *)parameter;
//
//+ (NSString *)uploadImageFileName;

+ (id)JSONObjectWithData:(NSData *)data error:(NSError **)error;
+ (id)removeNull:(id)object;

+ (NSString *)urlWithHome;
+ (NSDictionary *)paramWithHome;

@end
