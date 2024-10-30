//
//  WTVGIFButton.m
//  WoTV
//
//  Created by 周健平 on 2019/12/24.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import "WTVGIFButton.h"
#import "JPGIFShareViewController.h"

@interface WTVGIFButton ()
@property (nonatomic, weak) JPGIFShareViewController *gifVC;

@property (nonatomic, assign) CGFloat bgRadius;
@property (nonatomic, assign) CGFloat lineRadius;

@property (nonatomic, weak) UIVisualEffectView *blurView;
@property (nonatomic, weak) CAShapeLayer *bgLineLayer;
@property (nonatomic, weak) CAShapeLayer *lineLayer;
@property (nonatomic, weak) UIImageView *icon;
@end

@implementation WTVGIFButton
{
    CGFloat _bgScale;
    CGFloat _bgLineWidth;
    CGFloat _lineWidth;
}

- (BOOL)isPreview {
    return self.gifVC != nil;
}

- (void)__setup {
    [super __setup];
    
    CGFloat maxW = 400;
    CGFloat maxH = maxW * (9.0 / 16.0);
    self.gifMaxSize = CGSizeMake(maxW, maxH);
    
    self.layer.masksToBounds = NO;
    
    CGFloat radius = JPScaleValue(135);
    CGFloat wh = radius * 2;
    CGFloat halfBtnWH = JPScaleValue(20);
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = CGRectMake(0, 0, wh, wh);
    blurView.center = CGPointMake(halfBtnWH, halfBtnWH);
    blurView.layer.cornerRadius = radius;
    blurView.layer.masksToBounds = YES;
    [self addSubview:blurView];
    self.blurView = blurView;
    
    CGPoint center = CGPointMake(radius, radius);
    radius = JPScaleValue(80);
    
    CAShapeLayer *bgLineLayer = [CAShapeLayer layer];
    bgLineLayer.fillColor = UIColor.clearColor.CGColor;
    bgLineLayer.strokeColor = JPRGBAColor(0, 0, 0, 0.4).CGColor;
    bgLineLayer.lineCap = kCALineCapRound;
    bgLineLayer.lineJoin = kCALineCapRound;
    bgLineLayer.lineWidth = 0;
    bgLineLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:-(M_PI_2 * 3) clockwise:NO].CGPath;
    [blurView.contentView.layer addSublayer:bgLineLayer];
    self.bgLineLayer = bgLineLayer;
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.fillColor = UIColor.clearColor.CGColor;
    lineLayer.strokeColor = JPRGBAColor(188, 188, 188, 1).CGColor;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineCapRound;
    lineLayer.lineWidth = 0;
    lineLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:-(M_PI_2 * 3) clockwise:NO].CGPath;
    [blurView.contentView.layer addSublayer:lineLayer];
    self.lineLayer = lineLayer;
    
    _bgLineWidth = JPScaleValue(15);
    _lineWidth = JPScaleValue(7.5);
    _bgScale = (halfBtnWH * 2) / wh;
    blurView.transform = CGAffineTransformMakeScale(_bgScale, _bgScale);
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon_gif"]];
    icon.center = CGPointMake(halfBtnWH, halfBtnWH);
    [self addSubview:icon];
    self.icon = icon;
    
    @jp_weakify(self);
    self.gifStartRecord = ^{
        @jp_strongify(self);
        if (!self) return;
        // 确保播放中
        [JPProgressHUD showImage:nil status:@"请长按2秒以上" userInteractionEnabled:YES];
        [self startRecord];
    };
    
    self.gifConfirmCreate = ^{
        @jp_strongify(self);
        if (!self) return;
        [JPProgressHUD showImage:nil status:@"松手即可完成录制" userInteractionEnabled:YES];
        [self confirmCreate];
    };
    
    self.gifPrepareCreate = ^{
        @jp_strongify(self);
        if (!self) return;
        [self finishRecord];
    };
    
    self.gifStartCreate = ^(UIImage *firstImage) {
        @jp_strongify(self);
        if (!self) return;
        [self.player pause];
        [self startShare];
        self.gifVC = [JPGIFShareViewController showGIFShareVcWithPlaceholder:firstImage isPortrait:!JPScreenRotationTool.sharedInstance.isPortrait dismissBlock:^{
            @jp_strongify(self);
            if (!self) return;
            [self reset];
            [self shareDone];
            [self.player play];
            // 恢复旋转方向...
            JPScreenRotationTool.sharedInstance.isLockOrientationWhenDeviceOrientationDidChange = YES;
            JPScreenRotationTool.sharedInstance.isLockLandscapeWhenDeviceOrientationDidChange = NO;
            [JPScreenRotationTool.sharedInstance rotationToPortrait];
        }];
    };
    
    self.gifCreateFailed = ^(JPGifFailReason failReason) {
        @jp_strongify(self);
        if (!self) return;
        if (self.gifVC) {
            [self.gifVC createFaild];
        } else {
            NSString *reason;
            switch (failReason) {
                case JPGifFailReason_FewTotalDuration:
                    reason = @"剩余时间过短";
                    break;
                case JPGifFailReason_FewRecordDuration:
                    reason = @"录制时间过短，请重录";
                    break;
                case JPGifFailReason_FewFrameInterval:
                    reason = @"获取帧数太少，请重录";
                    break;
                case JPGifFailReason_CreateFailed:
                    reason = @"生成GIF失败，请重录";
                    break;
            }
            [JPProgressHUD showErrorWithStatus:reason userInteractionEnabled:YES];
            [self reset];
            [self finishRecord];
        }
    };
    
    self.gifCreateSuccess = ^(NSString *gifFilePath) {
        @jp_strongify(self);
        if (!self) return;
        if (self.gifVC) {
            self.gifVC.gifFilePath = gifFilePath;
        } else {
            [self reset];
        }
    };
}

- (void)dealloc {
    JPLog(@"gif dead");
}

- (void)startRecord {
    // 扩开
    
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    anim.beginTime = 0;
    anim.duration = self.factRecordSecond;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim.fromValue = @0;
    anim.toValue = @1;
    [self.lineLayer pop_addAnimation:anim forKey:kPOPShapeLayerStrokeEnd];
    
    [self.blurView jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(CGPointMake(1, 1)) springSpeed:5 springBounciness:6 completionBlock:^(POPAnimation *anim, BOOL finished) {
        if (!finished) return;
        POPBasicAnimation *anim1 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        anim1.duration = 0.9;
        anim1.fromValue = @(CGPointMake(1, 1));
        anim1.toValue = @(CGPointMake(0.95, 0.95));
        anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        anim1.repeatForever = YES;
        anim1.autoreverses = YES;
        [self.blurView pop_addAnimation:anim1 forKey:kPOPViewScaleXY];
    }];
    
    [self.icon jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(CGPointMake(1.5, 1.5)) springSpeed:5 springBounciness:14];
    
    [self.bgLineLayer jp_addPOPSpringAnimationWithPropertyNamed:kPOPShapeLayerLineWidth toValue:@(_bgLineWidth) springSpeed:10 springBounciness:10 beginTime:0.15 completionBlock:nil];
    [self.lineLayer jp_addPOPSpringAnimationWithPropertyNamed:kPOPShapeLayerLineWidth toValue:@(_lineWidth) springSpeed:10 springBounciness:10 beginTime:0.15 completionBlock:nil];
}

- (void)confirmCreate {
    // 变色
    
    AudioServicesPlaySystemSound(1519);
    
    [self.lineLayer jp_addPOPSpringAnimationWithPropertyNamed:kPOPShapeLayerLineWidth toValue:@(_bgLineWidth) springSpeed:10 springBounciness:10];
    [self.lineLayer jp_addPOPSpringAnimationWithPropertyNamed:kPOPShapeLayerStrokeColor toValue:JPRGBAColor(255, 151, 0, 1) springSpeed:10 springBounciness:10];
}

- (void)finishRecord {
    // 还原
    
    UIColor *bgColor;
    if (self.isCreateGIF) {
        bgColor = JPRGBAColor(255, 151, 0, 1);
    } else {
        bgColor = JPRGBAColor(0, 0, 0, 0.4);
    }
    
    [self.blurView pop_removeAnimationForKey:kPOPViewScaleXY];
    [self.blurView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(CGPointMake(_bgScale, _bgScale)) duration:0.25 completionBlock:^(POPAnimation *anim, BOOL finished) {
        [self.lineLayer pop_removeAllAnimations];
        self.lineLayer.strokeEnd = 0.0;
        self.lineLayer.strokeColor = JPRGBAColor(188, 188, 188, 1).CGColor;
    }];
    
    [self.icon jp_addPOPSpringAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(CGPointMake(1, 1)) springSpeed:5 springBounciness:14];
    
    [self.bgLineLayer jp_addPOPBasicAnimationWithPropertyNamed:kPOPShapeLayerLineWidth toValue:@(0) duration:0.15];
    [self.lineLayer jp_addPOPBasicAnimationWithPropertyNamed:kPOPShapeLayerLineWidth toValue:@(0) duration:0.15];
    
    [self.lineLayer pop_removeAnimationForKey:kPOPShapeLayerStrokeEnd];
}

- (void)startShare {
    // 隐藏
    
}

- (void)shareDone {
    // 显示、还原
    
}

@end
