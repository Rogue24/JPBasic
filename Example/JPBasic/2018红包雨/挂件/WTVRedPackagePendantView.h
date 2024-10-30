//
//  WTVRedPackagePendantView.h
//  WoTV
//
//  Created by 周健平 on 2018/1/24.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTVRedPackageRainViewController.h"

typedef NS_ENUM(NSUInteger, WTVRedPackagePendantState) {
    WTVRedPackagePendantHide,
    WTVRedPackagePendantChoose,
    WTVRedPackagePendantShowOnTop,
    WTVRedPackagePendantShowOnLeft,
};

@interface WTVRedPackagePendantView : UIView

- (void)show;

- (void)hide;

- (void)hideThorough;

- (void)showOnLeft;

- (void)topTap:(UITapGestureRecognizer *)topTapGR;

@property (nonatomic, assign) BOOL isShowed;

@property (nonatomic, weak) UIViewController *superVC;

@property (nonatomic, assign) WTVRedPackagePendantState state;

@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, copy) void (^tapBlock)(void);
@property (nonatomic, copy) void (^showComplete)(void);

@end
