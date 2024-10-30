//
//  WTVRedPackageDogPrizesView.m
//  WoTV
//
//  Created by 周健平 on 2018/1/24.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageDogPrizesView.h"
#import "WTVRedPackageRainManager.h"
#import "UIImageView+JPExtension.h"

@interface WTVRedPackageDogPrizesView ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray<WTVRedPackageDogPrizesCell *> *cells;
@property (nonatomic, assign) CGFloat cellViewMaxY;
@property (nonatomic, weak) UIButton *cashBtn;
@property (nonatomic, weak) UIButton *ruleBtn;
@property (nonatomic, weak) UIView *ruleView;
@end

@implementation WTVRedPackageDogPrizesView

+ (instancetype)dogPrizesView {
    WTVRedPackageDogPrizesView *dpView = [[self alloc] init];
    return dpView;
}

- (instancetype)init {
    if (self = [super init]) {
        
        CGFloat scale = JPScale;
        CGFloat selfW = JPPortraitScreenWidth - 20;
        
        CGFloat w = selfW;
        CGFloat h = 12 * scale;
        CGFloat x = 0;
        CGFloat y = 0;
        
        UILabel *titleLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:h];
            aLabel.textColor = [UIColor whiteColor];
            aLabel.text = @"犬年集萌犬，畅赢iPhone 8！";
            aLabel.frame = CGRectMake(x, y, w, h);
            aLabel;
        });
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        CGFloat baseY = titleLabel.jp_maxY + 10;
        
        self.cells = [NSMutableArray array];
        @jp_weakify(self);
        for (NSInteger i = 0; i < 6; i++) {
            
            WTVRedPackageDogPrizesCell *cell = [[WTVRedPackageDogPrizesCell alloc] initWithModel:nil];
            cell.tapBlock = ^(WTVRedPackageDogPrizesCell *tapCell) {
                @jp_strongify(self);
                if (!self) return;
                for (WTVRedPackageDogPrizesCell *cell in self.cells) {
                    if (tapCell != cell) {
                        cell.isSelected = NO;
                    } else {
                        cell.isSelected = !cell.isSelected;
                    }
                }
            };
            
            x = i % 3 * (cell.jp_width + 5);
            y = baseY + i / 3 * (cell.jp_height + 10);
            cell.jp_origin = CGPointMake(x, y);
            
            [self addSubview:cell];
            [self.cells addObject:cell];
            
            if (i == 5) {
                self.cellViewMaxY = cell.jp_maxY;
            }
        }
        
        UIButton *cashBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont systemFontOfSize:12 * scale];
            [btn setImage:[UIImage imageNamed:@"me_btn_exchange"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(cash) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            btn.layer.masksToBounds = YES;
            btn;
        });
        w = 201 * scale;
        h = 40 * scale;
        x = (selfW - w) * 0.5;
        y = self.cells.lastObject.jp_maxY + 25 * scale;
        cashBtn.frame = CGRectMake(x, y, w, h);
        [self addSubview:cashBtn];
        self.cashBtn = cashBtn;
        
        UILabel *ruleLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:10 * scale];
            aLabel.textColor = JPRGBColor(79, 49, 37);
            aLabel.text = @"活动时间内中仅享有1次萌犬兑换奖品的机会哦！";
            [aLabel sizeToFit];
            aLabel.jp_height = aLabel.font.pointSize;
            aLabel;
        });
        
        UIButton *ruleBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = ruleLabel.font;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitle:@"活动规则>>" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(lookRule) forControlEvents:UIControlEventTouchUpInside];
            [btn sizeToFit];
            btn.jp_x = ruleLabel.jp_maxX;
            btn.jp_height = ruleLabel.jp_height;
            btn;
        });
        
        w = ruleLabel.jp_width + ruleBtn.jp_width;
        h = ruleLabel.jp_height;
        x = (selfW - w) * 0.5;
        y = cashBtn.jp_maxY + 15 * scale;
        UIView *ruleView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [ruleView addSubview:ruleLabel];
        [ruleView addSubview:ruleBtn];
        self.ruleBtn = ruleBtn;
        
        [self addSubview:ruleView];
        self.ruleView = ruleView;
        
        self.jp_size = CGSizeMake(selfW, ruleView.jp_maxY);
        
    }
    return self;
}

- (void)cash {
    if (self.exchangedDogPrizeModel) {
        return;
    }
    if (self.btnDidClick) {
        WTVRedPackageRainPrizeModel *model;
        for (WTVRedPackageDogPrizesCell *cell in self.cells) {
            if (cell.isSelected) {
                model = cell.model;
                break;
            }
        }
        self.btnDidClick(model);
    }
}

- (void)lookRule {
    !self.lookRuleBlock ? : self.lookRuleBlock();
}

- (void)setupModels:(NSArray<WTVRedPackageRainPrizeModel *> *)models animateBlock:(void (^)(CGFloat, void (^)(void)))animateBlock {
    
    NSInteger cellCount = self.cells.count;
    NSInteger count = models.count;
    
    NSMutableArray *showCells = [NSMutableArray array];
    NSMutableArray *hideCells = [NSMutableArray array];
    CGFloat cellViewMaxY = self.cellViewMaxY;
    for (NSInteger i = 0; i < cellCount; i++) {
        WTVRedPackageDogPrizesCell *cell = self.cells[i];
        if (i < count) {
            if (cell.alpha == 0) {
                [showCells addObject:cell];
            }
            cell.model = models[i];
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
        animateBlock(0, nil);
        return;
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
            self.cashBtn.jp_y += diffH;
            self.ruleView.jp_y += diffH;
            self.jp_height += diffH;
        };
        
        animateBlock(diffH, viewChangBlock);
    }
    
}

- (void)updateModels:(NSArray<WTVRedPackageRainPrizeModel *> *)models {
    NSInteger cellCount = self.cells.count;
    NSInteger count = models.count;
    NSMutableArray *showCells = [NSMutableArray array];
    NSMutableArray *hideCells = [NSMutableArray array];
    for (NSInteger i = 0; i < cellCount; i++) {
        WTVRedPackageDogPrizesCell *cell = self.cells[i];
        if (i < count) {
            if (cell.alpha == 0) {
                [showCells addObject:cell];
            }
            cell.model = models[i];
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
}

- (void)updateConforming:(NSInteger)dogTypeCount {
    for (WTVRedPackageDogPrizesCell *cell in self.cells) {
        cell.isConforming = dogTypeCount >= cell.model.presentNeed;
    }
}

- (void)setExchangedDogPrizeModel:(WTVRedPackageRainPrizeModel *)exchangedDogPrizeModel {
    _exchangedDogPrizeModel = exchangedDogPrizeModel;
    BOOL isCanExchanged = NO;
    if (exchangedDogPrizeModel) {
        [self.cashBtn setImage:nil forState:UIControlStateNormal];
        [self.cashBtn setTitle:[NSString stringWithFormat:@"已兑换：%@", exchangedDogPrizeModel.name] forState:UIControlStateNormal];
        self.cashBtn.backgroundColor = JPRGBColor(254, 84, 101);
        self.cashBtn.layer.borderWidth = 1;
        self.cashBtn.layer.cornerRadius = self.cashBtn.jp_height * 0.5;
    } else {
        isCanExchanged = YES;
        [self.cashBtn setImage:[UIImage imageNamed:@"me_btn_exchange"] forState:UIControlStateNormal];
        [self.cashBtn setTitle:nil forState:UIControlStateNormal];
        self.cashBtn.backgroundColor = [UIColor clearColor];
        self.cashBtn.layer.cornerRadius = 0;
        self.cashBtn.layer.cornerRadius = 0;
    }
    for (WTVRedPackageDogPrizesCell *cell in self.cells) {
        cell.isCanExchanged = isCanExchanged;
    }
}

@end

@interface WTVRedPackageDogPrizesCell ()
@property (nonatomic, weak) UILabel *conditionLabel;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) CALayer *imageLayer;
@end

@implementation WTVRedPackageDogPrizesCell

- (instancetype)initWithModel:(WTVRedPackageRainPrizeModel *)model {
    if (self = [super init]) {
        
        CGFloat scale = JPScale;
        
        CGFloat w = (JPPortraitScreenWidth - 20 - 10) / 3.0;
        CGFloat h = w * (150.0 / 115.0);
        CGFloat x = 0;
        CGFloat y = 0;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.layer.borderColor = JPRGBColor(255, 181, 53).CGColor;
        imageView.layer.cornerRadius = 8.0;
        imageView.layer.borderWidth = 0.0;
        imageView.layer.masksToBounds = YES;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        CALayer *imageLayer = [CALayer layer];
        imageLayer.frame = imageView.bounds;
        imageLayer.backgroundColor = JPRGBColor(254, 74, 97).CGColor;
        [imageView.layer addSublayer:imageLayer];
        self.imageLayer = imageLayer;
        
        h = 21 * scale;
        y = imageView.jp_height - h;
        UILabel *conditionLabel = ({
            UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:15 * scale];
            aLabel.textColor = [UIColor whiteColor];
            aLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            aLabel;
        });
        [imageView addSubview:conditionLabel];
        self.conditionLabel = conditionLabel;
 
        h = 11 * scale;
        y = imageView.jp_maxY + 5;
        UILabel *contentLabel = ({
            UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:h];
            aLabel.textColor = [UIColor whiteColor];
            aLabel;
        });
        [self addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        self.jp_size = CGSizeMake(w, contentLabel.jp_maxY);
        
        self.model = model;
        self.isSelected = NO;
        self.isConforming = YES;
        _isCanExchanged = YES;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
        
    }
    return self;
}

- (void)tap {
    if (self.isConforming) {
        !self.tapBlock ? : self.tapBlock(self);
    }
}

- (void)setModel:(WTVRedPackageRainPrizeModel *)model {
    _model = model;
    if (model) {
        [self.imageView jp_setPictureWithURL:[NSURL URLWithString:model.image] placeholderImage:nil];
        NSString *condition = @"";
        switch (model.presentNeed) {
            case 1:
                condition = @"集齐一大神犬";
                break;
            case 2:
                condition = @"集齐二大神犬";
                break;
            case 3:
                condition = @"集齐三大神犬";
                break;
            case 4:
                condition = @"集齐四大神犬";
                break;
            case 5:
                condition = @"集齐五大神犬";
                break;
            case 6:
                condition = @"集齐六大神犬";
                break;
            default:
                break;
        }
        self.conditionLabel.text = condition;
    } else {
        self.imageView.image = [UIImage imageNamed:@""];
        self.conditionLabel.text = @"";
    }
    
    if (self.isConforming) {
        self.contentLabel.text = [NSString stringWithFormat:@"可兑换:剩余%zd张", model.remain];
    } else {
        self.contentLabel.text = [NSString stringWithFormat:@"剩余%zd张", model.remain];
    }
    
}

- (void)setIsCanExchanged:(BOOL)isCanExchanged {
    _isCanExchanged = isCanExchanged;
    if (!isCanExchanged && self.isSelected) {
        _isSelected = NO;
        self.imageView.layer.borderWidth = 0.0;
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    if (!self.isConforming) {
        _isSelected = NO;
        self.imageView.layer.borderWidth = 0.0;
        return;
    }
    if (!self.isCanExchanged) {
        _isSelected = NO;
        self.imageView.layer.borderWidth = 0.0;
        [JPProgressHUD showInfoWithStatus:@"您已兑换过萌犬奖品了~" userInteractionEnabled:YES];
        return;
    }
    _isSelected = isSelected;
    self.imageView.layer.borderWidth = isSelected ? 3.0 : 0.0;
}

- (void)setIsConforming:(BOOL)isConforming {
    _isConforming = isConforming;
    if (!isConforming && self.isSelected) {
        _isSelected = NO;
        self.imageView.layer.borderWidth = 0.0;
    }
    self.imageLayer.opacity = isConforming ? 0.0 : 0.4;
    self.conditionLabel.hidden = isConforming;
    
    if (isConforming) {
        self.contentLabel.text = [NSString stringWithFormat:@"可兑换:剩余%zd张", self.model.remain];
    } else {
        self.contentLabel.text = [NSString stringWithFormat:@"剩余%zd张", self.model.remain];
    }
}

@end

