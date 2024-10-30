//
//  WTVRedPackageRainViewController.m
//  WoTV
//
//  Created by 周健平 on 2018/1/18.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageRainViewController.h"
#import "WTVRedPackageRainUIBuildTool.h"
#import "WTVRedPackageRainView.h"
#import "WTVRedPackageRainResultView.h"
#import "WTVRedPackageRainManager.h"
#import "WTVRedPackageRainRuleView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface WTVRedPackageRainViewController () <WTVRedPackageRainViewDelegate>
@property (nonatomic, weak) CALayer *bgLayer;
@property (nonatomic, weak) UIImageView *topBgView;
@property (nonatomic, weak) UIImageView *bottomBgView;
@property (nonatomic, weak) UIImageView *contentView;
@property (nonatomic, weak) UIImageView *decorateView;
@property (nonatomic, weak) UIImageView *dogView;
@property (nonatomic, weak) UIImageView *luckyBagView;
@property (nonatomic, weak) UIImageView *backwardsView;
@property (nonatomic, weak) UILabel *backwardsLabel;
@property (nonatomic, weak) UIButton *closeBtn;

@property (nonatomic, weak) WTVRedPackageRainView *rprView;

@property (nonatomic, weak) UILabel *rpContentLabel;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UILabel *timerLabel;

@property (nonatomic, weak) WTVRedPackageRainResultView *resultView;

@property (nonatomic, assign) BOOL isShowedContent;
@property (nonatomic, assign) BOOL isShowedBackwards;

@property (nonatomic, copy) void (^dismissHandle)(WTVRedPackageRainScreeningsModel *finishScreeningsModel);

@property (nonatomic, strong) NSMutableArray<WTVRedPackageRainGiftModel *> *gitfModels;
@property (nonatomic, strong) WTVRedPackageRainGiftModel *shareGiftModel;

@property (nonatomic, assign) SystemSoundID bgMusicID;
@end

@implementation WTVRedPackageRainViewController
{
    CGRect _topBgFrame1;
    CGRect _topBgFrame2;
    
    CGRect _bottomBgFrame1;
    CGRect _bottomBgFrame2;
    
    CGRect _decorateFrame1;
    CGRect _decorateFrame2;
    
    CGRect _dogFrame1;
    CGRect _dogFrame2;
    
    CGRect _luckyBagFrame1;
    CGRect _luckyBagFrame2;
    
    CGRect _rprViewFrame;
    
    CGRect _rpContentFrame;
    
    NSInteger _backwardsCount;
    NSInteger _snatchRedPackageBackwardsCount;
    
    NSString *_timeText;
}

- (instancetype)initWithTimeText:(NSString *)timeText dismissHandle:(void (^)(WTVRedPackageRainScreeningsModel *finishScreeningsModel))dismissHandle {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        _timeText = timeText;
        
        self.dismissHandle = dismissHandle;
        
        self.currentScreeningsModel = RPManager.currentScreeningsModel;
        
        self.gitfModels = [self.currentScreeningsModel.gitfModels mutableCopy];
        
        self.shareGiftModel = self.gitfModels.lastObject;
        [self.gitfModels removeLastObject];
    }
    return self;
}

- (UILabel *)timerLabel {
    if (!_timerLabel) {
        UILabel *timerLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:15];
            aLabel.textColor = [UIColor whiteColor];
            aLabel.text = @"10";
            aLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            CGFloat w = 31;
            CGFloat h = 31;
            CGFloat x = self.closeBtn.jp_x - w - 5;
            CGFloat y = self.closeBtn.jp_maxY - h;
            aLabel.frame = CGRectMake(x, y, w, h);
            aLabel.layer.cornerRadius = h * 0.5;
            aLabel.layer.masksToBounds = YES;
            aLabel;
        });
        [self.view addSubview:timerLabel];
        _timerLabel = timerLabel;
    }
    return _timerLabel;
}

#pragma mark - 初始配置

- (void)setupBase {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBackwardsAnimated) name:RedPackageRainStartNotification object:nil];
    
    _backwardsCount = 6;
//    _backwardsCount = 1;
    
    _snatchRedPackageBackwardsCount = 21;
//    _snatchRedPackageBackwardsCount = 1;
    
    CGFloat w = JPPortraitScreenWidth;
    CGFloat h = w * (357.0 / 375.0);
    CGFloat x = 0;
    CGFloat y = 0;
    
    _topBgFrame2 = CGRectMake(x, y, w, h);
    _topBgFrame1 = CGRectMake(x, -h, w, h);
    
    h = JPPortraitScreenWidth * (295.0 / 375.0);
    y = JPPortraitScreenHeight - h;
    _bottomBgFrame2 = CGRectMake(x, y, w, h);
    _bottomBgFrame1 = CGRectMake(x, JPPortraitScreenHeight, w, h);
    
    w = JPPortraitScreenWidth;
    h = JPPortraitScreenWidth * (487.5 / 375.0);
    x = 0;
    y = 15;
    _decorateFrame2 = CGRectMake(x, y, w, h);
    x += w;
    y -= h;
    _decorateFrame1 = CGRectMake(x, y, w, h);
    
    w = JPPortraitScreenWidth * (357.0 / 375.0);
    h = JPPortraitScreenWidth * (226.0 / 357.0);
    x = (JPPortraitScreenWidth - w) * 0.5;
    y = JPPortraitScreenHeight - h;
    _dogFrame2 = CGRectMake(x, y, w, h);
    _dogFrame1 = CGRectMake(x, JPPortraitScreenHeight, w, h);
    
    w = JPPortraitScreenWidth * (291.0 / 375.0);
    h = JPPortraitScreenWidth * (128.0 / 357.0);
    x = (JPPortraitScreenWidth - w) * 0.5;
    y = JPPortraitScreenHeight - h;
    _luckyBagFrame2 = CGRectMake(x, y, w, h);
    y = JPPortraitScreenHeight;
    _luckyBagFrame1 = CGRectMake(x, y, w, h);
    
    
    h = 100 * 5;
    w = sqrt(JPPortraitScreenWidth * JPPortraitScreenWidth * 0.5) + h;
    x = -h;
    y = JPDiffStatusBarH;
    _rprViewFrame = CGRectMake(x, y, w, h);
    
    NSLog(@"%.2lf", sqrt(3 * 3));
    
    w = 100;
    h = 18;
    x = (JPPortraitScreenWidth - w) * 0.5;
    y = _luckyBagFrame2.origin.y - 30;
    _rpContentFrame = CGRectMake(x, y, w, h);
}

- (void)setupSubviews {
    
    self.bgLayer = [WTVRedPackageRainUIBuildTool bgLayerOnView:self.view];
    
    self.topBgView = [WTVRedPackageRainUIBuildTool topBgViewWithFrame:_topBgFrame1 onView:self.view];
    
    self.bottomBgView = [WTVRedPackageRainUIBuildTool bottomBgViewWithFrame:_bottomBgFrame1 onView:self.view];
    
    CGFloat scale = JPScale;
    
    CGFloat w = JPPortraitScreenWidth * (357.0 / 375.0);
    CGFloat h = JPPortraitScreenWidth * (297.5 / 357.0);
    CGFloat x = (JPPortraitScreenWidth - w) * 0.5;
    CGFloat y = 16.0;
    self.contentView = [WTVRedPackageRainUIBuildTool contentViewWithFrame:CGRectMake(x, y, w, h) onView:self.view];
    self.contentView.userInteractionEnabled = YES;
    
    w = 100.0 * scale;
    h = 60.0 * scale;
    x = 79.0 * scale;
    y = 98.0 * scale;
    UILabel *timeTextLabel = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.font = [UIFont boldSystemFontOfSize:23 * scale];
        aLabel.textColor = JPRGBColor(79, 49, 37);
        aLabel.text = _timeText;
        aLabel.frame = CGRectMake(x, y, w, h);
        aLabel;
    });
    [self.contentView addSubview:timeTextLabel];
    
    UIButton *ruleBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"活动规则" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(lookRule) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        btn.jp_x = (self.contentView.jp_width - btn.jp_width) * 0.5;
        btn.jp_y = self.contentView.jp_height - btn.jp_height - 20 * scale;
        CALayer *line = [CALayer layer];
        line.frame = CGRectMake(0, btn.jp_height - 7.5, btn.jp_width, 1);
        line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8].CGColor;
        [btn.layer addSublayer:line];
        btn;
    });
    [self.contentView addSubview:ruleBtn];
    
    self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.contentView.alpha = 0;
    
    w = JPPortraitScreenWidth * (278.0 / 375.0);
    h = JPPortraitScreenWidth * (56.0 / 357.0);
    x = (JPPortraitScreenWidth - w) * 0.5;
    y = 100 * (JPPortraitScreenWidth / 375.0);
    self.backwardsView = [WTVRedPackageRainUIBuildTool backwardsViewWithFrame:CGRectMake(x, y, w, h) onView:self.view];
    self.backwardsView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1);
    self.backwardsView.layer.transform = CATransform3DTranslate(self.backwardsView.layer.transform, 0, 50, 0);
    self.backwardsView.alpha = 0;
    
    self.decorateView = [WTVRedPackageRainUIBuildTool decorateViewWithFrame:_decorateFrame1 onView:self.view];
    
    w = JPPortraitScreenWidth;
    h = 110;
    x = 0;
    y = CGRectGetMaxY(self.backwardsView.frame) + 20;
    self.backwardsLabel = [WTVRedPackageRainUIBuildTool backwardsLabelWithFrame:CGRectMake(x, y, w, h) onView:self.view];
    self.backwardsLabel.layer.transform = CATransform3DMakeScale(0.01, 0.01, 1);
    self.backwardsLabel.alpha = 0;
    
    WTVRedPackageRainView *rprView = [[WTVRedPackageRainView alloc] initWithFrame:_rprViewFrame];
    rprView.userInteractionEnabled = NO;
    rprView.delegate = self;
    [self.view addSubview:rprView];
    self.rprView = rprView;
    rprView.layer.anchorPoint = CGPointMake(_rprViewFrame.size.height / _rprViewFrame.size.width, 0);
    rprView.layer.position = CGPointMake(50, 50);
    rprView.layer.transform = CATransform3DMakeRotation(-M_PI * 0.25, 0, 0, 1);
    
    self.dogView = [WTVRedPackageRainUIBuildTool dogViewWithFrame:_dogFrame1 onView:self.view];
    self.luckyBagView = [WTVRedPackageRainUIBuildTool luckyBagViewWithFrame:_luckyBagFrame1 onView:self.view];
    
    self.closeBtn = [WTVRedPackageRainUIBuildTool closeBtnOnView:self.view];
    [self.closeBtn addTarget:self action:@selector(closeAnimated) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self setupBase];
    [self setupSubviews];
    
}

- (void)dealloc {
    NSLog(@"抢红包雨控制器死了");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTimer];
}

#pragma mark - 查看活动规则

- (void)lookRule {
    [WTVRedPackageRainRuleView showRuleViewOnView:self.view];
}

#pragma mark - 定时器

- (void)addTimer {
    [self removeTimer];
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(snatchRedPackageBackwards) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)snatchRedPackageBackwards {
    [self beginRedPackageRain];
    _snatchRedPackageBackwardsCount -= 1;
    
    if (_snatchRedPackageBackwardsCount <= 0) {
        [self removeTimer];
        [self stopSnatchRedPackage];
        return;
    }
    
    self.timerLabel.text = [NSString stringWithFormat:@"%zd", _snatchRedPackageBackwardsCount];
}

#pragma mark - 出场动画

- (void)showBaseAnimated {
    NSTimeInterval duration = 0.35; // 0.35
    NSTimeInterval beginTime = 0.0;
    
    [self.bgLayer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerBackgroundColor toValue:[UIColor colorWithWhite:1.0 alpha:0.8] duration:duration beginTime:beginTime completionBlock:nil];
    
    [self.topBgView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_topBgFrame2) duration:duration beginTime:beginTime completionBlock:nil];
    [self.bottomBgView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_bottomBgFrame2) duration:duration beginTime:beginTime completionBlock:nil];
    
    CGRect frame = self.closeBtn.frame;
    frame.origin.y = 0;
    [self.closeBtn jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(frame) duration:duration beginTime:beginTime completionBlock:nil];
    
    [self.dogView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_dogFrame2) duration:duration beginTime:beginTime completionBlock:nil];
    [self.luckyBagView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_luckyBagFrame2) duration:duration beginTime:beginTime completionBlock:nil];
    
    [self.decorateView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_decorateFrame2) duration:0.7 beginTime:0.2 completionBlock:nil];
}

- (void)showTrailerAnimated {
    
    [self showBaseAnimated];
    
    self.contentView.alpha = 1;
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    anim.springSpeed = 10;
    anim.springBounciness = 10;
    anim.beginTime = CACurrentMediaTime() + 0.3;
    anim.toValue = @(CGPointMake(1, 1));
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        self.isShowedContent = YES;
    };
    [self.contentView pop_addAnimation:anim forKey:@"ScaleXY"];
}

- (void)showBackwardsAnimated {
    for (UIView *subview in self.view.subviews) {
        [subview pop_removeAllAnimations];
    }
    
    if (!self.isShowedContent) {
        [self showBaseAnimated];
    } else {
        [self.contentView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:0.3 completionBlock:nil];
    }
    
    NSTimeInterval duration = 1.0; // 1.0
    NSTimeInterval beginTime = 0.3;
    
    [self.backwardsView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@1 duration:duration beginTime:beginTime completionBlock:nil];
    [self.backwardsView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(1, 1)) duration:duration beginTime:beginTime completionBlock:nil];
    [self.backwardsView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerTranslationY toValue:@0 duration:duration beginTime:beginTime completionBlock:nil];
    
    // 1.0
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backwardsLabel.alpha = 1;
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        anim.springSpeed = 10;
        anim.springBounciness = 10;
        anim.toValue = @(CGPointMake(1, 1));
        anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            self.isShowedContent = YES;
            self.isShowedBackwards = YES;
            [self beginBackwards];
        };
        [self.backwardsLabel.layer pop_addAnimation:anim forKey:@"ScaleXY"];
    });
    
}

- (void)beginBackwards {
    _backwardsCount -= 1;
    if (_backwardsCount <= 0) {
        [self showRedPackageRain];
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.backwardsLabel cache:YES];
        self.backwardsLabel.text = [NSString stringWithFormat:@"%zd", self->_backwardsCount];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self beginBackwards];
    });
}

- (void)showRedPackageRain {
    NSTimeInterval duration = 0.35;
    NSTimeInterval beginTime = 0;
    
    @jp_weakify(self);
    [self.backwardsView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:duration beginTime:beginTime completionBlock:nil];
    [self.decorateView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:duration beginTime:beginTime completionBlock:nil];
    [self.backwardsLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:duration beginTime:beginTime completionBlock:nil];
    [self.dogView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_dogFrame1) duration:duration beginTime:beginTime completionBlock:^(POPAnimation *anim, BOOL finished) {
        @jp_strongify(self);
        if (!self) return;
        
        self.rprView.userInteractionEnabled = YES;
        self.rprView.alpha = 1;
        [self addTimer];
        
        if (RPManager.bgMusicURL) {
            SystemSoundID bgMusicID;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)RPManager.bgMusicURL, &bgMusicID);
            AudioServicesPlaySystemSound (bgMusicID);
            self.bgMusicID = bgMusicID;
        }
    }];
}

- (void)beginRedPackageRain {
    [self.rprView.models addObject:[self rpModel]];
    [self.rprView.models addObject:[self rpModel]];
    [self.rprView.models addObject:[self rpModel]];
}

#pragma mark - 创建红包模型

- (WTVRedPackageModel *)rpModel {
    WTVRedPackageModel *model = [[WTVRedPackageModel alloc] init];
    model.beginTime = (CGFloat)(arc4random() % 10) / 10.0;
    model.liveTime = 2 + (arc4random() % 4);
    
    NSInteger gitfCount = self.gitfModels.count;
    if (gitfCount) {
        NSInteger a = arc4random() % 2;
        if (a == 1) {
            NSInteger index = arc4random() % gitfCount;
            model.giftModel = self.gitfModels[index];
            [self.gitfModels removeObjectAtIndex:index];
        }
    }
    
    return model;
}

#pragma mark - 退场动画

- (void)closeAnimated {
    [self removeTimer];
    
    if (self.bgMusicID > 0) {
        AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
        AudioServicesDisposeSystemSoundID(self.bgMusicID);
        AudioServicesRemoveSystemSoundCompletion(self.bgMusicID);
    }
    
    NSTimeInterval duration = 0.35;
    [self.topBgView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_topBgFrame1) duration:duration completionBlock:nil];
    [self.bottomBgView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_bottomBgFrame1) duration:duration completionBlock:nil];
    CGRect frame = self.closeBtn.frame;
    frame.origin.y = -frame.size.height;
    [self.closeBtn jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(frame) duration:duration completionBlock:nil];
    [self.view jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:duration completionBlock:^(POPAnimation *anim, BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            !self.dismissHandle ? : self.dismissHandle(self.finishScreeningsModel);
        }];
    }];
}

#pragma mark - WTVRedPackageRainViewDelegate

- (NSTimeInterval)currentTime {
    static double time = 0;
    time += 0.1;
    return time;
}

- (void)redPackageViewDidClick:(WTVRedPackageView *)redPackageView atPoint:(CGPoint)point {
    
    if (RPManager.boomMusicURL) {
        SystemSoundID boomMusicID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)RPManager.boomMusicURL, &boomMusicID);
        AudioServicesPlaySystemSound (boomMusicID);
    }
    
    [redPackageView bombAnimated];
    
    WTVRedPackageRainGiftModel *giftModel = redPackageView.model.giftModel;
    NSString *content;
    if (giftModel) {
        switch (giftModel.giftType) {
            case WTVProvinceTrafficType:
            case WTVDomesticTrafficType:
                content = [NSString stringWithFormat:@"+ %zdM", giftModel.actualCount];
                break;
                
            default:
                content = [NSString stringWithFormat:@"+ %@", giftModel.name];
                break;
        }
        
        if (self.rpContentLabel) {
            [self.rpContentLabel pop_removeAllAnimations];
            [self rpContentLabelSecondAnimated:self.rpContentLabel];
        }
        
        if (!self.finishScreeningsModel) {
            self.finishScreeningsModel = [[WTVRedPackageRainScreeningsModel alloc] init];
            self.finishScreeningsModel.ID = self.currentScreeningsModel.ID;
            self.finishScreeningsModel.starttime = self.currentScreeningsModel.starttime;
            self.finishScreeningsModel.endtime = self.currentScreeningsModel.endtime;
        }
        [self.finishScreeningsModel.gitfModels addObject:giftModel];
        
    } else {
        return;
    }
    
    UILabel *rpContentLabel = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.font = [UIFont systemFontOfSize:18];
        aLabel.textColor = JPRGBColor(79, 49, 37);
        aLabel.text = content;
        aLabel.frame = _rpContentFrame;
        aLabel.layer.opacity = 0;
        aLabel;
    });
    [self.view insertSubview:rpContentLabel belowSubview:self.luckyBagView];
    self.rpContentLabel = rpContentLabel;
    
    [self rpContentLabelFirstAnimated:rpContentLabel];
}

- (void)rpContentLabelFirstAnimated:(UILabel *)rpContentLabel {
    NSTimeInterval duration = 1.0;
    [rpContentLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(1.1, 1.1)) duration:duration completionBlock:nil];
    [rpContentLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerTranslationY toValue:@(-30) duration:duration completionBlock:nil];
    [rpContentLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@1 duration:duration completionBlock:^(POPAnimation *anim, BOOL finished) {
        [self rpContentLabelSecondAnimated:rpContentLabel];
    }];
}

- (void)rpContentLabelSecondAnimated:(UILabel *)rpContentLabel {
    NSTimeInterval duration = 0.8;
    [rpContentLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(0.6, 0.6)) duration:duration completionBlock:nil];
    [rpContentLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerTranslationY toValue:@100 duration:duration completionBlock:nil];
    [rpContentLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@0 duration:duration completionBlock:^(POPAnimation *anim, BOOL finished) {
        [rpContentLabel removeFromSuperview];
    }];
}

#pragma mark - 结束抢红包

- (void)stopSnatchRedPackage {
    self.isRedPackageRainFinish = YES;
    [_timerLabel removeFromSuperview];
    
    self.rprView.userInteractionEnabled = NO;
    [self.rprView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:0.5 completionBlock:nil];
    
    NSTimeInterval duration = 0.5;
    NSTimeInterval beginTime = 0.0;
    
    [self.topBgView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_topBgFrame1) duration:duration beginTime:beginTime completionBlock:nil];
    [self.bottomBgView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_bottomBgFrame1) duration:duration beginTime:beginTime completionBlock:nil];
    [self.luckyBagView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_luckyBagFrame1)duration:duration beginTime:beginTime completionBlock:nil];
    
    @jp_weakify(self);
    WTVRedPackageRainResultView *resultView = [[WTVRedPackageRainResultView alloc] initWithFinishScreeningsModel:self.finishScreeningsModel shareGiftModel:self.shareGiftModel prizeDrawSuccess:^{
        @jp_strongify(self);
        if (!self) return;
        
        [self.finishScreeningsModel.gitfModels addObject:self.shareGiftModel];
        
    } closeBlock:^{
        @jp_strongify(self);
        if (!self) return;
        
        CGRect frame = self.resultView.frame;
        frame.origin.y = JPPortraitScreenHeight;
        [self.resultView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(CGPointMake(0.3, 0.3)) duration:0.35 completionBlock:nil];
        [self.resultView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:0.35 completionBlock:nil];
        CGRect btnFrame = self.closeBtn.frame;
        btnFrame.origin.y = -btnFrame.size.height;
        [self.closeBtn jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(btnFrame) duration:duration completionBlock:nil];
        [self.bgLayer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerBackgroundColor toValue:[UIColor colorWithWhite:1.0 alpha:0] duration:0.35 completionBlock:^(POPAnimation *anim, BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:^{
                !self.dismissHandle ? : self.dismissHandle(self.finishScreeningsModel);
            }];
        }];
    }];
    [self.view addSubview:resultView];
    self.resultView = resultView;
    [resultView showAnimated];
}

#pragma mark - 强制竖屏

//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}

@end
