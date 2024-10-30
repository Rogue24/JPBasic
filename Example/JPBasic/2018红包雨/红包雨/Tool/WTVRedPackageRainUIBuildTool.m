//
//  WTVRedPackageRainUIBuildTool.m
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageRainUIBuildTool.h"

@implementation WTVRedPackageRainUIBuildTool

+ (CALayer *)bgLayerOnView:(UIView *)view {
    CALayer *bgLayer = [CALayer layer];
    bgLayer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0].CGColor;
    bgLayer.frame = [UIScreen mainScreen].bounds;
    [view.layer addSublayer:bgLayer];
    return bgLayer;
}

+ (UIImageView *)topBgViewWithFrame:(CGRect)frame onView:(UIView *)view {
    UIImageView *topBgView = [[UIImageView alloc] initWithFrame:frame];
    topBgView.image = [UIImage imageNamed:@"bg_popup_top"];
    [view addSubview:topBgView];
    return topBgView;
}

+ (UIImageView *)bottomBgViewWithFrame:(CGRect)frame onView:(UIView *)view {
    UIImageView *bottomBgView = [[UIImageView alloc] initWithFrame:frame];
    bottomBgView.image = [UIImage imageNamed:@"bg_popup_bottom"];
    [view addSubview:bottomBgView];
    return bottomBgView;
}

+ (UIImageView *)contentViewWithFrame:(CGRect)frame onView:(UIView *)view {
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:frame];
    contentView.image = [UIImage imageNamed:@"webcopy_top"];
    [view addSubview:contentView];
    return contentView;
}

+ (UIImageView *)decorateViewWithFrame:(CGRect)frame onView:(UIView *)view {
    UIImageView *decorateView = [[UIImageView alloc] initWithFrame:frame];
    decorateView.image = [UIImage imageNamed:@"bg_line_star"];
    [view addSubview:decorateView];
    return decorateView;
}

+ (UIImageView *)dogViewWithFrame:(CGRect)frame onView:(UIView *)view {
    UIImageView *dogView = [[UIImageView alloc] initWithFrame:frame];
    dogView.image = [UIImage imageNamed:@"bg_dog"];
    [view addSubview:dogView];
    return dogView;
}

+ (UIImageView *)luckyBagViewWithFrame:(CGRect)frame onView:(UIView *)view {
    UIImageView *luckyBagView = [[UIImageView alloc] initWithFrame:frame];
    luckyBagView.image = [UIImage imageNamed:@"bg_lucky_bag"];
    [view addSubview:luckyBagView];
    return luckyBagView;
}

+ (UIImageView *)backwardsViewWithFrame:(CGRect)frame onView:(UIView *)view {
    UIImageView *backwardsView = [[UIImageView alloc] initWithFrame:frame];
    backwardsView.image = [UIImage imageNamed:@"countdown_webcopy"];
    [view addSubview:backwardsView];
    return backwardsView;
}

+ (UILabel *)backwardsLabelWithFrame:(CGRect)frame onView:(UIView *)view {
    UILabel *backwardsLabel = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.font = [UIFont systemFontOfSize:110];
        aLabel.textColor = JPRGBColor(79, 49, 37);
        aLabel.frame = frame;
        aLabel;
    });
    [view addSubview:backwardsLabel];
    return backwardsLabel;
}

+ (UIButton *)closeBtnOnView:(UIView *)view {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"red_icon_closed"] forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(JPPortraitScreenWidth - 34 - closeBtn.currentImage.size.width, -closeBtn.currentImage.size.height, closeBtn.currentImage.size.width, closeBtn.currentImage.size.height);
    [view addSubview:closeBtn];
    return closeBtn;
}


@end
