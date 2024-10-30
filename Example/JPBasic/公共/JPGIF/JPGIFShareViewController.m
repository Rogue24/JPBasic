//
//  JPGIFShareViewController.m
//  WoTV
//
//  Created by 周健平 on 2019/12/23.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import "JPGIFShareViewController.h"
#import <Photos/Photos.h>
#import "YYWebImage.h"
#import "JPCustomLayoutButton.h"
#import "JPPhotoTool.h"

@interface JPGIFShareViewController ()
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, weak) UIVisualEffectView *blurView;
@property (nonatomic, weak) YYAnimatedImageView *animView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIActivityIndicatorView *jvhua;
@property (nonatomic, weak) JPCustomLayoutButton *wechatBtn;
@property (nonatomic, weak) JPCustomLayoutButton *qqBtn;
@property (nonatomic, weak) JPCustomLayoutButton *weiboBtn;
@property (nonatomic, weak) JPCustomLayoutButton *saveBtn;
@property (nonatomic, weak) UIButton *closeBtn;

@property (nonatomic, strong) NSURL *gifFileURL;
@property (nonatomic, copy) void (^dismissBlock)(void);

@property (nonatomic, assign) BOOL isCreating;
@property (nonatomic, assign) BOOL isCreateFaild;
@end

@implementation JPGIFShareViewController
{
    CGFloat _viewW;
    CGFloat _viewH;
}

#pragma mark - setter

- (void)setGifFilePath:(NSString *)gifFilePath {
    self.isCreating = NO;
    self.isCreateFaild = NO;
    
    _gifFilePath = gifFilePath.copy;
    _gifFileURL = [NSURL fileURLWithPath:gifFilePath];
    
    [self.animView yy_setImageWithURL:_gifFileURL placeholder:self.placeholder options:(YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionIgnoreDiskCache) completion:nil];
    
    [self.jvhua stopAnimating];
    [UIView transitionWithView:self.titleLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.titleLabel.text = @"分享GIF至";
    } completion:nil];
    
    [UIView transitionWithView:self.closeBtn duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.closeBtn.hidden = NO;
    } completion:nil];
    
    self.wechatBtn.userInteractionEnabled = YES;
    self.qqBtn.userInteractionEnabled = YES;
    self.weiboBtn.userInteractionEnabled = YES;
    self.saveBtn.userInteractionEnabled = YES;
}

- (void)createFaild {
    self.isCreating = NO;
    self.isCreateFaild = YES;
    
    [self.jvhua stopAnimating];
    [UIView transitionWithView:self.titleLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.titleLabel.text = @"GIF生成失败";
    } completion:nil];
    
    [UIView transitionWithView:self.closeBtn duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.closeBtn.hidden = NO;
    } completion:nil];
}

#pragma mark - getter

- (BOOL)isPortrait {
    return _viewW < _viewH;
}

#pragma mark - 创建方法

+ (instancetype)showGIFShareVcWithPlaceholder:(UIImage *)placeholder isPortrait:(BOOL)isPortrait dismissBlock:(void (^)(void))dismissBlock {
    JPGIFShareViewController *gifVC = [[JPGIFShareViewController alloc] initWithPlaceholder:placeholder isPortrait:isPortrait dismissBlock:dismissBlock];
    
    if (isPortrait != JPScreenRotationTool.sharedInstance.isPortrait) {
        if (!isPortrait) {
            JPScreenRotationTool.sharedInstance.isLockOrientationWhenDeviceOrientationDidChange = NO;
            JPScreenRotationTool.sharedInstance.isLockLandscapeWhenDeviceOrientationDidChange = YES;
        }
        [JPScreenRotationTool.sharedInstance toggleOrientation];
    }
    
    [[UIWindow jp_topViewControllerFromDelegateWindow] presentViewController:gifVC animated:NO completion:^{
        // 要等下一个循环才能获取旋转之后的屏幕信息
        dispatch_async(dispatch_get_main_queue(), ^{
            [gifVC show];
        });
    }];
    return gifVC;
}

- (instancetype)initWithPlaceholder:(UIImage *)placeholder isPortrait:(BOOL)isPortrait dismissBlock:(void (^)(void))dismissBlock {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen | UIModalPresentationCustom;
        if (isPortrait) {
            _viewW = JPPortraitScreenWidth;
            _viewH = JPPortraitScreenHeight;
        } else {
            _viewW = JPLandscapeScreenWidth;
            _viewH = JPLandscapeScreenHeight;
        }
        self.placeholder = placeholder;
        self.dismissBlock = dismissBlock;
        self.isCreating = YES;
        [self willShow];
    }
    return self;
}

- (JPCustomLayoutButton *)createBtnWithTitle:(NSString *)title imageName:(NSString *)imageName {
    JPCustomLayoutButton *btn = [JPCustomLayoutButton buttonWithType:UIButtonTypeSystem];
    [btn setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.titleLabel.font = JPScaleFont(12);
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    CGFloat imageWH = JPScaleValue(50);
    CGFloat titleW = JPScaleValue(70);
    CGFloat titleH = JPScaleValue(17);
    
    CGFloat w = imageWH;
    CGFloat h = w + JPScaleValue(4) + titleH;
    
    btn.layoutSubviewsBlock = ^(UIButton *kBtn) {
        kBtn.imageView.frame = CGRectMake(0, 0, imageWH, imageWH);
        kBtn.titleLabel.frame = CGRectMake(JPHalfOfDiff(w, titleW), h - titleH, titleW, titleH);
    };
    
    btn.jp_size = CGSizeMake(w, h);
    
    return btn;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBlurView];
    [self setupAnimView];
    [self setupBottomPart];
    
    UIButton *closeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setImage:[[UIImage imageNamed:@"find_close_white_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        if (self.isPortrait) {
            btn.frame = CGRectMake(JP12Margin, JPStatusBarH, 44, 44);
        } else {
            btn.frame = CGRectMake(JPDiffStatusBarH + JP12Margin, JP12Margin, 44, 44);
        }
        btn;
    });
    [self.view addSubview:closeBtn];
    self.closeBtn = closeBtn;
    self.closeBtn.hidden = YES;
}

- (void)dealloc {
    JPLog(@"老子死了");
    [self.animView yy_cancelCurrentImageRequest];
    if (self.gifFileURL) [[YYWebImageManager sharedManager].cache removeImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:self.gifFileURL]];
}

#pragma mark - 初始布局

- (void)setupBlurView {
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
    blurView.frame = CGRectMake(0, 0, _viewW, _viewH);
    blurView.layer.masksToBounds = YES;
    [self.view addSubview:blurView];
    self.blurView = blurView;
}

- (void)setupAnimView {
    CGFloat maxW = JPScaleValue(328);
    CGFloat maxH = maxW * (9.0 / 16.0);
    
    CGFloat w;
    CGFloat h;
    if (self.placeholder) {
        CGFloat imageW = self.placeholder.size.width;
        CGFloat imageH = self.placeholder.size.height;
        if (imageW >= imageH) {
            w = maxW;
            h = w * (imageH / imageW);
            if (h > imageH) {
                h = maxH;
                w = h * (imageW / imageH);
            }
        } else {
            h = maxH;
            w = h * (imageW / imageH);
            if (w > imageW) {
                w = maxW;
                h = w * (imageH / imageW);
            }
        }
    } else {
        w = maxW;
        h = maxH;
    }
    CGFloat x = JPHalfOfDiff(_viewW, w);
    CGFloat y = JPHalfOfDiff(_viewH, h + JPScaleValue(15 + 21 + 15 + 50 + 4 + 17));
    
    YYAnimatedImageView *animView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    animView.contentMode = UIViewContentModeScaleAspectFit;
    animView.backgroundColor = JPRandomColor;
    animView.layer.cornerRadius = JPScaleValue(4);
    animView.layer.masksToBounds = YES;
    animView.image = self.placeholder;
    [self.view addSubview:animView];
    self.animView = animView;
}

- (void)setupBottomPart {
    UILabel *titleLabel = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.font = JPScaleFont(15);
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.textColor = UIColor.whiteColor;
        aLabel.text = @"正在生成GIF中...";
        aLabel;
    });
    CGFloat w = self.animView.jp_width;
    CGFloat h = JPScaleValue(21);
    w = [titleLabel sizeThatFits:CGSizeMake(w, h)].width;
    CGFloat x = JPHalfOfDiff(_viewW, w);
    CGFloat y = self.animView.jp_maxY + JPScaleValue(15);
    titleLabel.frame = CGRectMake(x, y, w, h);
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIActivityIndicatorView *jvhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:jvhua];
    [jvhua mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(titleLabel.mas_left).offset(-8);
    }];
    jvhua.hidesWhenStopped = YES;
    [jvhua startAnimating];
    self.jvhua = jvhua;
    
    JPCustomLayoutButton *wechatBtn = [self createBtnWithTitle:@"微信好友" imageName:@"watch"];
    JPCustomLayoutButton *qqBtn = [self createBtnWithTitle:@"QQ好友" imageName:@"qq"];
    JPCustomLayoutButton *weiboBtn = [self createBtnWithTitle:@"新浪微博" imageName:@"sina microblog"];
    JPCustomLayoutButton *saveBtn = [self createBtnWithTitle:@"保存到本地" imageName:@"download"];

    CGFloat space = JPScaleValue(24);
    CGFloat margin = (self.animView.jp_width - wechatBtn.jp_width * 4 - space * 3) * 0.5;
    
    y = titleLabel.jp_maxY + JPScaleValue(15);
    
    x = self.animView.jp_x + margin;
    wechatBtn.jp_origin = CGPointMake(x, y);
    
    x += (wechatBtn.jp_width + space);
    qqBtn.jp_origin = CGPointMake(x, y);
    
    x += (wechatBtn.jp_width + space);
    weiboBtn.jp_origin = CGPointMake(x, y);
    
    x += (wechatBtn.jp_width + space);
    saveBtn.jp_origin = CGPointMake(x, y);
    
    wechatBtn.tag = 0;
    [wechatBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wechatBtn];
    self.wechatBtn = wechatBtn;
    
    qqBtn.tag = 1;
    [qqBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qqBtn];
    self.qqBtn = qqBtn;
    
    weiboBtn.tag = 2;
    [weiboBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:weiboBtn];
    self.weiboBtn = weiboBtn;
    
    saveBtn.tag = 3;
    [saveBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    self.saveBtn = saveBtn;
    
    self.wechatBtn.userInteractionEnabled = NO;
    self.qqBtn.userInteractionEnabled = NO;
    self.weiboBtn.userInteractionEnabled = NO;
    self.saveBtn.userInteractionEnabled = NO;
}

#pragma mark - 通知方法

#pragma mark - 事件触发方法

- (void)shareAction:(UIButton *)btn {
    if (btn.tag > 2) {
        JPLog(@"保存相册");
        @jp_weakify(self);
        [JPPhotoToolSI albumAccessAuthorityWithAllowAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            NSError *error;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:self.gifFileURL];
            } error:&error];
            if (error) {
                [JPProgressHUD showErrorWithStatus:@"保存失败" userInteractionEnabled:YES];
            } else {
                [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
                [self close];
            }
        } refuseAccessAuthorityHandler:nil alreadyRefuseAccessAuthorityHandler:nil canNotAccessAuthorityHandler:nil isRegisterChange:NO];
        return;
    }
    
//    UMSocialPlatformType platformType;
//    NSString *operateValue;
//    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
//    switch (btn.tag) {
//        case 0:
//        {
//            platformType = UMSocialPlatformType_WechatSession;
//            operateValue = @"微信";
//            UMShareEmotionObject *shareObject = [UMShareEmotionObject shareObjectWithTitle:nil descr:nil thumImage:self.placeholder];
//            NSData *gifData = [NSData dataWithContentsOfFile:self.gifFilePath];
//            shareObject.emotionData = gifData;
//            messageObject.shareObject = shareObject;
//            break;
//        }
//        case 1:
//        {
//            platformType = UMSocialPlatformType_QQ;
//            operateValue = @"QQ好友";
//            UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:nil descr:nil thumImage:self.placeholder];
//            NSData *gifData = [NSData dataWithContentsOfFile:self.gifFilePath];
//            shareObject.shareImage = gifData;
//            messageObject.shareObject = shareObject;
//            break;
//        }
//        case 2:
//        {
//            platformType = UMSocialPlatformType_Sina;
//            operateValue = @"新浪微博";
//            UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:nil descr:nil thumImage:self.placeholder];
//            shareObject.shareImage = self.placeholder;
//            messageObject.shareObject = shareObject;
//            messageObject.text = @"沃视频开启未来新视界";
//            break;
//        }
//        default:
//            return;
//    }
//
//    @jp_weakify(self);
//    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:MyTools.topVC completion:^(id data, NSError *error) {
//        @jp_strongify(self);
//        if (!self) return;
//        if (error) {
//            NSLog(@"************Share fail with error %@*********",error);
//            [JPProgressHUD showErrorWithStatus:@"分享失败" userInteractionEnabled:YES]
//        } else {
//            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
////                UMSocialShareResponse *resp = data;
////                //分享结果消息
////                UMSocialLogInfo(@"response message is %@",resp.message);
////                //第三方原始返回的数据
////                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
//                [JPProgressHUD showSuccessWithStatus:@"分享成功" userInteractionEnabled:YES];
//                [self close];
//            } else {
////                UMSocialLogInfo(@"response data is %@",data);
//            }
//        }
//    }];
}

#pragma mark - 私有方法

- (void)willShow {
    self.view.userInteractionEnabled = NO;
    [self.view layoutIfNeeded];
    
    self.animView.layer.transform = CATransform3DMakeTranslation(0, -100, 0);
    self.animView.layer.opacity = 0;
    
    self.titleLabel.layer.opacity = 0;
    self.jvhua.layer.opacity = 0;
    
    self.wechatBtn.layer.opacity = 0;
    self.qqBtn.layer.opacity = 0;
    self.weiboBtn.layer.opacity = 0;
    self.saveBtn.layer.opacity = 0;
    
    CGFloat scale = 0.6;
    self.wechatBtn.layer.transform = CATransform3DMakeScale(scale, scale, 1);
    self.qqBtn.layer.transform = CATransform3DMakeScale(scale, scale, 1);
    self.weiboBtn.layer.transform = CATransform3DMakeScale(scale, scale, 1);
    self.saveBtn.layer.transform = CATransform3DMakeScale(scale, scale, 1);
}

- (void)show {
    [UIView animateWithDuration:1.0 animations:^{
        self.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }];
    [UIView animateWithDuration:0.8 delay:0.2 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        self.animView.layer.transform = CATransform3DIdentity;
        self.animView.layer.opacity = 1;
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.3 options:kNilOptions animations:^{
        self.titleLabel.layer.opacity = 1;
        self.jvhua.layer.opacity = 1;
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        self.wechatBtn.layer.opacity = 1;
        self.qqBtn.layer.opacity = 1;
        self.weiboBtn.layer.opacity = 1;
        self.saveBtn.layer.opacity = 1;
        
        self.wechatBtn.layer.transform = CATransform3DIdentity;
        self.qqBtn.layer.transform = CATransform3DIdentity;
        self.weiboBtn.layer.transform = CATransform3DIdentity;
        self.saveBtn.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)close {
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.blurView.effect = nil;
    }];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        self.animView.layer.opacity = 0;
        self.titleLabel.layer.opacity = 0;
        self.jvhua.layer.opacity = 0;
        self.closeBtn.layer.opacity = 0;
        
        self.wechatBtn.layer.opacity = 0;
        self.qqBtn.layer.opacity = 0;
        self.weiboBtn.layer.opacity = 0;
        self.saveBtn.layer.opacity = 0;
        
        CGFloat scale = 0.6;
        self.wechatBtn.layer.transform = CATransform3DMakeScale(scale, scale, 1);
        self.qqBtn.layer.transform = CATransform3DMakeScale(scale, scale, 1);
        self.weiboBtn.layer.transform = CATransform3DMakeScale(scale, scale, 1);
        self.saveBtn.layer.transform = CATransform3DMakeScale(scale, scale, 1);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:self.dismissBlock];
    }];
}

@end
