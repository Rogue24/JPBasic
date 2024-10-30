//
//  WTVRedPacketPopView.m
//  WoTV
//
//  Created by 周恩慧 on 2018/2/6.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPacketPopView.h"
#import "WTVRedPackageRainManager.h"
#import "JPWebImageManager.h"

@interface WTVRedPacketPopView ()

@property (nonatomic, strong) UIButton *cancleBtn;

@property (nonatomic, strong) UIImageView *redPacketImageView;

@property (nonatomic, strong) UIImageView *contentImageView;

@property (nonatomic, strong) UILabel *bigTitleLabel;

@property (nonatomic, strong) UIButton *topSureBtn;


@property (nonatomic, strong) UILabel *contentTopLabel;
@property (nonatomic, strong) UILabel *contentBottomLabel;

@property (nonatomic, strong) UILabel *conversionDetailLabel;

@property (nonatomic, strong) UIView *shareView;

@property (nonatomic, copy) RedPackageRainShareDataRequestHandler dataRequestHandle;
@property (nonatomic, copy) RedPackageRainShareResponseHandler responseHandler;

@property (nonatomic, weak) UIButton *noLoginBtn;
@property (nonatomic, weak) UIButton *goLoginBtn;
@end

@implementation WTVRedPacketPopView

+ (WTVRedPacketPopView *)sharePopViewWithTitle:(NSString *)title dataRequestHandle:(RedPackageRainShareDataRequestHandler)dataRequestHandle responseHandler:(RedPackageRainShareResponseHandler)responseHandler {
    WTVRedPacketPopView *popView = [[WTVRedPacketPopView alloc]init];
    popView.dataRequestHandle = dataRequestHandle;
    popView.responseHandler = responseHandler;
    popView.popViewType = WTVRedPacketPopViewShare;
    popView.bigTitleLabel.text = title;
    [popView addToKeyWindow];
    [popView showAnimation];
    return popView;
}

+ (WTVRedPacketPopView *)loginPopViewWithSureHandler:(void (^)(void))sureHandler cancelHandle:(void (^)(void))cancelHandle {
    WTVRedPacketPopView *popView = [[WTVRedPacketPopView alloc]init];
    popView.sureHandler = sureHandler;
    popView.cancelHandle = cancelHandle;
    popView.popViewType = WTVRedPacketPopViewNeedLogin;
    [popView addToKeyWindow];
    [popView showAnimation];
    return popView;
}

+ (WTVRedPacketPopView *)conversionPopViewWithConversionString:(NSString *)conversionString promptString:(NSString *)promptString sureHandler:(void(^)(void))sureHandler cancelHandle:(void(^)(void))cancelHandle {
    WTVRedPacketPopView *popView = [[WTVRedPacketPopView alloc]init];
    popView.sureHandler = sureHandler;
    popView.cancelHandle = cancelHandle;
    popView.popViewType = WTVRedPacketPopViewConversionSomething;
    popView.conversionString = conversionString;
    popView.conversionDetailLabel.text = promptString;
    [popView addToKeyWindow];
    [popView showAnimation];
    return popView;
}

- (void)addToKeyWindow {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (void)conversionSuccess {
    if (self.popViewType != WTVRedPacketPopViewConversionSomething) {
        return;
    }
    _popViewType = WTVRedPacketPopViewConversionSuccess;
    self.bigTitleLabel.text = @"恭喜您";
    self.contentTopLabel.text = @"已经受理";
    self.contentBottomLabel.text = @"我们将在活动规则规定的时候与您联系~";
    [_topSureBtn setBackgroundImage:[UIImage imageNamed:@"me_popup_btn_zhidao"] forState:UIControlStateNormal];
    _conversionDetailLabel.hidden = YES;
}

- (void)conversionFail {
    if (self.popViewType != WTVRedPacketPopViewConversionSomething) {
        return;
    }
    _popViewType = WTVRedPacketPopViewConversionFail;
    self.redPacketImageView.image = [UIImage imageNamed:@"popup_bg_no_prize"];
    self.bigTitleLabel.text = @"真遗憾！";
    self.contentTopLabel.text = @"兑换失败";
    self.contentBottomLabel.text = @"您可以再来一次！";
    [_topSureBtn setBackgroundImage:[UIImage imageNamed:@"me_popup_btn_zhidao"] forState:UIControlStateNormal];
    _conversionDetailLabel.hidden = YES;
}

- (void)shareSuccess:(BOOL)isGive {
    if (self.popViewType != WTVRedPacketPopViewShare) {
        return;
    }
    _popViewType = WTVRedPacketPopViewShareSuccess;
    _shareView.hidden = YES;
    self.bigTitleLabel.hidden = YES;
    self.contentTopLabel.font = [UIFont systemFontOfSize:self.contentTopLabel.font.pointSize - 5];
    self.contentTopLabel.text = isGive ? @"神犬已送出！" : @"讨要完成，等待收货！";
    self.contentBottomLabel.text = @"";
    _contentImageView.hidden = NO;
    _topSureBtn.hidden = NO;
    [_topSureBtn setBackgroundImage:[UIImage imageNamed:@"me_popup_btn_zhidao"] forState:UIControlStateNormal];
    _conversionDetailLabel.hidden = YES;
}

- (void)setIsRequesting:(BOOL)isRequest {
    for (UIView *subview in self.subviews) {
        subview.userInteractionEnabled = !isRequest;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBase];
    }
    return self;
}
- (void)setBase {
    self.backgroundColor = [UIColor jp_colorWithHexString:@"000000" alpha:0];
    _cancleBtn = ({
        UIButton *btn = [[UIButton alloc]init];
        [btn setBackgroundImage:[UIImage imageNamed:@"red_icon_closed"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });

    [self addSubview:_cancleBtn];

    [_cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-20));
        make.top.equalTo(self);
    }];
}

- (void)setContentImageViewWithType:(WTVRedPacketPopViewType)type {
    
    __block NSString *topTitle = self.conversionString;
    __block NSString *bottomTitle = @"";
    
    void (^setContentLabelText)(void) = ^{
        switch (type) {
                
            case WTVRedPacketPopViewShareSuccess:
                topTitle = @"分享成功";
                bottomTitle = @"请关注下一场红包雨抢大礼包哦~";
                break;
            case WTVRedPacketPopViewConversionFail:
                topTitle = @"兑换失败";
                bottomTitle = @"您可以再试一次！";
                break;
            case WTVRedPacketPopViewConversionSuccess:
                topTitle = @"已经受理";
                bottomTitle = @"我们将在活动规则规定的时候与您联系~";
                break;
                
            case WTVRedPacketPopViewNeedLogin:
                topTitle = @"本活动仅限已捆绑手机号用户参加";
                bottomTitle = @"微信用户可在“个人中心”捆绑手机号";
                break;
                
            default:
                break;
        }
        
        self.contentTopLabel.text = topTitle;
        self.contentBottomLabel.text = bottomTitle;
    };
    
    if (type == WTVRedPacketPopViewNeedLogin) {
        if (!_contentTopLabel) {
            _contentTopLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.font = [UIFont systemFontOfSize:15];
                aLabel.textColor = JPRGBColor(255, 208, 126);
                aLabel;
            });
            _contentTopLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        if (!_contentBottomLabel) {
            _contentBottomLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.font = [UIFont systemFontOfSize:15];
                aLabel.textColor = JPRGBColor(255, 208, 126);
                aLabel;
            });
            _contentBottomLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        setContentLabelText();
        
        [self.redPacketImageView addSubview:self.contentTopLabel];
        [self.redPacketImageView addSubview:self.contentBottomLabel];
        
        [_contentTopLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.redPacketImageView);
            make.top.equalTo(self.bigTitleLabel.mas_bottom).offset(12);
        }];
        
        [_contentBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentTopLabel.mas_bottom).offset(8);
            make.centerX.equalTo(self.redPacketImageView);
        }];
        
        UIButton * (^needLoginCreateBtn)(NSString *title, SEL action) = ^(NSString *title, SEL action) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:JPRGBColor(79, 49, 37) forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 20;
            btn.layer.borderColor = JPRGBColor(255, 176, 51).CGColor;
            btn.layer.borderWidth = 1;
            return btn;
        };
        
        UIButton *noLoginBtn = needLoginCreateBtn(@"暂不参加", @selector(noLogin));
        [self.redPacketImageView addSubview:noLoginBtn];
        self.noLoginBtn = noLoginBtn;
        
        UIButton *goLoginBtn = needLoginCreateBtn(@"重新登录", @selector(goLogin));
        [self.redPacketImageView addSubview:goLoginBtn];
        self.goLoginBtn = goLoginBtn;
        
        [noLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@30);
            make.bottom.equalTo(@(-20));
            make.height.equalTo(@40);
        }];
        
        [goLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.equalTo(noLoginBtn);
            make.left.equalTo(noLoginBtn.mas_right).offset(20);
            make.right.equalTo(@(-30));
        }];
        
    } else {
        
        if (!_contentImageView) {
            _contentImageView = [[UIImageView alloc]init];
            _contentImageView.image = [UIImage imageNamed:@"me_popup_bg_prize"];
        }
        
        if (!_contentTopLabel) {
            _contentTopLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.font = [UIFont systemFontOfSize:24];
                aLabel.textColor = [UIColor whiteColor];
                aLabel;
            });
            _contentTopLabel.textAlignment = NSTextAlignmentCenter;
            _contentTopLabel.numberOfLines = 2;
            [_contentTopLabel sizeToFit];
        }
        
        if (!_contentBottomLabel) {
            _contentBottomLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.font = [UIFont systemFontOfSize:10];
                aLabel.textColor = [UIColor whiteColor];
                aLabel;
            });
            _contentBottomLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        
        if (!_conversionDetailLabel) {
            _conversionDetailLabel = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.font = [UIFont systemFontOfSize:10];
                aLabel.textColor = JPRGBColor(254,191,71);
                aLabel.text = @"您只能参与一次神犬奖品的兑换哦！";
                aLabel;
            });
            _conversionDetailLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        [self.redPacketImageView addSubview:_contentImageView];
        [self.contentImageView addSubview:self.contentTopLabel];
        [self.contentImageView addSubview:self.contentBottomLabel];
        [self.redPacketImageView addSubview:_conversionDetailLabel];
        
        setContentLabelText();
        
        [_contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.redPacketImageView);
            make.top.equalTo(@170);
        }];
        
        [_contentTopLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(@150);
            
            make.centerX.equalTo(self.contentImageView);
            if (type == WTVRedPacketPopViewConversionSomething) {
                make.center.equalTo(self.contentImageView);
            }else{
                make.centerY.equalTo(self.contentImageView).offset(-5);
            }
            
            
        }];
        
        [_contentBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(@(-37));
            make.centerX.equalTo(self.contentImageView);
        }];
        
        
        [_conversionDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(@(-6));
            make.centerX.equalTo(self.redPacketImageView);
        }];
        
        _contentImageView.hidden = (type == WTVRedPacketPopViewShare);
        _conversionDetailLabel.hidden = !(type == WTVRedPacketPopViewConversionSomething);
        
    }
}

- (void)noLogin {
    [self destorySelfAction];
    !self.cancelHandle ? : self.cancelHandle();
}

- (void)goLogin {
    [self destorySelfAction];
    !self.sureHandler ? : self.sureHandler();
}

- (void)setShareView {
    
    if (!_shareView) {
        _shareView = [[UIView alloc]init];
        NSArray *shareLogo = [[NSArray alloc] initWithObjects:@"share_wechat",@"share_friends",@"share_weibo",@"share_qq", nil];
        NSArray *shareTitle = [[NSArray alloc] initWithObjects:@"微信好友",@"朋友圈",@"新浪微博",@"QQ好友", nil];
        
        UIImage *image = [UIImage imageNamed:shareLogo.firstObject];
        NSString *title = shareTitle.firstObject;
        
        UIFont *font = [UIFont systemFontOfSize:12];
        
        CGFloat btnW = MAX([title sizeWithFont:font].width, image.size.width);
        CGFloat totalH = btnW + 15  + [@"" sizeWithFont:font].height ;
        
        CGFloat bgW = 315;
        CGFloat margin = (bgW - btnW * shareTitle.count)/(shareTitle.count + 1);
        
        for (int i = 0; i < shareLogo.count; i++) {
            
            NSString *imageName = [shareLogo objectAtIndex:i];
            NSString *text = [shareTitle objectAtIndex:i];
            
            UIButton *btn = [[UIButton alloc] init];
            btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            btn.jp_width = btnW;
            btn.jp_height = totalH;
            btn.jp_x = margin + (btnW + margin) * i;
//            btn.buttonPositionStyle = BAButtonPositionStyleTop;
//            btn.padding = 10;
            [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            btn.tag = 3000 + i;
            btn.titleLabel.font = font;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitle:text forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
            [_shareView addSubview:btn];
        }
        
    }
  
    [self.redPacketImageView addSubview:_shareView];
    
    [_shareView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(_bigTitleLabel.mas_bottom).offset(20);
        make.left.right.bottom.equalTo(self.redPacketImageView);
    }];
    
    
}
- (void)setSureBtnWithType:(WTVRedPacketPopViewType)type {
    
    if (!_topSureBtn) {
        _topSureBtn = [[UIButton alloc] init];
        [_topSureBtn addTarget:self action:@selector(topSoureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSString *name = @"";
    switch (type) {
        case WTVRedPacketPopViewConversionSomething:
            name = @"me_popup_btn_exchange";
             break;

        case WTVRedPacketPopViewConversionFail:
        case WTVRedPacketPopViewShareSuccess:
        case WTVRedPacketPopViewConversionSuccess:
            name = @"me_popup_btn_zhidao";
            
            break;
            
        default:
            break;
    }
    
    [_topSureBtn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [self.redPacketImageView addSubview:_topSureBtn];
    
    _topSureBtn.hidden = (type == WTVRedPacketPopViewShare);
    [_topSureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(@(-20));
        make.centerX.equalTo(self.redPacketImageView);
    }];
}
- (void)setBgImageViewWithType:(WTVRedPacketPopViewType)type {
    
    NSString *name = @"popup_bg_huojiang";
    
    if (!_redPacketImageView) {
        _redPacketImageView = ({
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.userInteractionEnabled = YES;
            imageView;
        });
    }
    name = (type== WTVRedPacketPopViewConversionFail)?@"popup_bg_no_prize":name;
    
    _redPacketImageView.image = [UIImage imageNamed:name];
    
    [self addSubview:_redPacketImageView];
    [_redPacketImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self);
    }];
    
}

- (void)setLabelWithType:(WTVRedPacketPopViewType)type {
    
    UIFont *font = [UIFont systemFontOfSize:16];
    if (type == WTVRedPacketPopViewNeedLogin) {
        font = [UIFont boldSystemFontOfSize:25];
    }
    
    if (!_bigTitleLabel) {
        _bigTitleLabel = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.font = font;
            aLabel.textColor = [UIColor whiteColor];
            aLabel;
        });
        [self.redPacketImageView addSubview:_bigTitleLabel];
    }
    
    
    CGFloat top = 175;
    
    NSString *text = @"";
    
    switch (type) {
        case WTVRedPacketPopViewShare:
            font = [UIFont boldSystemFontOfSize:21];
            text = @"向好友讨神犬";
            top = 193;
            
             break;
        case WTVRedPacketPopViewShareSuccess:
             break;
        case WTVRedPacketPopViewConversionFail:
            text = @"真遗憾";
            break;
        case WTVRedPacketPopViewConversionSuccess:
            text = @"恭喜您";
            
             break;
        case WTVRedPacketPopViewConversionSomething:
             text = @"亲，确认要兑换";
            break;
            
        case WTVRedPacketPopViewNeedLogin:
            text = @"活动规则";
            break;
            
        default:
            break;
    }
    
    self.bigTitleLabel.hidden = (type ==WTVRedPacketPopViewShareSuccess);
    
    self.bigTitleLabel.text = text;
    self.bigTitleLabel.font = font;
    
    [self.bigTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.redPacketImageView);
        make.top.equalTo(@(top));
    }];
    
    
}

#pragma mark - setter
- (void)setConversionString:(NSString *)conversionString {
    
    _conversionString = conversionString;
    self.popViewType = _popViewType;
}
- (void)setPopViewType:(WTVRedPacketPopViewType)popViewType {
    
    _popViewType = popViewType;
    
    [self setBgImageViewWithType:popViewType];
    [self setLabelWithType:popViewType];
    [self setContentImageViewWithType:popViewType];
    [self setSureBtnWithType:popViewType];
    
    if (popViewType == WTVRedPacketPopViewShare) {
        [self setShareView];
    }else{
        _shareView.hidden = YES;
    }
    
    self.redPacketImageView.transform = CGAffineTransformMakeScale(0.00, 0.00);
    
//    [self showAnimation];
    self.cancleBtn.hidden = YES;
    
}

#pragma mark - selector
- (void)closeAction {
    [self destorySelfAction];
    !self.cancelHandle ? : self.cancelHandle();
}

- (void)topSoureBtnAction {
    
    if (self.popViewType == WTVRedPacketPopViewConversionSomething) {
        if (self.sureHandler) {
            self.sureHandler();
        }
    }else{
        [self destorySelfAction];
    }
}

- (void)shareAction:(UIButton*)btn {
    
//    UMSocialPlatformType shareType = UMSocialPlatformType_UnKnown;
//    switch (btn.tag) {
//
//        case 3000: shareType = UMSocialPlatformType_WechatSession;
//
//            if (![WXApi isWXAppInstalled]) {
//                [self showToastCenterWithTip:@"您没有安装微信"];
//                return;
//            }
//
//            break;
//        case 3001: shareType = UMSocialPlatformType_WechatTimeLine;
//            if (![WXApi isWXAppInstalled]) {
//                [self showToastCenterWithTip:@"您没有安装微信"];
//                return;
//            }
//
//            break;
//        case 3002: shareType = UMSocialPlatformType_Sina;
//            if ( ![WeiboSDK isWeiboAppInstalled]) {
//                [self showToastCenterWithTip:@"您没有安装微博"];
//                return;
//            }
//
//            break;
//        case 3003: shareType = UMSocialPlatformType_QQ;
//
//            if ( ![QQApiInterface isQQInstalled]) {
//                [self showToastCenterWithTip:@"您没有安装QQ"];
//                return;
//            }
//
//            break;
//        default: break;
//    }
//
//    if (self.dataRequestHandle) {
//
//        @jp_weakify(self);
//        RedPackageRainShareHandle shareHandle = ^(WTVShareModel *model) {
//            @jp_strongify(self);
//            if (!self) return;
//
//            [JPWebImageManager downloadImageWithURL:[NSURL URLWithString:model.icon] options:kNilOptions progress:nil transform:nil completed:^(UIImage *image, NSError *error, NSURL *imageURL, JPWebImageFromType jp_fromType, JPWebImageStage jp_stage) {
//                UIImage *shareImage = image;
//                if (!shareImage) {
//                    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
//                    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
//                    shareImage = [UIImage imageNamed:icon];
//                }
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [WTVShareTool shareWithTitle:model.title url:model.urlStr shareName:model.des shareImage:shareImage platformType:shareType shareCallBack:^(BOOL shareSuccess) {
//
//                    }];
//                });
//            }];
//        };
//
//        self.dataRequestHandle(shareType, shareHandle);
//    }
 
}


- (void)showAnimation {
    
    [UIView animateWithDuration:0.25f
                          delay:0.25f
         usingSpringWithDamping:YES
          initialSpringVelocity:0.2f
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         
                         self.redPacketImageView.transform = CGAffineTransformMakeScale(1, 1);
                         
                         
                         
                     } completion:^(BOOL finished) {
                         self.cancleBtn.hidden = NO;
                     }];
    
    
    [self jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewBackgroundColor toValue:[UIColor jp_colorWithHexString:@"000000" alpha:0.3f] duration:0.25 completionBlock:nil];
    
}
- (void)destorySelfAction {
    self.userInteractionEnabled = NO;
    
    self.redPacketImageView.transform = CGAffineTransformMakeScale(1, 1);
    
    [UIView animateWithDuration:0.25f
                          delay:0
         usingSpringWithDamping:YES
          initialSpringVelocity:0.2f
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         
                         self.redPacketImageView.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
                         
                         
                     } completion:^(BOOL finished) {
                         
                         [self removeFromSuperview];
                     }];
    
    [self jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewBackgroundColor  toValue:[UIColor jp_colorWithHexString:@"000000" alpha:0] duration:0.25 completionBlock:nil];
}

//#pragma mark - UMDelegate
//
//-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
//    !self.responseHandler ? :self.responseHandler(response);
//}



@end
