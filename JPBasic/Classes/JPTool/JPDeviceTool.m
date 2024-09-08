//
//  JPDeviceTool.m
//  WoLive
//
//  Created by 周健平 on 2018/10/9.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import "JPDeviceTool.h"
#import "JPConstant.h"

@implementation JPDeviceTool

+ (NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

+ (NSString *)systemVersion {
    static NSString *systemVersion_ = nil;
    if (!systemVersion_) {
        systemVersion_ = [[UIDevice currentDevice] systemVersion];
    }
    return systemVersion_;
}

+ (int)getSignalIntensity:(BOOL)isWiFi {
    int signalStrength = 0;
    if (@available(iOS 13.0, *)) {
        id statusBar = nil;
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
            UIView *localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
            if ([localStatusBar respondsToSelector:@selector(statusBar)]) {
                statusBar = [localStatusBar performSelector:@selector(statusBar)];
            }
        }
#pragma clang diagnostic pop
        if (statusBar) {
            id currentData = [[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_currentData"];
            // 层级：_UIStatusBarDataNetworkEntry、_UIStatusBarDataIntegerEntry、_UIStatusBarDataEntry
            if (isWiFi) {
                id wifiEntry = [currentData valueForKeyPath:@"_wifiEntry"];
                if ([wifiEntry isKindOfClass:NSClassFromString(@"_UIStatusBarDataIntegerEntry")]) {
                    signalStrength = [[wifiEntry valueForKey:@"displayValue"] intValue];
                }
            } else {
                id cellularEntry = [currentData valueForKeyPath:@"_cellularEntry"];
                if ([cellularEntry isKindOfClass:NSClassFromString(@"_UIStatusBarDataCellularEntry")]) {
                    signalStrength = [[cellularEntry valueForKey:@"displayValue"] intValue];
                }
            }
        }
    } else {
        id statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        if (statusBar) {
            NSArray *subviews;
            NSString *className;
            NSString *key;
            if (JPis_iphoneX) {
                id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
                UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
                subviews = [[foregroundView subviews][2] subviews];
                className = isWiFi ? @"_UIStatusBarWifiSignalView" : @"_UIStatusBarCellularSignalView";
                key = @"_numberOfActiveBars";
            } else {
                UIView *foregroundView = [statusBar valueForKey:@"foregroundView"];
                subviews = [foregroundView subviews];
                className = isWiFi ? @"UIStatusBarDataNetworkItemView" : @"UIStatusBarSignalStrengthItemView";
                key = isWiFi ? @"_wifiStrengthBars" : @"_signalStrengthBars";
            }
            for (id subview in subviews) {
                if ([subview isKindOfClass:[NSClassFromString(className) class]]) {
                    signalStrength = [[subview valueForKey:key] intValue];
                    break;
                }
            }
        }
    }
    return signalStrength;
}

+ (BOOL)goApplicationOpenSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
        return YES;
    } else {
        return NO;
    }
}

@end
