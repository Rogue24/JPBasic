//
//  WTVRedPackageRainResultView.h
//  WoTV
//
//  Created by 周健平 on 2018/1/23.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTVRedPackageModel;
@class WTVRedPackageRainScreeningsModel;
@class WTVRedPackageRainGiftModel;

@interface WTVRedPackageRainResultView : UIView
- (instancetype)initWithFinishScreeningsModel:(WTVRedPackageRainScreeningsModel *)finishScreeningsModel shareGiftModel:(WTVRedPackageRainGiftModel *)shareGiftModel prizeDrawSuccess:(void(^)(void))prizeDrawSuccess closeBlock:(void(^)(void))closeBlock;
- (void)showAnimated;
@property (nonatomic, strong) WTVRedPackageRainScreeningsModel *finishScreeningsModel;
@property (nonatomic, strong) WTVRedPackageRainGiftModel *shareGiftModel;

@property (nonatomic, copy) void (^prizeDrawSuccess)(void);
@property (nonatomic, copy) void (^closeBlock)(void);
@end
