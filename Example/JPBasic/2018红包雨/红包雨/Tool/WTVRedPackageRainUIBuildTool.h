//
//  WTVRedPackageRainUIBuildTool.h
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTVRedPackageRainUIBuildTool : NSObject

+ (CALayer *)bgLayerOnView:(UIView *)view;
+ (UIImageView *)topBgViewWithFrame:(CGRect)frame onView:(UIView *)view;
+ (UIImageView *)bottomBgViewWithFrame:(CGRect)frame onView:(UIView *)view;
+ (UIImageView *)contentViewWithFrame:(CGRect)frame onView:(UIView *)view;
+ (UIImageView *)decorateViewWithFrame:(CGRect)frame onView:(UIView *)view;
+ (UIImageView *)dogViewWithFrame:(CGRect)frame onView:(UIView *)view;
+ (UIImageView *)luckyBagViewWithFrame:(CGRect)frame onView:(UIView *)view;
+ (UIImageView *)backwardsViewWithFrame:(CGRect)frame onView:(UIView *)view;
+ (UILabel *)backwardsLabelWithFrame:(CGRect)frame onView:(UIView *)view;
+ (UIButton *)closeBtnOnView:(UIView *)view;

@end
