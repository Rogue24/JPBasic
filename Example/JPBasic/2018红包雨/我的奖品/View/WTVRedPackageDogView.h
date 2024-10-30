//
//  WTVRedPackageDogView.h
//  WoTV
//
//  Created by 周健平 on 2018/1/29.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTVRedPackageRainDogModel;

@interface WTVRedPackageDogView : UIView
+ (instancetype)dogView;
- (NSInteger)setupModels:(NSArray<WTVRedPackageRainDogModel *> *)models animateBlock:(void(^)(CGFloat diffH, void(^viewChangBlock)(void)))animateBlock;
- (NSInteger)updateModels:(NSArray<WTVRedPackageRainDogModel *> *)models;

@property (nonatomic, copy) void (^giveBtnDidClick)(WTVRedPackageRainDogModel *selectedModel);
@property (nonatomic, copy) void (^getBtnDidClick)(WTVRedPackageRainDogModel *selectedModel);
@end

@interface WTVRedPackageDogCell : UIView

- (instancetype)initWithModel:(WTVRedPackageRainDogModel *)model;
@property (nonatomic, strong) WTVRedPackageRainDogModel *model;

@property (nonatomic, assign) BOOL isLooking;
- (void)setIsLooking:(BOOL)isLooking animated:(BOOL)animated;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, copy) void (^tapBlock)(WTVRedPackageDogCell *tapCell);
@end
