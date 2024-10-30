//
//  WTVRedPackageTrafficPrizesView.m
//  WoTV
//
//  Created by 周健平 on 2018/1/24.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageTrafficPrizesView.h"
#import "WTVRedPackageRainManager.h"

@interface WTVRedPackageTrafficPrizesView ()

@property (nonatomic, weak) UIImageView *topImageView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIImageView *titleView;

@property (nonatomic, weak) WTVRedPackageTrafficPrizesCell *midCell;

@property (nonatomic, weak) UIButton *loginBtn;

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *bottomLabel;
@property (nonatomic, weak) UIButton *bottomBtn;

@property (nonatomic, weak) UIView *cashView;

@end

@implementation WTVRedPackageTrafficPrizesView

+ (instancetype)trafficPrizesView {
    WTVRedPackageTrafficPrizesView *tpView = [[self alloc] init];
    return tpView;
}

- (instancetype)init {
    if (self = [super init]) {
        
        CGFloat scale = JPScale;
        CGFloat selfW = JPPortraitScreenWidth - 10;
        
        UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, selfW, 36 * scale)];
        topImageView.image = [UIImage imageNamed:@"me_bg_flow_top"];
        [self addSubview:topImageView];
        self.topImageView = topImageView;
        
        CGFloat x = 10;
        CGFloat y = topImageView.jp_maxY - 15;
        CGFloat w = selfW - 2 * x;
        CGFloat h = 300;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
        self.contentView = contentView;
        
        w = 153.0 * scale;
        h = 37.0 * scale;
        x = (contentView.jp_width - w) * 0.5;
        y = 5;
        UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        titleView.image = [UIImage imageNamed:@"me_webcopy_flow_prize"];
        [contentView addSubview:titleView];
        self.titleView = titleView;
        
        WTVRedPackageTrafficPrizesCell *getCell = [[WTVRedPackageTrafficPrizesCell alloc] initWithImageName:@"me_bg_flow_get" isOnTop:YES];
        x = contentView.jp_width * 0.5;
        y = titleView.jp_maxY + 20 * scale + getCell.jp_height * 0.5;
        getCell.layer.position = CGPointMake(x, y);
        [contentView addSubview:getCell];
        self.getCell = getCell;
        self.midCell = getCell;
        
        WTVRedPackageTrafficPrizesCell *exchangedCell = [[WTVRedPackageTrafficPrizesCell alloc] initWithImageName:@"me_bg_flow_exchanged" isOnTop:NO];
        x = contentView.jp_width * 0.5 - (exchangedCell.jp_width - 20);
        exchangedCell.layer.position = CGPointMake(x, y);
        [contentView addSubview:exchangedCell];
        self.exchangedCell = exchangedCell;
        
        WTVRedPackageTrafficPrizesCell *surplusCell = [[WTVRedPackageTrafficPrizesCell alloc] initWithImageName:@"me_bg_flow_surplus" isOnTop:NO];
        x = contentView.jp_width * 0.5 + (surplusCell.jp_width - 20);
        surplusCell.layer.position = CGPointMake(x, y);
        [contentView addSubview:surplusCell];
        self.surplusCell = surplusCell;
        
        __weak typeof(self) wSelf = self;
        getCell.tapBlock = ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            [sSelf cellDidTap:sSelf.getCell];
        };
        
        exchangedCell.tapBlock = ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            [sSelf cellDidTap:sSelf.exchangedCell];
        };
        
        surplusCell.tapBlock = ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            [sSelf cellDidTap:sSelf.surplusCell];
        };
        
        BOOL isPhoneLogin = RPManager.isPhoneLogin;
        
        if (isPhoneLogin) {
            UIFont *font = [UIFont systemFontOfSize:12];
            CGFloat x = 10.0;
            CGFloat y = self.midCell.jp_maxY + 18 * scale;
            CGFloat w = contentView.jp_width - 2 * x;
            CGFloat h = font.pointSize;
            UIView *cashView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
            [contentView addSubview:cashView];
            self.cashView = cashView;
            
            UILabel *cashLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.textAlignment = NSTextAlignmentCenter;
                aLabel.font = font;
                aLabel.textColor = JPRGBColor(254, 74, 97);
                aLabel.text = @"可兑换";
                [aLabel sizeToFit];
                x = (cashView.jp_width - aLabel.jp_width) * 0.5;
                aLabel.jp_x = x;
                aLabel.jp_height = font.pointSize;
                aLabel;
            });
            [cashView addSubview:cashLabel];
            
            w = cashLabel.jp_x - 10;
            h = 5.0;
            y = (cashView.jp_height - h) * 0.5;
            UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, w, h)];
            leftView.image = [UIImage imageNamed:@"me_flow_line_left"];
            [cashView addSubview:leftView];
            
            UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(cashLabel.jp_maxX + 10, y, w, h)];
            rightView.image = [UIImage imageNamed:@"me_flow_line_right"];
            [cashView addSubview:rightView];
            
            w = cashView.jp_width;
            x = 10;
            y = cashView.jp_maxY + 23 * scale;
            WTVRedPackageTrafficView *trafficView = [[WTVRedPackageTrafficView alloc] initWithWidth:w];
            trafficView.jp_origin = CGPointMake(x, y);
            [contentView addSubview:trafficView];
            self.trafficView = trafficView;
        }
        
        UIButton *loginBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            NSString *imageName = isPhoneLogin ?  @"me_btn_exchange" : @"me_btn_login";
            [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(goLogin) forControlEvents:UIControlEventTouchUpInside];
            CGFloat w = 200.0 * scale;
            CGFloat h = 40.0 * scale;
            CGFloat x = (contentView.jp_width - w) * 0.5;
            CGFloat y = (isPhoneLogin ? self.trafficView.jp_maxY : self.midCell.jp_maxY) + 24 * scale;
            btn.frame = CGRectMake(x, y, w, h);
            btn;
        });
        [contentView addSubview:loginBtn];
        self.loginBtn = loginBtn;
        
        UILabel *bottomLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.font = [UIFont systemFontOfSize:10 * scale];
            aLabel.textColor = JPRGBColor(79, 49, 37);
            aLabel.text = @"单一用户省内流量、全国流量分别可兑换5次，查看";
            [aLabel sizeToFit];
            aLabel;
        });
        
        UIButton *bottomBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.titleLabel.font = bottomLabel.font;
            [btn setTitle:@"活动规则>>" forState:UIControlStateNormal];
            [btn setTitleColor:JPRGBColor(254, 74, 97) forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(lookRule) forControlEvents:UIControlEventTouchUpInside];
            [btn sizeToFit];
            btn.jp_height = bottomLabel.jp_height;
            btn.jp_x = bottomLabel.jp_width;
            btn;
        });
        
        w = bottomLabel.jp_width + bottomBtn.jp_width;
        h = bottomLabel.jp_height;
        x = (contentView.jp_width - w) * 0.5;
        y = loginBtn.jp_maxY + 16 * scale;
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [contentView addSubview:bottomView];
        self.bottomView = bottomView;
        
        [bottomView addSubview:bottomLabel];
        self.bottomLabel = bottomLabel;
        
        [bottomView addSubview:bottomBtn];
        self.bottomBtn = bottomBtn;
        
        contentView.jp_height = bottomView.jp_maxY + 18.0 * scale;
        
        self.jp_size = CGSizeMake(selfW, contentView.jp_maxY);
        
        if (self.trafficView) {
            @jp_weakify(self);
            self.trafficView.updateHandle = ^(CGFloat diffH) {
                @jp_strongify(self);
                if (!self) return;
                self.contentView.jp_height += diffH;
                self.loginBtn.jp_y += diffH;
                self.bottomView.jp_y += diffH;
            };
        }
    }
    return self;
}

- (void)goLogin {
    if (self.btnDidClick) {
        WTVRedPackageRainPrizeModel *model;
        for (WTVRedPackageTrafficCell *cell in self.trafficView.cells) {
            if (cell.isSelected) {
                model = cell.model;
                break;
            }
        }
        self.btnDidClick(model);
    }
}

- (void)lookRule {
    NSLog(@"去看活动规则");
    !self.lookRuleBlock ? : self.lookRuleBlock();
}

- (void)cellDidTap:(WTVRedPackageTrafficPrizesCell *)cell {
    if (self.midCell == cell || !self.midCell) {
        return;
    }
    
    self.userInteractionEnabled = NO;
    
    WTVRedPackageTrafficPrizesCell *midCell = self.midCell;
    self.midCell = nil;
    
    CGPoint midPos = midCell.layer.position;
    CGFloat midZPos = 1;
    CGPoint midScaleXY = CGPointMake(1, 1);
    CGFloat midShadowOpacity = 0.2;
    UIColor *midBgColor = [UIColor colorWithCGColor:midCell.layer.backgroundColor];
    UIColor *midTrafficColor = JPRGBColor(254, 74, 97);
    
    CGPoint pos = cell.layer.position;
    CGFloat zPos = 0;
    CGPoint scaleXY = CGPointMake(0.9, 0.9);
    CGFloat shadowOpacity = 0;
    UIColor *bgColor = [UIColor colorWithCGColor:cell.layer.backgroundColor];
    UIColor *trafficColor = JPRGBColor(79, 49, 37);
    
    NSTimeInterval duration = 0.35;
    NSTimeInterval beginTime = 0;
    
    [midCell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerPosition toValue:@(pos) duration:duration beginTime:beginTime completionBlock:nil];
    [midCell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerZPosition toValue:@(zPos) duration:duration beginTime:duration * 0.5 completionBlock:nil];
    [midCell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(scaleXY) duration:duration beginTime:beginTime completionBlock:nil];
    [midCell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerShadowOpacity toValue:@(shadowOpacity) duration:duration beginTime:beginTime completionBlock:nil];
    [midCell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerBackgroundColor toValue:bgColor duration:duration beginTime:beginTime completionBlock:nil];
    [midCell.countryTrafficLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPLabelTextColor toValue:trafficColor duration:duration beginTime:beginTime completionBlock:nil];
    [midCell.provinceTrafficLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPLabelTextColor toValue:trafficColor duration:duration beginTime:beginTime completionBlock:nil];
    
    [cell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerPosition toValue:@(midPos) duration:duration beginTime:beginTime completionBlock:nil];
    [cell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerZPosition toValue:@(midZPos) duration:duration beginTime:duration * 0.5 completionBlock:nil];
    [cell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(midScaleXY) duration:duration beginTime:beginTime completionBlock:nil];
    [cell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerShadowOpacity toValue:@(midShadowOpacity) duration:duration beginTime:beginTime completionBlock:nil];
    [cell.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerBackgroundColor toValue:midBgColor duration:duration beginTime:beginTime completionBlock:^(POPAnimation *anim, BOOL finished) {
        self.userInteractionEnabled = YES;
        self.midCell = cell;
    }];
    [cell.countryTrafficLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPLabelTextColor toValue:midTrafficColor duration:duration beginTime:beginTime completionBlock:nil];
    [cell.provinceTrafficLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPLabelTextColor  toValue:midTrafficColor duration:duration beginTime:beginTime completionBlock:nil];
}

@end


@interface WTVRedPackageTrafficPrizesCell ()
@property (nonatomic, weak) UIView *noTrafficView;
@property (nonatomic, weak) UILabel *noTrafficLabel;
@property (nonatomic, weak) UILabel *countryLabel;
@property (nonatomic, weak) UILabel *provinceLabel;
@end

@implementation WTVRedPackageTrafficPrizesCell

- (UIView *)noTrafficView {
    if (!_noTrafficView) {
        CGFloat scale = JPScale;
        CGFloat x = 13 * scale;
        CGFloat w = self.jp_width - 2 * x;
        CGFloat h = w * (25.0 / 100.0);
        CGFloat y = self.jp_height - h - 15 * scale;
        UIView *noTrafficView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        
        CAGradientLayer *gLayer = [CAGradientLayer layer];
        gLayer.frame = noTrafficView.bounds;
        gLayer.startPoint = CGPointMake(0, 0.5);
        gLayer.endPoint = CGPointMake(1, 0.5);
        gLayer.locations = @[@0, @1];
        gLayer.colors = @[(id)JPRGBColor(254, 133, 125).CGColor,
                          (id)JPRGBColor(254, 67, 93).CGColor];
        gLayer.cornerRadius = noTrafficView.jp_height * 0.5;
        gLayer.masksToBounds = YES;
        [noTrafficView.layer addSublayer:gLayer];
        
        UILabel *noTrafficLabel = [[UILabel alloc] initWithFrame:noTrafficView.bounds];
        noTrafficLabel.font = [UIFont systemFontOfSize:15 * scale];
        noTrafficLabel.textAlignment = NSTextAlignmentCenter;
        noTrafficLabel.textColor = [UIColor whiteColor];
        noTrafficLabel.text = @"— —流量";
        [noTrafficView addSubview:noTrafficLabel];
        _noTrafficLabel = noTrafficLabel;
        
        [self addSubview:noTrafficView];
        _noTrafficView = noTrafficView;
    }
    return _noTrafficView;
}

+ (CGFloat)viewWidth {
    return 125.0 * JPScale;
}

+ (CGFloat)viewHeight:(BOOL)isPhoneLogin {
    return (isPhoneLogin ? 173.0 : 160.0) * JPScale;
}

- (instancetype)initWithImageName:(NSString *)imageName isOnTop:(BOOL)isOnTop {
    
    BOOL scale = JPScale;
    BOOL isPhoneLogin = RPManager.isPhoneLogin;
    CGFloat viewWidth = WTVRedPackageTrafficPrizesCell.viewWidth;
    CGFloat viewHeight = [WTVRedPackageTrafficPrizesCell viewHeight:isPhoneLogin];
    
    if (self = [super initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)]) {
        
        CGFloat x = 3;
        CGFloat y = 3;
        CGFloat w = viewWidth - 2 * x;
        CGFloat h = w * (109.0 / 120.0);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        imageView.image = [UIImage imageNamed:imageName];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        BOOL isPhoneLogin = RPManager.isPhoneLogin;
        if (!isPhoneLogin) {
            [self noTrafficView];
        } else {
            UIFont *font12 = [UIFont systemFontOfSize:12 * scale];
            UIFont *font15 = [UIFont systemFontOfSize:15 * scale - 1];
            
            x = 13 * scale;
            y = imageView.jp_maxY + 15 * scale;
            
            if (JPPortraitScreenWidth < 375.0) {
                font12 = [UIFont systemFontOfSize:10];
                font15 = [UIFont systemFontOfSize:12];
                x = 10;
                y = imageView.jp_maxY + 10;
            }
            
            UILabel *countryLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.textAlignment = NSTextAlignmentCenter;
                aLabel.font = font12;
                aLabel.textColor = JPRGBColor(79, 49, 37);
                aLabel.text = @"全国流量";
                [aLabel sizeToFit];
                aLabel.frame = CGRectMake(x, y, aLabel.jp_width, font12.pointSize);
                aLabel;
            });
            
            y = countryLabel.jp_maxY + 10 * scale;
            UILabel *provinceLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.textAlignment = NSTextAlignmentCenter;
                aLabel.font = font12;
                aLabel.textColor = JPRGBColor(79, 49, 37);
                aLabel.text = @"省内流量";
                [aLabel sizeToFit];
                aLabel.frame = CGRectMake(x, y, aLabel.jp_width, font12.pointSize);
                aLabel;
            });
            
            x = countryLabel.jp_maxX + 10 * scale;
            if (JPPortraitScreenWidth < 375.0) {
                x = countryLabel.jp_maxX + 8;
            }
            y = countryLabel.jp_y + (countryLabel.jp_height - font15.pointSize) * 0.5;
            UILabel *countryTrafficLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.textAlignment = NSTextAlignmentCenter;
                aLabel.font = font15;
                aLabel.textColor = isOnTop ? JPRGBColor(254, 74, 97) : JPRGBColor(79, 49, 37);
                aLabel.text = @"9999M";
                [aLabel sizeToFit];
                aLabel.text = @"";
                aLabel.frame = CGRectMake(x, y, aLabel.jp_width, font15.pointSize);
                aLabel;
            });
            
            y = provinceLabel.jp_y + (provinceLabel.jp_height - font15.pointSize) * 0.5;
            UILabel *provinceTrafficLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.textAlignment = NSTextAlignmentCenter;
                aLabel.font = font15;
                aLabel.textColor = isOnTop ? JPRGBColor(254, 74, 97) : JPRGBColor(79, 49, 37);
                aLabel.text = @"9999M";
                [aLabel sizeToFit];
                aLabel.text = @"";
                aLabel.frame = CGRectMake(x, y, aLabel.jp_width, font15.pointSize);
                aLabel;
            });
            
            [self addSubview:countryLabel];
            self.countryLabel = countryLabel;
            
            [self addSubview:provinceLabel];
            self.provinceLabel = provinceLabel;
            
            [self addSubview:countryTrafficLabel];
            self.countryTrafficLabel = countryTrafficLabel;
            
            [self addSubview:provinceTrafficLabel];
            self.provinceTrafficLabel = provinceTrafficLabel;
        }
        
        self.layer.cornerRadius = 6;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 5.0;
        
        if (isOnTop) {
            self.layer.backgroundColor = [UIColor whiteColor].CGColor;
            self.layer.shadowOpacity = 0.2;
            self.layer.zPosition = 1;
        } else {
            self.layer.backgroundColor = JPRGBColor(242, 242, 242).CGColor;
            self.layer.shadowOpacity = 0;
            self.layer.zPosition = 0;
            self.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1);
        }
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)tapGR {
    !self.tapBlock ? : self.tapBlock();
}

@end

@interface WTVRedPackageTrafficView ()

@end

@implementation WTVRedPackageTrafficView

- (NSMutableArray<WTVRedPackageTrafficCell *> *)cells {
    if (!_cells) {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (instancetype)initWithWidth:(CGFloat)width {
    if (self = [super init]) {
        self.jp_size = CGSizeMake(width, 50);
    }
    return self;
}

- (void)setupModels:(NSArray<WTVRedPackageRainPrizeModel *> *)models animateBlock:(void (^)(CGFloat, void (^)(void)))animateBlock {
    NSInteger count = models.count;
    if (count > 0) {
        CGFloat scale = JPScale;
        CGFloat horSpace = 10 * scale;
        CGFloat verSpace = 20 * scale;
        CGFloat w = (self.jp_width - horSpace * 3) / 4.0;
        CGFloat h = 14 * scale;
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat selfH = self.jp_height;
        for (NSInteger i = 0; i < count; i++) {
            x = i % 4 * (w + horSpace);
            y = i / 4 * (h + verSpace);
            NSLog(@"%zd -- %.2lf", i , x);
            WTVRedPackageRainPrizeModel *model = models[i];
            WTVRedPackageTrafficCell *cell = [WTVRedPackageTrafficCell trafficCellWithFrame:CGRectMake(x, y, w, h) model:model target:self action:@selector(cellDidClick:)];
            cell.alpha = 0;
            [self addSubview:cell];
            [self.cells addObject:cell];
            if (i == count - 1) {
                selfH = cell.jp_maxY;
            }
        }
        
        if (animateBlock) {
            CGFloat diffH = selfH - self.jp_height;
            
            void (^viewChangBlock)(void) = ^{
                !self.updateHandle ? : self.updateHandle(diffH);
                for (WTVRedPackageTrafficCell *cell in self.cells) {
                    cell.alpha = 1;
                }
                self.jp_size = CGSizeMake(self.jp_width, selfH);
            };
            
            animateBlock(diffH, viewChangBlock);
        }
        
    }
}

- (void)updateModels:(NSArray<WTVRedPackageRainPrizeModel *> *)models {
    NSInteger cellCount = self.cells.count;
    NSInteger count = models.count;
    NSMutableArray *showCells = [NSMutableArray array];
    NSMutableArray *hideCells = [NSMutableArray array];
    for (NSInteger i = 0; i < cellCount; i++) {
        WTVRedPackageTrafficCell *cell = self.cells[i];
        cell.selected = NO;
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

- (void)updateSurplusPtCount:(NSInteger)surplusPtCount surplusDtCount:(NSInteger)surplusDtCount {
    for (WTVRedPackageTrafficCell *cell in self.cells) {
        if (cell.model.type == WTVProvinceTrafficPrizeType) {
            cell.enabled = surplusPtCount >= cell.model.presentNeed;
        } else if (cell.model.type == WTVDomesticTrafficPrizeType) {
            cell.enabled = surplusDtCount >= cell.model.presentNeed;
        }
    }
}

- (void)cellDidClick:(WTVRedPackageTrafficCell *)clickCell {
    for (WTVRedPackageTrafficCell *cell in self.cells) {
        if (clickCell != cell) {
            cell.selected = NO;
        } else {
            cell.selected = !cell.selected;
        }
    }
}

@end

@interface WTVRedPackageTrafficCell ()

@end

@implementation WTVRedPackageTrafficCell

+ (instancetype)trafficCellWithFrame:(CGRect)frame model:(WTVRedPackageRainPrizeModel *)model target:(id)target action:(SEL)action {
    WTVRedPackageTrafficCell *cell = [self buttonWithType:UIButtonTypeCustom];
    cell.adjustsImageWhenHighlighted = NO;
    cell.frame = frame;
    cell.model = model;
    cell.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    cell.titleEdgeInsets = UIEdgeInsetsMake(0, 5 * JPScale, 0, 0);
    cell.titleLabel.font = [UIFont systemFontOfSize:frame.size.height - 6];
    [cell setImage:[UIImage imageNamed:@"me_flow_icon_point"] forState:UIControlStateNormal];
    [cell setImage:[UIImage imageNamed:@"me_flow_icon_checked"] forState:UIControlStateSelected];
    [cell setImage:[UIImage imageNamed:@"me_flow_icon_point_no"] forState:UIControlStateDisabled];
    [cell setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cell setTitleColor:JPRGBColor(254, 74, 97) forState:UIControlStateSelected];
    [cell setTitleColor:JPRGBColor(150, 150, 150) forState:UIControlStateDisabled];
    [cell addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)setModel:(WTVRedPackageRainPrizeModel *)model {
    _model = model;
    [self setTitle:model.name forState:UIControlStateNormal];
}

@end
