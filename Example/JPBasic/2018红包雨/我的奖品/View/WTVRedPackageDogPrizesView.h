//
//  WTVRedPackageDogPrizesView.h
//  WoTV
//
//  Created by 周健平 on 2018/1/24.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTVRedPackageRainPrizeModel;

@interface WTVRedPackageDogPrizesView : UIView
+ (instancetype)dogPrizesView;
- (void)setupModels:(NSArray<WTVRedPackageRainPrizeModel *> *)models animateBlock:(void(^)(CGFloat diffH, void(^viewChangBlock)(void)))animateBlock;
- (void)updateConforming:(NSInteger)dogTypeCount;
- (void)updateModels:(NSArray<WTVRedPackageRainPrizeModel *> *)models;

@property (nonatomic, weak) WTVRedPackageRainPrizeModel *exchangedDogPrizeModel;
@property (nonatomic, copy) void (^btnDidClick)(WTVRedPackageRainPrizeModel *selectedModel);
@property (nonatomic, copy) void (^lookRuleBlock)(void);

@end

@interface WTVRedPackageDogPrizesCell : UIView
- (instancetype)initWithModel:(WTVRedPackageRainPrizeModel *)model;
@property (nonatomic, strong) WTVRedPackageRainPrizeModel *model;
@property (nonatomic, assign) BOOL isConforming;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isCanExchanged;
@property (nonatomic, copy) void (^tapBlock)(WTVRedPackageDogPrizesCell *tapCell);
@end



