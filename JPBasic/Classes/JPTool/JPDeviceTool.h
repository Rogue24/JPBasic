//
//  JPDeviceTool.h
//  WoLive
//
//  Created by 周健平 on 2018/10/9.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPDeviceTool : NSObject
+ (NSString *)deviceName;
+ (NSString *)systemVersion;
+ (int)getSignalIntensity:(BOOL)isWiFi;
+ (BOOL)goApplicationOpenSettings;
@end
