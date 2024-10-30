//
//  WTVRedPackageRainViewController.h
//  WoTV
//
//  Created by 周健平 on 2018/1/18.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTVRedPackageRainScreeningsModel;

@interface WTVRedPackageRainViewController : UIViewController
- (instancetype)initWithTimeText:(NSString *)timeText dismissHandle:(void(^)(WTVRedPackageRainScreeningsModel *finishScreeningsModel))dismissHandle;
- (void)showTrailerAnimated;
- (void)showBackwardsAnimated;

@property (nonatomic, weak) WTVRedPackageRainScreeningsModel *currentScreeningsModel;
@property (nonatomic, strong) WTVRedPackageRainScreeningsModel *finishScreeningsModel;

@property (nonatomic, assign) BOOL isRedPackageRainFinish;
@end
