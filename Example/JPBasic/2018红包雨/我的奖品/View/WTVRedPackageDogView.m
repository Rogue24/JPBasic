//
//  WTVRedPackageDogView.m
//  WoTV
//
//  Created by 周健平 on 2018/1/29.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageDogView.h"
#import "WTVRedPackageRainManager.h"
#import "UIImageView+JPExtension.h"

@interface WTVRedPackageDogView ()
@property (nonatomic, strong) NSMutableArray<WTVRedPackageDogCell *> *cells;
@property (nonatomic, strong) UIButton *giveBtn;
@property (nonatomic, strong) UIButton *getBtn;
@property (nonatomic, assign) CGFloat cellViewMaxY;
@end

@implementation WTVRedPackageDogView
{
    BOOL _isPhoneLogin;
}

+ (instancetype)dogView {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        
        _isPhoneLogin = RPManager.isPhoneLogin;
        
        CGFloat scale = JPScale;
        
        CGFloat x = 0;
        CGFloat y = 0;
        
        self.cells = [NSMutableArray array];
        
        @jp_weakify(self);
        for (NSInteger i = 0; i < 6; i++) {
            
            WTVRedPackageDogCell *cell = [[WTVRedPackageDogCell alloc] initWithModel:nil];
            x = i % 3 * (cell.jp_width + 5);
            y = i / 3 * (cell.jp_height + (_isPhoneLogin ? 15.0 : 5.0));
            cell.jp_origin = CGPointMake(x, y);
            
            cell.tapBlock = ^(WTVRedPackageDogCell *tapCell) {
                @jp_strongify(self);
                if (!self) return;
                for (WTVRedPackageDogCell *cell in self.cells) {
                    if (tapCell != cell) {
                        cell.isSelected = NO;
                    } else {
                        cell.isSelected = !cell.isSelected;
                    }
                }
            };
            
            [self addSubview:cell];
            [self.cells addObject:cell];
            
            if (i == 5) {
                self.cellViewMaxY = cell.jp_maxY;
            }
        }
        
        CGFloat selfW = JPPortraitScreenWidth - 20;
        CGFloat selfH = 0;
        
        if (_isPhoneLogin) {
            
            CGFloat w = 160.0 * scale;
            CGFloat h = 40.0 * scale;
            x = 0;
            y = self.cells.lastObject.jp_maxY + 25.0 * scale;
            UIButton *giveBtn = ({
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setImage:[UIImage imageNamed:@"me_btn_share_send"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(giveDog) forControlEvents:UIControlEventTouchUpInside];
                btn.frame = CGRectMake(x, y, w, h);
                btn;
            });
            [self addSubview:giveBtn];
            self.giveBtn = giveBtn;
            
            x = selfW - w;
            UIButton *getBtn = ({
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setImage:[UIImage imageNamed:@"me_btn_share_beg"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(getDog) forControlEvents:UIControlEventTouchUpInside];
                btn.frame = CGRectMake(x, y, w, h);
                btn;
            });
            [self addSubview:getBtn];
            self.getBtn = getBtn;
            
            selfH = giveBtn.jp_maxY;
            
        } else {
            selfH = self.cells.lastObject.jp_maxY;
            
            NSArray *models = [WTVRedPackageRainDogModel noPhoneLoginModels];
            for (NSInteger i = 0; i < 6; i++) {
                WTVRedPackageDogCell *cell = self.cells[i];
                cell.model = models[i];
            }
        }
        
        self.jp_size = CGSizeMake(selfW, selfH);
        
    }
    return self;
}

- (void)giveDog {
    if (self.giveBtnDidClick) {
        WTVRedPackageRainDogModel *model;
        for (WTVRedPackageDogCell *cell in self.cells) {
            if (cell.isSelected) {
                model = cell.model;
                break;
            }
        }
        self.giveBtnDidClick(model);
    }
}

- (void)getDog {
    if (self.getBtnDidClick) {
        WTVRedPackageRainDogModel *model;
        for (WTVRedPackageDogCell *cell in self.cells) {
            if (cell.isSelected) {
                model = cell.model;
                break;
            }
        }
        self.getBtnDidClick(model);
    }
}

- (NSInteger)setupModels:(NSArray<WTVRedPackageRainDogModel *> *)models animateBlock:(void (^)(CGFloat, void (^)(void)))animateBlock {
    
    NSInteger dogTypeCount = 0;
    
    NSInteger cellCount = self.cells.count;
    NSInteger count = models.count;
    
    NSMutableArray *showCells = [NSMutableArray array];
    NSMutableArray *hideCells = [NSMutableArray array];
    CGFloat cellViewMaxY = self.cellViewMaxY;
    for (NSInteger i = 0; i < cellCount; i++) {
        WTVRedPackageDogCell *cell = self.cells[i];
        if (i < count) {
            if (cell.alpha == 0) {
                [showCells addObject:cell];
            }
            cell.model = models[i];
            if (cell.model.count > 0) {
                dogTypeCount += 1;
            }
        } else {
            if (cell.alpha > 0) {
                [hideCells addObject:cell];
            }
        }
        
        if (i == count - 1) cellViewMaxY = cell.jp_maxY;
    }
    
    if (self.cellViewMaxY == cellViewMaxY) {
        [UIView animateWithDuration:0.35 animations:^{
            for (UICollectionViewCell *cell in showCells) {
                cell.alpha = 1;
            }
            for (UICollectionViewCell *cell in hideCells) {
                cell.alpha = 0;
            }
        }];
        !animateBlock ? : animateBlock(0, nil);
        return dogTypeCount;
    }
    
    if (animateBlock) {
        CGFloat diffH = cellViewMaxY - self.cellViewMaxY;
        
        @jp_weakify(self);
        void (^viewChangBlock)(void) = ^{
            @jp_strongify(self);
            if (!self) return;
            for (UICollectionViewCell *cell in showCells) {
                cell.alpha = 1;
            }
            for (UICollectionViewCell *cell in hideCells) {
                cell.alpha = 0;
            }
            self.giveBtn.jp_y += diffH;
            self.getBtn.jp_y += diffH;
            self.jp_height += diffH;
        };
        
        animateBlock(diffH, viewChangBlock);
    }
    
    return dogTypeCount;
}

- (NSInteger)updateModels:(NSArray<WTVRedPackageRainDogModel *> *)models {
    NSInteger dogTypeCount = 0;
    NSInteger cellCount = self.cells.count;
    NSInteger count = models.count;
    NSMutableArray *showCells = [NSMutableArray array];
    NSMutableArray *hideCells = [NSMutableArray array];
    
    for (NSInteger i = 0; i < cellCount; i++) {
        WTVRedPackageDogCell *cell = self.cells[i];
        if (i < count) {
            if (cell.alpha == 0) {
                [showCells addObject:cell];
            }
            cell.model = models[i];
            if (cell.model.count > 0) {
                dogTypeCount += 1;
            }
        } else {
            if (cell.alpha > 0) {
                [hideCells addObject:cell];
            }
        }
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        for (UICollectionViewCell *cell in showCells) {
            cell.alpha = 1;
        }
        for (UICollectionViewCell *cell in hideCells) {
            cell.alpha = 0;
        }
    }];
    
    return dogTypeCount;
}

@end

@interface WTVRedPackageDogCell ()
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIImageView *frontImageView;
@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UIImageView *selectedView;
@property (nonatomic, weak) UILabel *selectedLabel;
@end

@implementation WTVRedPackageDogCell
{
    BOOL _isPhoneLogin;
}

- (instancetype)initWithModel:(WTVRedPackageRainDogModel *)model {
    if (self = [super init]) {
        _isPhoneLogin = RPManager.isPhoneLogin;
        
        CGFloat scale = JPScale;
        
        CGFloat selfW = (JPPortraitScreenWidth - 20 - 10) / 3.0;
        CGFloat w = selfW;
        CGFloat h = w;
        CGFloat x = 0;
        CGFloat y = 0;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        contentView.backgroundColor = JPRGBColor(255, 54, 68);
        contentView.layer.masksToBounds = YES;
        contentView.layer.cornerRadius = 6.0;
        contentView.layer.borderColor = JPRGBColor(255, 181, 53).CGColor;
        [self addSubview:contentView];
        self.contentView = contentView;
        
        UIImageView *frontImageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
        [contentView addSubview:frontImageView];
        self.frontImageView = frontImageView;
        
        CGFloat selfH = 0;
        if (_isPhoneLogin) {
            
            UIImageView *backImageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
            [contentView addSubview:backImageView];
            self.backImageView = backImageView;
            
            CGFloat bottomViewH = 12 * scale;
            w = 10 * scale;
            h = w;
            x = 0;
            y = (bottomViewH - h) * 0.5;
            UIImageView *selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
            selectedView.image = [UIImage imageNamed:@"me_dog_point"];

            UILabel *selectedLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.textAlignment = NSTextAlignmentCenter;
                aLabel.font = [UIFont systemFontOfSize:bottomViewH];
                aLabel.textColor = [UIColor whiteColor];
                aLabel.text = @"已拥有：99个";
                [aLabel sizeToFit];
                aLabel.text = @"已拥有：0个";
                aLabel.jp_height = bottomViewH;
                aLabel.jp_x = selectedView.jp_maxX + 5;
                aLabel;
            });
            
            w = selectedLabel.jp_maxX;
            h = bottomViewH;
            x = (selfW - w) * 0.5;
            y = contentView.jp_maxY + 10;
            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];

            [bottomView addSubview:selectedView];
            self.selectedView = selectedView;

            [bottomView addSubview:selectedLabel];
            self.selectedLabel = selectedLabel;
            
            [self addSubview:bottomView];
            selfH = bottomView.jp_maxY;
            
            [contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
            
        } else {
            selfH = contentView.jp_maxY;
        }
        
        self.jp_size = CGSizeMake(selfW, selfH);
        
        self.model = model;
        self.isLooking = NO;
        self.isSelected = NO;
        
    }
    return self;
}

- (void)tap {
    [self setIsLooking:!self.isLooking animated:YES];
    !self.tapBlock ? : self.tapBlock(self);
}

- (void)setModel:(WTVRedPackageRainDogModel *)model {
    _model = model;
    if (model) {
        if (_isPhoneLogin) {
            [self.frontImageView jp_setPictureWithURL:[NSURL URLWithString:model.image] placeholderImage:nil];
            [self.backImageView jp_setPictureWithURL:[NSURL URLWithString:model.image2] placeholderImage:nil];
        } else {
            self.frontImageView.image = [UIImage imageNamed:model.image];
            self.backImageView.image = nil;
        }
    } else {
        self.frontImageView.image = nil;
        self.backImageView.image = nil;
    }
    _selectedLabel.text = [NSString stringWithFormat:@"已拥有：%zd个", model.count];
    
    self.frontImageView.hidden = self.isLooking;
    self.backImageView.hidden = !self.isLooking;
}

- (void)setIsLooking:(BOOL)isLooking {
    [self setIsLooking:isLooking animated:NO];
}

- (void)setIsLooking:(BOOL)isLooking animated:(BOOL)animated {
    if (self.model.image2.length == 0) {
        _isLooking = NO;
        return;
    }
    _isLooking = isLooking;
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = @"oglFlip";
        transition.subtype = kCATransitionFromLeft;
        [self.contentView.layer addAnimation:transition forKey:@"Flip"];
    }
    self.frontImageView.hidden = isLooking;
    self.backImageView.hidden = !isLooking;
}

- (void)setIsSelected:(BOOL)isSelected {
    if (_isSelected == isSelected) {
        return;
    }
    _isSelected = isSelected;
    self.contentView.layer.borderWidth = isSelected ? 5.0 : 0.0;
    self.selectedView.image = [UIImage imageNamed:(isSelected ? @"me_dog_point_checked" : @"me_dog_point")];
    self.selectedLabel.textColor = isSelected ? JPRGBColor(255, 181, 53) : JPRGBColor(255, 255, 255);
}

@end

