//
//  WTVRedPackagePendantView.m
//  WoTV
//
//  Created by 周健平 on 2018/1/24.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackagePendantView.h"
#import "UIView+JPExtension.h"
#import "WTVRedPackageRainManager.h"

@interface WTVRedPackagePendantView () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIImageView *popView;
@property (nonatomic, weak) UILabel *popLabel;
@property (nonatomic, weak) UIButton *closeBtn;
@property (nonatomic, weak) UIButton *hideBtn;

@property (nonatomic, strong) UITapGestureRecognizer *leftTapGR;
@property (nonatomic, strong) UIPanGestureRecognizer *leftPanGR;

@property (nonatomic, strong) UITapGestureRecognizer *topTapGR;
@property (nonatomic, strong) UISwipeGestureRecognizer *topSwipeGR;
@property (nonatomic, strong) UIPanGestureRecognizer *topPanGR;

@property (nonatomic, assign) BOOL isAlwayHide;
@end

@implementation WTVRedPackagePendantView
{
    CGRect _pendantFrame;
    CGRect _hideLeftFrame;
}

- (instancetype)init {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.leftTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTap:)];
        
        self.leftPanGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPan:)];
        
        self.topTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topTap:)];
        
        self.topSwipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(topSwipe:)];
        self.topSwipeGR.direction = UISwipeGestureRecognizerDirectionUp;
        
        self.topPanGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topPan:)];
        
        self.topPanGR.delegate = self;
        self.topSwipeGR.delegate = self;
        
        CGFloat scale = JPScale;
        CGFloat w = 162.0 * scale;
        CGFloat h = 226.0 * scale;
        CGFloat x = JPPortraitScreenWidth - w - 10;
        CGFloat y = 0;
        _pendantFrame = CGRectMake(x, y, w, h);
        
        CGRect pendantFrame = _pendantFrame;
        pendantFrame.origin.y = -pendantFrame.size.height;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:pendantFrame];
        imageView.image = [UIImage imageNamed:@"widgets_bg"];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        w = 50 * scale;
        h = 91 * scale;
        x = JPPortraitScreenWidth - w;
        y = 80;
        _hideLeftFrame = CGRectMake(x, y, w, h);
        
        x = 0;
        w = _pendantFrame.size.width;
        h = 16.0 * scale; // 18
        y = 102.0 * scale;
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        timeLabel.font = [UIFont boldSystemFontOfSize:h];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.textColor = JPRGBColor(79, 49, 37);
        timeLabel.text = @"敬请期待";
        [imageView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        h = 12.0 * scale;
        y = timeLabel.jp_maxY + 8.0 * scale;
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        contentLabel.font = [UIFont systemFontOfSize:h];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.textColor = JPRGBColor(79, 49, 37);
        contentLabel.text = @"集神犬·赢大奖";
        [imageView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        w = 190.0 * scale;
        h = 82.0 * scale + 17;
        x = self.imageView.jp_x - w + 50 * scale;
        y = self.imageView.jp_height - 30 * scale;
        UIImageView *popView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        popView.image = [UIImage imageNamed:@"widgets_bg_popup"];
        popView.userInteractionEnabled = YES;
        [self addSubview:popView];
        self.popView = popView;
        
        x = 18.0 * scale;
        y = 15.0 * scale;
        w = popView.jp_width - x - 29 * scale;
        h = 30 * scale + 17;
        UILabel *popLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.font = [UIFont systemFontOfSize:12 * scale];
            aLabel.textColor = [UIColor whiteColor];
            aLabel.text = @"主人，我是春节人见人爱的抢红包提醒挂件哦！（上滑可隐藏）";
            aLabel.numberOfLines = 3;
            aLabel.frame = CGRectMake(x, y, w, h);
            aLabel;
        });
        [popView addSubview:popLabel];
        self.popLabel = popLabel;
        
        w = 60.0 * scale;
        h = 21.0 * scale;
        y = popView.jp_height - h - 9 * scale;
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"widgets_btn_no"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        closeBtn.frame = CGRectMake(x, y, w, h);
        [popView addSubview:closeBtn];
        self.closeBtn = closeBtn;
        
        x = popLabel.jp_maxX - w;
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [hideBtn setImage:[UIImage imageNamed:@"widgets_btn_yes"] forState:UIControlStateNormal];
        [hideBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        hideBtn.frame = CGRectMake(x, y, w, h);
        [popView addSubview:hideBtn];
        self.hideBtn = hideBtn;
        
        popView.layer.position = CGPointMake(popView.jp_maxX, popView.jp_y);
        popView.layer.anchorPoint = CGPointMake(1, 0);
        popView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        popView.layer.opacity = 0;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)show {
    
    if (self.isShowed) {
        return;
    }
    
    self.isShowed = YES;
    
    if (self.isAlwayHide) {
        !self.showComplete ? : self.showComplete();
        return;
    }
    
    self.layer.zPosition = 9999;
    [self.superVC.view addSubview:self];
    
    [self.imageView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_pendantFrame) duration:0.35 completionBlock:^(POPAnimation *anim, BOOL finished) {
        POPSpringAnimation *anim1 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        anim1.springSpeed = 5;
        anim1.springBounciness = 5;
        anim1.beginTime = CACurrentMediaTime();
        anim1.toValue = @(CGPointMake(1, 1));
        [self.popView.layer pop_addAnimation:anim1 forKey:@"ScaleXY"];
        
        POPSpringAnimation *anim2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
        anim2.springSpeed = 5;
        anim2.springBounciness = 5;
        anim2.beginTime = CACurrentMediaTime();
        anim2.toValue = @1;
        anim2.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            self.state = WTVRedPackagePendantChoose;
            !self.showComplete ? : self.showComplete();
        };
        [self.popView.layer pop_addAnimation:anim2 forKey:@"Opacity"];
        
        self.layer.zPosition = 0;
        [self.superVC.view addSubview:self];
    }];
    
}

- (void)close {
    if (self.isAlwayHide) {
        return;
    }
    
    [self.popView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(0.1, 0.1)) duration:0.25];
    [self.popView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@0 duration:0.25];
    
    CGRect frame = self.imageView.frame;
    frame.origin.y = -frame.size.height;
    [self.imageView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(frame) duration:0.35 beginTime:0.2 completionBlock:^(POPAnimation *anim, BOOL finished) {
        RPManager.pendantView = nil;
        [self removeFromSuperview];
        self.isAlwayHide = YES;
    }];
}

- (void)hide {
    if (self.isAlwayHide) {
        !self.tapBlock ? : self.tapBlock();
        return;
    }
    
    [self.popView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(0.1, 0.1)) duration:0.25];
    [self.popView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@0 duration:0.25];
    
    [self topSwipe:nil];
}

- (void)hideThorough {
    if (self.isAlwayHide) {
        return;
    }
    
    [self.popView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerScaleXY toValue:@(CGPointMake(0.1, 0.1)) duration:0.25];
    [self.popView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@0 duration:0.25];
    
    CGRect frame = self.imageView.frame;
    if (frame.origin.y == 0) {
        frame.origin.y = -frame.size.height;
    } else if (CGRectGetMaxX(frame) == JPPortraitScreenWidth) {
        frame.origin.x = JPPortraitScreenWidth;
    } else {
        frame.origin.y = -frame.size.height;
    }
    [self.imageView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(frame) duration:0.35 beginTime:0.2 completionBlock:nil];
}

- (void)showOnLeft {
    if (self.isAlwayHide) {
        return;
    }
    
    self.layer.zPosition = 9999;
    [self.superVC.view addSubview:self];
    
    [self.popView removeFromSuperview];
    
    [self.imageView removeGestureRecognizer:self.topTapGR];
    [self.imageView removeGestureRecognizer:self.topSwipeGR];
    [self.imageView removeGestureRecognizer:self.topPanGR];
    
    self.timeLabel.hidden = YES;
    self.contentLabel.hidden = YES;
    
    CGRect hideLeftFrame = _hideLeftFrame;
    hideLeftFrame.origin.x = JPPortraitScreenWidth;
    self.imageView.frame = hideLeftFrame;
    self.imageView.image = [UIImage imageNamed:@"widgets_icon_hide"];
    
    [self.imageView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(_hideLeftFrame) duration:0.35 beginTime:0.2 completionBlock:^(POPAnimation *anim, BOOL finished) {
        
        self.state = WTVRedPackagePendantShowOnLeft;
        self.imageView.userInteractionEnabled = YES;
        [self.imageView addGestureRecognizer:self.leftTapGR];
        [self.imageView addGestureRecognizer:self.leftPanGR];
        
        self.layer.zPosition = 0;
        [self.superVC.view addSubview:self];
    }];
}

#pragma mark - 手势

- (void)leftTap:(UITapGestureRecognizer *)leftTapGR {
    CGRect frame = self.imageView.frame;
    frame.origin.x = JPPortraitScreenWidth;
    [self.imageView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(frame) duration:0.25 completionBlock:^(POPAnimation *anim, BOOL finished) {
        
        [self.imageView removeGestureRecognizer:self.leftTapGR];
        [self.imageView removeGestureRecognizer:self.leftPanGR];
        
        self.timeLabel.hidden = NO;
        self.contentLabel.hidden = NO;
        
        self.imageView.image = [UIImage imageNamed:@"widgets_bg"];
        
        CGRect pendantFrame = self->_pendantFrame;
        pendantFrame.origin.y = -pendantFrame.size.height;
        self.imageView.frame = pendantFrame;
        
        [self.imageView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(self->_pendantFrame) duration:0.35 completionBlock:^(POPAnimation *anim, BOOL finished) {
            
            self.state = WTVRedPackagePendantShowOnTop;
            [self.imageView addGestureRecognizer:self.topTapGR];
            [self.imageView addGestureRecognizer:self.topSwipeGR];
            [self.imageView addGestureRecognizer:self.topPanGR];
            
        }];
    }];
}

- (void)leftPan:(UIPanGestureRecognizer *)leftPanGR {
    CGPoint translation = [leftPanGR translationInView:self.imageView];
    
    [leftPanGR setTranslation:CGPointZero inView:self.imageView];
    
    if (leftPanGR.state == UIGestureRecognizerStateChanged) {
        
        CGRect frame = self.imageView.frame;
        
        frame.origin.y += translation.y;
        
        if (CGRectGetMaxY(frame) > self.jp_height) {
            frame.origin.y = self.jp_height - frame.size.height;
        }
        
        if (frame.origin.y < 0) {
            frame.origin.y = 0;
        }
        
        self.imageView.frame = frame;
        
    }
}

- (void)topPan:(UIPanGestureRecognizer *)topPanGR {
    CGPoint translation = [topPanGR translationInView:self.imageView];
    
    [topPanGR setTranslation:CGPointZero inView:self.imageView];
    
    if (topPanGR.state == UIGestureRecognizerStateChanged) {
        
        CGRect frame = self.imageView.frame;
        
        frame.origin.x += translation.x;
        
        if (CGRectGetMaxX(frame) > self.jp_width) {
            frame.origin.x = self.jp_width - frame.size.width;
        }
        
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        }
        
        self.imageView.frame = frame;
        
    }
}

- (void)topTap:(UITapGestureRecognizer *)topTapGR {
    CGRect pendantFrame = _pendantFrame;
    pendantFrame.origin.x = self.imageView.jp_x;
    pendantFrame.origin.y = -pendantFrame.size.height;
    [self.imageView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(pendantFrame) duration:0.35 completionBlock:^(POPAnimation *anim, BOOL finished) {
        self.state = WTVRedPackagePendantHide;
        !self.tapBlock ? : self.tapBlock();
    }];
}

- (void)topSwipe:(UISwipeGestureRecognizer *)topSwipeGR {
    CGRect frame = self.imageView.frame;
    if (frame.origin.y == 0) {
        frame.origin.y = -frame.size.height;
    } else if (CGRectGetMaxX(frame) == JPPortraitScreenWidth) {
        frame.origin.x = JPPortraitScreenWidth;
    } else {
        frame.origin.y = -frame.size.height;
    }
    [self.imageView jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(frame) duration:0.35 beginTime:0.2 completionBlock:^(POPAnimation *anim, BOOL finished) {
        if (RPManager.currentScreeningsModel.state == WTVScreeningsOnGoingState ||
            RPManager.currentScreeningsModel.state == WTVScreeningsReadyBeginState) {
            self.imageView.userInteractionEnabled = YES;
            self.state = WTVRedPackagePendantHide;
            !self.tapBlock ? : self.tapBlock();
        } else {
            [self showOnLeft];
        }
    }];
}

#pragma mark - 父类方法

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.imageView.userInteractionEnabled) {
        return CGRectContainsPoint(self.imageView.frame, point);
    }
    return [super pointInside:point withEvent:event];
}

@end
