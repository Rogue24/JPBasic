//
//  WTVRedPackageRainView.h
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTVRedPackageView.h"

@protocol WTVRedPackageRainViewDelegate <NSObject>

@property (nonatomic, readonly) NSTimeInterval currentTime;

- (void)redPackageViewDidClick:(WTVRedPackageView *)redPackageView atPoint:(CGPoint)point;

@end

@interface WTVRedPackageRainView : UIView
@property (nonatomic, weak) id<WTVRedPackageRainViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<WTVRedPackageModel *> *models;

- (void)pause;
- (void)resume;
@end
