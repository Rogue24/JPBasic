//
//  WTVRedPackageTrafficPrizesView.h
//  WoTV
//
//  Created by 周健平 on 2018/1/24.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTVRedPackageTrafficPrizesCell;
@class WTVRedPackageTrafficCell;
@class WTVRedPackageRainPrizeModel;
@class WTVRedPackageTrafficView;

@interface WTVRedPackageTrafficPrizesView : UIView
+ (instancetype)trafficPrizesView;

@property (nonatomic, weak) WTVRedPackageTrafficPrizesCell *getCell;
@property (nonatomic, weak) WTVRedPackageTrafficPrizesCell *exchangedCell;
@property (nonatomic, weak) WTVRedPackageTrafficPrizesCell *surplusCell;

@property (nonatomic, weak) WTVRedPackageTrafficView *trafficView;

@property (nonatomic, copy) void (^btnDidClick)(WTVRedPackageRainPrizeModel *selectedModel);
@property (nonatomic, copy) void (^lookRuleBlock)(void);
@end


@interface WTVRedPackageTrafficPrizesCell : UIView
- (instancetype)initWithImageName:(NSString *)imageName isOnTop:(BOOL)isOnTop;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *countryTrafficLabel;
@property (nonatomic, weak) UILabel *provinceTrafficLabel;
@property (nonatomic, copy) void (^tapBlock)(void);
@end

@interface WTVRedPackageTrafficView : UIView
@property (nonatomic, strong) NSMutableArray<WTVRedPackageTrafficCell *> *cells;
@property (nonatomic, copy) void (^updateHandle)(CGFloat diffH);
- (instancetype)initWithWidth:(CGFloat)width;
- (void)setupModels:(NSArray<WTVRedPackageRainPrizeModel *> *)models animateBlock:(void(^)(CGFloat diffH, void(^viewChangBlock)(void)))animateBlock;
- (void)updateSurplusPtCount:(NSInteger)surplusPtCount surplusDtCount:(NSInteger)surplusDtCount;
- (void)updateModels:(NSArray<WTVRedPackageRainPrizeModel *> *)models;
@end

@interface WTVRedPackageTrafficCell : UIButton
+ (instancetype)trafficCellWithFrame:(CGRect)frame model:(WTVRedPackageRainPrizeModel *)model target:(id)target action:(SEL)action;
@property (nonatomic, strong) WTVRedPackageRainPrizeModel *model;
@end

