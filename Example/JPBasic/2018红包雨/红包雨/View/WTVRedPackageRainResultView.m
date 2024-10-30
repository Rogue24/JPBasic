//
//  WTVRedPackageRainResultView.m
//  WoTV
//
//  Created by 周健平 on 2018/1/23.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageRainResultView.h"
#import "WTVRedPackageModel.h"
#import "WTVRedPackageRainManager.h"
#import "JPWebImageManager.h"

@interface WTVRedPackageRainResultView ()
@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIButton *confirmBtn;

@property (nonatomic, strong) NSMutableArray *shareBtns;
@property (nonatomic, strong) NSMutableArray *shareLabels;

@property (nonatomic, weak) UIImageView *startView;
@property (nonatomic, assign) BOOL isShareSuccess;
@property (nonatomic, assign) BOOL isOpened;

@end

@implementation WTVRedPackageRainResultView

- (instancetype)initWithFinishScreeningsModel:(WTVRedPackageRainScreeningsModel *)finishScreeningsModel shareGiftModel:(WTVRedPackageRainGiftModel *)shareGiftModel prizeDrawSuccess:(void (^)(void))prizeDrawSuccess closeBlock:(void (^)(void))closeBlock {
    if (self = [super init]) {
        
        self.prizeDrawSuccess = prizeDrawSuccess;
        self.closeBlock = closeBlock;
        
        self.shareGiftModel = shareGiftModel;
        self.finishScreeningsModel = finishScreeningsModel;
        
        CGFloat scale = JPScale;
        
        CGFloat imageW = JPPortraitScreenWidth * (315.0 / 375.0);
        CGFloat imageH = imageW * (355.5 / 315.0);
        
        CGFloat btnW = 200 * scale;
        CGFloat btnH = 40 * scale;
        
        CGFloat w = imageW;
        CGFloat h = imageH + 10 + btnH;
        CGFloat x = (JPPortraitScreenWidth - w) * 0.5;
        CGFloat y = (JPPortraitScreenHeight - h) * 0.5;
        self.frame = CGRectMake(x, y, w, h);
        
        BOOL isNot = (!finishScreeningsModel || finishScreeningsModel.gitfModels.count == 0);
        
        UIButton *cancelBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:(isNot ? @"popup_no_prize_share_no" : @"popup_huojiang_btn_share_no")] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(cancelBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake((self.jp_width - btnW) * 0.5, imageH - btnH, btnW, btnH);
            btn;
        });
        [self addSubview:cancelBtn];
        self.cancelBtn = cancelBtn;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageW, imageH)];
        imageView.image = [UIImage imageNamed:(isNot ? @"popup_bg_no_prize" : @"popup_bg_huojiang")];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UIButton *confirmBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:(isNot ? @"popup_no_prize_share" : @"popup_huojiang_btn_share")] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake((imageW - btnW) * 0.5, imageH - btnH - 15, btnW, btnH);
            btn;
        });
        [self addSubview:confirmBtn];
        self.confirmBtn = confirmBtn;
        
        UILabel *titleLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:25];
            aLabel.textColor = [UIColor whiteColor];
            aLabel.text = isNot ? @"哎呀，差一点就抢到了" : @"你的运气爆棚啦";
            [aLabel sizeToFit];
            aLabel.jp_width = imageW;
            aLabel.jp_y = 190 * scale;
            aLabel;
        });
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIFont *font = [UIFont systemFontOfSize:15];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 8.0;
        paragraphStyle.alignment = NSTextAlignmentCenter;

        NSDictionary *attributed = @{NSParagraphStyleAttributeName: paragraphStyle,
                                     NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: JPRGBColor(255, 208, 126)};
        
        NSString *contentStr;
        if (isNot) {
            contentStr = @"请不要气馁哟\n红包还有好多\n休息一下，下次再来";
        } else {
            NSInteger redPackageCount = finishScreeningsModel.gitfModels.count;
            NSInteger trafficCount = 0;
            NSMutableString *allDogStr = [NSMutableString string];
            for (WTVRedPackageRainGiftModel *giftModel in finishScreeningsModel.gitfModels) {
                switch (giftModel.giftType) {
                    case WTVProvinceTrafficType:
                    case WTVDomesticTrafficType:
                        trafficCount += giftModel.actualCount;
                        break;
                    default:
                        if (allDogStr.length) {
                            [allDogStr appendString:@"，"];
                        }
                        [allDogStr appendString:[NSString stringWithFormat:@"%zd个%@", giftModel.actualCount, giftModel.name]];
                        break;
                }
            }
            
            NSString *redPackageStr = [NSString stringWithFormat:@"%zd个红包", redPackageCount];
            
            NSString *trafficStr = @"";
            if (trafficCount > 0) {
                trafficStr = [NSString stringWithFormat:@"，共%zdM流量", trafficCount];
            }
            
            contentStr = [NSString stringWithFormat:@"%@%@", redPackageStr, trafficStr];
            if (allDogStr.length) {
                contentStr = [NSString stringWithFormat:@"%@\n%@", contentStr, allDogStr];
            }
        }
        
        NSAttributedString *content = [[NSAttributedString alloc] initWithString:contentStr attributes:attributed];

        UILabel *contentLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.jp_y = titleLabel.jp_maxY + 10;
            aLabel.jp_width = imageW;
            aLabel.jp_height = confirmBtn.jp_y - 10 - aLabel.jp_y;
            aLabel.numberOfLines = 0;
            aLabel.attributedText = content;
            aLabel;
        });
        [self addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        [self setupShareViews];
    }
    return self;
}

- (void)setupShareViews {
    CGFloat scale = JPPortraitScreenWidth / 375.0;
    CGFloat w = 48 * scale;
    CGFloat h = w;
    CGFloat x = 20 * scale;
    
    CGFloat zh = h + 10 + 12;
    CGFloat y = self.titleLabel.jp_maxY + (self.imageView.jp_height - self.titleLabel.jp_maxY - zh) * 0.5;
    
    CGFloat space = (self.imageView.jp_width - w * 4 - 2 * x) / 3.0;
    
    self.shareBtns = [NSMutableArray array];
    self.shareLabels = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 4; i++) {
        
        UIImage *image;
        NSString *title;
        
        switch (i) {
            case 0:
                image = [UIImage imageNamed:@"share_wechat"];
                title = @"微信好友";
                break;
                
            case 1:
                image = [UIImage imageNamed:@"share_friends"];
                title = @"朋友圈";
                break;
                
            case 2:
                image = [UIImage imageNamed:@"share_qq"];
                title = @"QQ好友";
                break;
                
            case 3:
                image = [UIImage imageNamed:@"share_weibo"];
                title = @"新浪微博";
                break;
                
            default:
                break;
        }
        
        UIButton *shareBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:image forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(shareBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(x, y, w, h);
            btn.tag = i;
            btn;
        });
        [self addSubview:shareBtn];
        [self.shareBtns addObject:shareBtn];
        
        UILabel *shareLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel.font = [UIFont systemFontOfSize:12];
            aLabel.textColor = [UIColor whiteColor];
            aLabel.text = title;
            [aLabel sizeToFit];
            CGFloat lx = x + (w - aLabel.jp_width) * 0.5;
            aLabel.frame = CGRectMake(lx, shareBtn.jp_maxY + 10, aLabel.jp_width, 12);
            aLabel;
        });
        [self addSubview:shareLabel];
        [self.shareLabels addObject:shareLabel];
        
        shareBtn.layer.opacity = 0;
        shareLabel.layer.opacity = 0;
        
        x += w + space;
    }
    
}

#pragma mark - 按钮事件

- (void)cancelBtnDidClick {
    !self.closeBlock ? : self.closeBlock();
}

- (void)confirmBtnDidClick {
    
    if (self.isOpened) {
        !self.closeBlock ? : self.closeBlock();
        return;
    }
    
    if (self.isShareSuccess) {
        
        self.isOpened = YES;
        
        BOOL prizeDrawSuccess = arc4random() % 2;
        if (prizeDrawSuccess) {
            !self.prizeDrawSuccess ? : self.prizeDrawSuccess();
        }
        
        NSTimeInterval duration = 0.35;
        
        CATransition *transition = [CATransition animation];
        transition.duration = duration;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;
        [self.imageView.layer addAnimation:transition forKey:@"Fade"];
        self.imageView.image = [UIImage imageNamed:@"redpacket_open_bg"];
        
        [self.confirmBtn.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerTranslationY toValue:@50 duration:duration completionBlock:nil];
        [self.confirmBtn.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerRotation toValue:@(M_PI_2 * 0.5) duration:duration completionBlock:nil];
        [self.confirmBtn.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@0 duration:duration completionBlock:^(POPAnimation *anim, BOOL finished) {
            
            self.confirmBtn.layer.transform = CATransform3DIdentity;
            
            CGFloat scale = JPScale;
            
            CGFloat w = 130.0 * scale;
            CGFloat h = 36.0 * scale;
            CGFloat x = self.imageView.jp_x + (self.imageView.jp_width - w) * 0.5;
            CGFloat y = self.jp_height - h - 24 * scale;
            self.confirmBtn.frame = CGRectMake(x, y, w, h);
            [self.confirmBtn setImage:[UIImage imageNamed:(prizeDrawSuccess ? @"redpacket_open_btn_know" : @"redpacket_open_btn_deng")] forState:UIControlStateNormal];
            
            w = self.imageView.jp_width;
            h = 12;
            x = self.imageView.jp_x;
            y = self.confirmBtn.jp_y - h - 10 * scale;
            self.titleLabel.frame = CGRectMake(x, y, w, h);
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            self.titleLabel.textColor = JPRGBColor(184, 35, 1);
            self.titleLabel.text = prizeDrawSuccess ? @"已放入您的账户,请在个人中心查看" : @"别灰心，下一轮一定会中！";
            
            w = (prizeDrawSuccess ? 88.0 : 112.0) * scale;
            h = (prizeDrawSuccess ? 22.0 : 52.0) * scale;
            x = self.imageView.jp_x + (self.imageView.jp_width - w) * 0.5;
            y = self.imageView.jp_y + (prizeDrawSuccess ? 20.0 : 42.0) * scale;
            UIImageView *rewardView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
            rewardView.image = [UIImage imageNamed:(prizeDrawSuccess ? @"redpacket_open_webcopy_huojiang" : @"redpacket_open_webcopy")];
            [self addSubview:rewardView];
            
            if (prizeDrawSuccess) {
                NSString *rewardText;
                switch (self.shareGiftModel.giftType) {
                    case WTVProvinceTrafficType:
                    case WTVDomesticTrafficType:
                        rewardText = [NSString stringWithFormat:@"共%zdM流量", self.shareGiftModel.actualCount];
                        break;
                    default:
                        rewardText = [NSString stringWithFormat:@"%@X%zd", self.shareGiftModel.name, self.shareGiftModel.actualCount];
                        break;
                }
                UILabel *rewardLabel = ({
                    UILabel *aLabel = [[UILabel alloc] init];
                    aLabel.textAlignment = NSTextAlignmentCenter;
                    aLabel.font = [UIFont systemFontOfSize:15 * scale];
                    aLabel.textColor = JPRGBColor(255, 162, 52);
                    aLabel.text = rewardText;
                    w = self.imageView.jp_width - 2 * 25;
                    h = 55.0 * scale;
                    x = self.imageView.jp_x + 25;
                    y = rewardView.jp_maxY + 15.0 * scale;
                    aLabel.frame = CGRectMake(x, y, w, h);
                    aLabel;
                });
                [self addSubview:rewardLabel];
                rewardLabel.layer.opacity = 0;
                rewardLabel.layer.transform = CATransform3DMakeTranslation(0, 20, 0);
                [rewardLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@1 duration:0.35 completionBlock:nil];
                [rewardLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerTranslationY toValue:@0 duration:0.35 completionBlock:nil];
            }
            
            rewardView.layer.opacity = 0;
            rewardView.layer.transform = CATransform3DMakeTranslation(0, 20, 0);
            [rewardView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@1 duration:0.35 completionBlock:nil];
            [rewardView.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerTranslationY toValue:@0 duration:0.35];
            
            [self.confirmBtn jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@1 duration:0.25];
            [self.titleLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@1 duration:0.25];
        }];
        
        return;
    }
    
    self.imageView.image = [UIImage imageNamed:@"popup_bg_huojiang"];
    
    NSTimeInterval duration = 0.3;
    
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    [self.titleLabel.layer addAnimation:transition forKey:@"Fade"];
    self.titleLabel.text = @"分享成功拆红包";
    
    [self.confirmBtn jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:duration];
    [self.cancelBtn jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:duration];
    [self.contentLabel jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:duration];
    
    for (NSInteger i = 0; i < 4; i++) {
        
        UIButton *shareBtn = self.shareBtns[i];
        UILabel *shareLabel = self.shareLabels[i];
        
        NSTimeInterval delay = duration + i * 0.05;
        
        shareBtn.layer.transform = CATransform3DMakeTranslation(0, 30, 0);
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationY];
        anim.springSpeed = 5;
        anim.springBounciness = 10;
        anim.beginTime = CACurrentMediaTime() + delay;
        anim.toValue = @0;
        anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            [shareLabel.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@1 duration:0.25];
        };
        [shareBtn.layer pop_addAnimation:anim forKey:@"TranslationY"];
        [shareBtn.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@1 duration:0.25 beginTime:delay completionBlock:nil];
    }
    
    
}

- (void)shareBtnDidClick:(UIButton *)btn {
    NSLog(@"假装分享成功了");
    
//    NSString *noInstalledStr = @"";
//
//    UMSocialPlatformType shareType = UMSocialPlatformType_UnKnown;
//    switch (btn.tag) {
//
//        case 0:
//        {
//            shareType = UMSocialPlatformType_WechatSession;
//            if (![WXApi isWXAppInstalled]) {
//                noInstalledStr = @"您没有安装微信";
//                return;
//            }
//            break;
//        }
//
//        case 1:
//        {
//            shareType = UMSocialPlatformType_WechatTimeLine;
//            if (![WXApi isWXAppInstalled]) {
//                noInstalledStr = @"您没有安装微信";
//                return;
//            }
//            break;
//        }
//
//        case 2:
//        {
//            shareType = UMSocialPlatformType_QQ;
//            if ( ![QQApiInterface isQQInstalled]) {
//                noInstalledStr = @"您没有安装QQ";
//                return;
//            }
//            break;
//        }
//
//        case 3:
//        {
//            shareType = UMSocialPlatformType_Sina;
//            if ( ![WeiboSDK isWeiboAppInstalled]) {
//                noInstalledStr = @"您没有安装微博";
//                return;
//            }
//            break;
//        }
//
//        default: break;
//    }
//
//
//
//    if (![WTVShareTool isInstalledPlatform:shareType]) {
//        [self showToastCenterWithTip:noInstalledStr];
//        return;
//    }
//
//    @jp_weakify(self);
//    [[MyTools keyWindow] jp_showHUD];
//    [NetWorkRequest shareMessageWithTVCid:nil videoType:nil method:1 callback:^(WTVShareModel *shareModel) {
//        @jp_strongify(self);
//        if (!self) return;
//
//        [[MyTools keyWindow]  jp_hideHUD];
//
//        if (!shareModel) {
//            [[MyTools keyWindow]  showToastCenterWithTip:@"分享失败"];
//            return;
//        }
//
//        NSString *param1 = @"0";
//        NSString *param2 = [UserModel getoutAccount].uid;
//        NSString *param = [TripleDES encryptUseDES:[NSString stringWithFormat:@"%@;%@", param1, param2] key:DESKEY];
//        NSString *urlStr = [NSString stringWithFormat:@"https://wotest.17wo.cn/wovideo/celestail/dog/share?code=%@", param];
//
//        [JPWebImageManager downloadImageWithURL:[NSURL URLWithString:shareModel.icon] options:kNilOptions progress:nil transform:nil completed:^(UIImage *image, NSError *error, NSURL *imageURL, JPWebImageFromType jp_fromType, JPWebImageStage jp_stage) {
//            UIImage *shareImage = image;
//            if (!shareImage) {
//                NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
//                NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
//                shareImage = [UIImage imageNamed:icon];
//            }
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [WTVShareTool shareWithTitle:shareModel.title url:urlStr shareName:shareModel.des shareImage:shareImage platformType:shareType shareCallBack:^(BOOL shareSuccess) {
//                    if (shareSuccess) {
//                        [self shareSuccess];
//                    } else {
//                        [self showToastCenterWithTip:@"分享失败"];
//                    }
//                }];
//            });
//        }];
//    }];
}

#pragma mark - 动画

- (void)showAnimated {
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    anim.springSpeed = 5;
    anim.springBounciness = 10;
    anim.beginTime = CACurrentMediaTime();
    anim.toValue = @(CGPointMake(1, 1));
    
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        CGRect frame = self.confirmBtn.frame;
        frame.origin.y = self.jp_height - self.confirmBtn.jp_height;
    
        [self.cancelBtn jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewFrame toValue:@(frame) duration:0.25];
    };
    [self pop_addAnimation:anim forKey:@"ScaleXY"];
}


- (void)shareSuccess {
    self.isShareSuccess = YES;
    
    NSTimeInterval duration = 0.35;
    [self jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewAlpha toValue:@0 duration:duration];
   
    [self jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewScaleXY toValue:@(CGPointMake(0.1, 0.1)) duration:duration completionBlock:^(POPAnimation *anim, BOOL finished) {
        
        [self.cancelBtn removeFromSuperview];
        [self.contentLabel removeFromSuperview];
        for (UIButton *shareBtn in self.shareBtns) {
            [shareBtn removeFromSuperview];
        }
        for (UILabel *shareLabel in self.shareLabels) {
            [shareLabel removeFromSuperview];
        }
        
        self.titleLabel.alpha = 0;
        
        [self pop_removeAllAnimations];
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
        CGFloat scale = JPScale;
        
        CGFloat w = 285.0 * scale;
        CGFloat h = w;
        CGFloat x = 0;
        CGFloat y = 0;
        CGRect startFrame = CGRectMake(x, y, w, h);
        
        w = 217.0 * scale;
        h = 290.0 * scale;
        x = (startFrame.size.width - w) * 0.5;
        y = 94 * scale;
        CGRect rpFrame = CGRectMake(x, y, w, h);
        
        w = 76.0 * scale;
        h = 78.0 * scale;
        x = rpFrame.origin.x + (rpFrame.size.width - w) * 0.5;
        y = rpFrame.origin.y + (rpFrame.size.height - h) * 0.5;
        CGRect btnFrame = CGRectMake(x, y, w, h);
        
        w = startFrame.size.width;
        h = CGRectGetMaxY(rpFrame);
        x = (JPPortraitScreenWidth - w) * 0.5;
        y = (JPPortraitScreenHeight - h) * 0.5;
        self.frame = CGRectMake(x, y, w, h);
        
        UIImageView *startView = [[UIImageView alloc] initWithFrame:startFrame];
        startView.image = [UIImage imageNamed:@"redpacket_bg_star"];
        [self insertSubview:startView belowSubview:self.imageView];
        
        self.imageView.frame = rpFrame;
        self.imageView.image = [UIImage imageNamed:@"redpacket_bg_share"];
        
        self.confirmBtn.alpha = 1;
        self.confirmBtn.frame = btnFrame;
        [self.confirmBtn setImage:[UIImage imageNamed:@"redpacket_btn_chai"] forState:UIControlStateNormal];
        
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 1;
        POPSpringAnimation *anim1 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        anim1.springSpeed = 5;
        anim1.springBounciness = 10;
        anim1.toValue = @(CGPointMake(1, 1));
        [self pop_addAnimation:anim1 forKey:@"ScaleXY"];
        
    }];
}

@end
