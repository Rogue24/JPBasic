//
//  WLRecordConfirmViewController.m
//  WoLive
//
//  Created by 周健平 on 2020/3/30.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import "WLRecordConfirmViewController.h"
#import <AVKit/AVKit.h>
#import "JPSystemImagePickerTool.h"
#import "WLVideoInterceptionViewController.h"
#import "WLBlurButton.h"
#import "UIImage+JPExtension.h"
#import "JPPhotoTool.h"
#import "JPTextView.h"
#import "WLBlurButton.h"

CGFloat const WLImageMaxPixelWidth = 750.0; // 这是服务器能接受的最大像素值？

@interface WLRecordConfirmViewController () <AVPlayerViewControllerDelegate>
@property (nonatomic, weak) UIImageView *coverImageView;
@property (nonatomic, weak) JPTextView *textView;
@property (nonatomic, weak) UILabel *countLabel;
@property (nonatomic, weak) UIButton *saveBtn;
@property (nonatomic, weak) UIButton *saveAlbumBtn;
@property (nonatomic, weak) UIButton *sendBtn;
@property (nonatomic, assign) BOOL isCanSave;
@property (nonatomic, assign) BOOL isCanSend;
@property (readwrite) UIImage *coverImage;
@property (nonatomic, strong) WLVideoInterceptionTool *interceptionTool;

@property (nonatomic, copy) NSString *originTitle;
@property (nonatomic, strong) UIImage *originCover;
@property (nonatomic, assign) BOOL isChangeTitle;
@property (nonatomic, assign) BOOL isChangeCover;

@property (nonatomic, assign) BOOL isAskedAlbumAccessAuthority;
@property (nonatomic, assign) BOOL albumAccessAuthority;
@end

@implementation WLRecordConfirmViewController
{
    BOOL _isDidAppear;
}

#pragma mark - 常量

#pragma mark - setter

- (void)setCoverImage:(UIImage *)coverImage {
    if (!coverImage) {
        [JPProgressHUD showErrorWithStatus:@"封面设置失败" userInteractionEnabled:YES];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [coverImage jp_cgResizeImageWithPixelWidth:WLImageMaxPixelWidth];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                if (!self.originCover) self.originCover = image;
                [UIView transitionWithView:self.coverImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.coverImageView.image = image;
                } completion:nil];
                [self __checkIsCanSaveAndSend];
            } else {
                [JPProgressHUD showErrorWithStatus:@"封面设置失败" userInteractionEnabled:YES];
            }
        });
    });
}

#pragma mark - getter

- (NSURL *)videoURL {
    if (!_videoURL) {
        _videoURL = [NSURL fileURLWithPath:JPMainBundleResourcePath(@"testVideo2", @"mp4")];
    }
    return _videoURL;
}

- (UIImage *)coverImage {
    return self.coverImageView.image;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupBase];
    [self __setupCoverImageView];
    [self __setupTextView];
    [self __setupSendButton];
    [self __setupInterceptionTool];
    [self __checkIsCanSaveAndSend];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
#pragma clang diagnostic pop
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isDidAppear) return;
    _isDidAppear = YES;
}

#pragma mark - 初始布局

- (void)__setupBase {
    self.title = @"编辑信息";
    self.view.backgroundColor = JPRGBColor(14, 14, 36);
    self.originTitle = @"";
}

- (void)__setupCoverImageView {
    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, JPNavTopMargin, JPPortraitScreenWidth, JPPortraitScreenWidth / (375.0 / 210.0))];
    coverImageView.backgroundColor = JPRGBColor(14, 14, 36);
    coverImageView.userInteractionEnabled = YES;
    [coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)]];
    coverImageView.clipsToBounds = YES;
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:coverImageView];
    self.coverImageView = coverImageView;
    
    CGFloat wh = JPScaleValue(50);
    WLBlurButton *playBtn = [WLBlurButton buttonWithType:UIButtonTypeSystem];
    [playBtn setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    playBtn.tintColor = JPRGBColor(207, 208, 227);
    playBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    playBtn.frame = CGRectMake(JPHalfOfDiff(coverImageView.jp_width, wh), JPHalfOfDiff(coverImageView.jp_height, wh), wh, wh);
    playBtn.layer.cornerRadius = wh * 0.5;
    playBtn.layer.masksToBounds = YES;
    playBtn.userInteractionEnabled = NO;
    [coverImageView addSubview:playBtn];
    
    UIButton *editBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = JPScaleFont(12);
        [btn setTitle:@"修改封面" forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(openSheet) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(coverImageView.jp_width - JP12Margin - JPScaleValue(65), coverImageView.jp_height - JP12Margin - JPScaleValue(26), JPScaleValue(65), JPScaleValue(26));
        btn.backgroundColor = JPRGBColor(56, 121, 242);
        btn.layer.cornerRadius = JPScaleValue(2);
        btn.layer.masksToBounds = YES;
        btn;
    });
    [coverImageView addSubview:editBtn];
}

- (void)__setupTextView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.coverImageView.jp_maxY, JPPortraitScreenWidth, JPPortraitScreenWidth * (150.0 / 375.0))];
    contentView.backgroundColor = JPRGBColor(35, 35, 55);
    [self.view addSubview:contentView];
    
    UILabel *countLabel = ({
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(JP12Margin, contentView.jp_height - JPScaleValue(16 + 16), contentView.jp_width - JP12Margin * 2, JPScaleValue(16))];
        aLabel.font = JPScaleFont(12);
        aLabel.textAlignment = NSTextAlignmentRight;
        aLabel.textColor = JPRGBColor(155, 155, 155);
        aLabel.text = @"0 / 30";
        aLabel;
    });
    [contentView addSubview:countLabel];
    self.countLabel = countLabel;
    
    JPTextView *textView = [[JPTextView alloc] initWithFrame:CGRectMake(JP12Margin, JPScaleValue(16), contentView.jp_width - JP12Margin * 2, countLabel.jp_y - JPScaleValue(16 + 16))];
    [textView jp_contentInsetAdjustmentNever];
    textView.font = JPScaleFont(15);
    textView.bounces = NO;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.contentOffset = CGPointZero;
    textView.backgroundColor = UIColor.clearColor;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    textView.textColor = JPRGBColor(207, 208, 227);
    textView.placeholderColor = JPRGBColor(118, 119, 138);
    textView.placeholder = @"输入视频话题";
    textView.maxLimitNums = 30;
    [contentView addSubview:textView];
    self.textView = textView;
    
    @jp_weakify(self);
    textView.textDidChange = ^(JPTextView *textView, BOOL isLenovo) {
        @jp_strongify(self);
        if (!self || isLenovo) return;
        self.countLabel.text = [NSString stringWithFormat:@"%zd / %zd", textView.text.length, textView.maxLimitNums];
        [self __checkIsCanSaveAndSend];
    };
    textView.reachMaxLimitNums = ^(NSInteger maxLimitNums) {
        @jp_strongify(self);
        if (!self) return;
        [JPProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"最多%zd字", maxLimitNums] userInteractionEnabled:YES];
    };
    textView.returnKeyDidClick = ^BOOL(JPTextView *textView, NSString *finalText) {
        @jp_strongify(self);
        if (self) [self.view endEditing:YES];
        return YES;
    };
    
    textView.text = self.originTitle;
}

- (void)__setupSendButton {
    CGFloat h = JPScaleValue(68) + JPDiffTabBarH;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, JPPortraitScreenHeight - h, JPPortraitScreenWidth, h)];
    bottomView.backgroundColor = JPRGBColor(35, 35, 55);
    bottomView.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
    bottomView.layer.shadowOpacity = 1.0;
    bottomView.layer.shadowRadius = 3.0;
    bottomView.layer.shadowOffset = CGSizeMake(0, -1);
    bottomView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(-50, 0, JPPortraitScreenWidth + 100, bottomView.jp_height)].CGPath;
    [self.view addSubview:bottomView];
    
    CGFloat x = JPScaleValue(12);
    UIColor *titleColor;
    if (@available(iOS 13.0, *)) {
        titleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return JPRGBColor(207, 208, 227);
            } else {
                return UIColor.whiteColor;
            }
        }];
    } else {
        titleColor = UIColor.whiteColor;
    }
    UIButton *sendBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(x, JPScaleValue(16), bottomView.jp_width - 2 * x, JPScaleValue(44));
        btn.titleLabel.font = JPScaleFont(15);
        btn.layer.cornerRadius = 2;
        btn.backgroundColor = JPRGBColor(51, 51, 74);
        [btn setTitle:@"立即发布" forState:UIControlStateNormal];
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    sendBtn.userInteractionEnabled = NO;
    [bottomView addSubview:sendBtn];
    self.sendBtn = sendBtn;
}

- (void)__setupInterceptionTool {
    self.interceptionTool = [[WLVideoInterceptionTool alloc] initWithVideoURL:self.videoURL];
    
    @jp_weakify(self);
    [self.interceptionTool asyncGetCoverImageWithTime:kCMTimeZero pixelWidth:WLImageMaxPixelWidth complete:^(UIImage *coverImage) {
        @jp_strongify(self);
        if (!self || !coverImage) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.coverImage = coverImage;
        });
    }];
}

#pragma mark - 通知方法

#pragma mark - 事件触发方法

- (void)playVideo {
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.videoGravity = AVLayerVideoGravityResizeAspect;
    playerVC.player = [[AVPlayer alloc] initWithURL:self.videoURL];
//    playerVC.delegate = self;
//    playerVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:playerVC animated:YES completion:^{
        [playerVC.player play];
    }];
}

- (void)openSheet {
    @jp_weakify(self);
    [JPSystemImagePickerTool openSystemImagePickerWithTitle:@"修改封面" message:nil options:JPSystemImagePickerAllOption otherAlertActions:@[
        [UIAlertAction actionWithTitle:@"视频截取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @jp_strongify(self);
            if (!self) return;
            WLVideoInterceptionViewController *viVC = [[WLVideoInterceptionViewController alloc] initWithInterceptionTool:self.interceptionTool imageresizerComplete:^(UIImage *resizeDoneImage) {
                self.coverImage = resizeDoneImage;
            }];
            [self.navigationController pushViewController:viVC animated:YES];
        }]
    ] resizeWHScale:375.0 / 210.0 isOriginImageresizer:YES willOpenImagePicker:^(UIImagePickerController *picker, BOOL isCamera) {
        
        if (!isCamera) {
            picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
            picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        }
        
    } willCloseImagePicker:^(UIImagePickerController *picker) {
        
    } didClosedImagePicker:^{
        
    } imagePickerComplete:^(NSURL *mediaURL, UIImage *image) {
        @jp_strongify(self);
        if (!self) return;
        
        if (image) {
            self.coverImage = image;
        } else {
            WLVideoInterceptionViewController *viVC = [[WLVideoInterceptionViewController alloc] initWithVideoURL:mediaURL imageresizerComplete:^(UIImage *resizeDoneImage) {
                self.coverImage = resizeDoneImage;
            }];
            [self.navigationController pushViewController:viVC animated:YES];
        }
        
    }];
}

- (void)saveAlbumAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    sender.layer.borderColor = sender.selected ? JPRGBAColor(255, 126, 0, 1).CGColor : JPRGBAColor(255, 126, 0, 0).CGColor;
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.toValue = @(CGPointMake(0.965, 0.965));
    anim.duration = 0.05;
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        POPSpringAnimation *sAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        sAnim.springSpeed = 20;
        sAnim.springBounciness = 15;
        sAnim.toValue = @(CGPointMake(1, 1));
        [sender.layer pop_addAnimation:sAnim forKey:kPOPLayerScaleXY];
    };
    [sender.layer pop_addAnimation:anim forKey:kPOPLayerScaleXY];
}

- (void)saveAction:(id)sender {
    JPLog(@"保存");
    [self.view endEditing:YES];
    BOOL isSend = sender == nil;
    if (!isSend) [JPProgressHUD showWithStatus:@"正在保存..."];
    NSString *title = self.textView.text;
    UIImage *coverImage = self.coverImage;
    NSTimeInterval delay = isSend ? 1.0 : 0.5;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.isChangeTitle) {
//            self.model.title = title;
//            [WLRecordModelTool saveModel:self.model];
        }
        if (self.isChangeCover) {
//            [WLRecordModelTool saveCover:coverImage to:self.model.coverFilePath];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (isSend) {
                [JPProgressHUD dismiss];
                [self jp_popVC];
                JPLog(@"接下来就是去发布的流畅咯~（待定）");
            } else {
                [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
                self.originTitle = title;
                self.originCover = coverImage;
                [self __checkIsCanSaveAndSend];
            }
        });
    });
}

- (void)sendAction {
    if (self.saveAlbumBtn.selected && !self.isAskedAlbumAccessAuthority) {
        self.isAskedAlbumAccessAuthority = YES;
        @jp_weakify(self);
        [JPPhotoToolSI albumAccessAuthorityWithAllowAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            self.albumAccessAuthority = YES;
            [self sendAction];
        } refuseAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            [self sendAction];
        } alreadyRefuseAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            [self sendAction];
        } canNotAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            [self sendAction];
        } isRegisterChange:NO];
        return;
    }
    
    JPLog(@"发布");
    if (!self.textView.text.jp_isNotEmpty) {
        [JPProgressHUD showInfoWithStatus:@"视频话题不能为空" userInteractionEnabled:YES];
        [self.textView becomeFirstResponder];
        return;
    }
    if (!self.coverImage) {
        [JPProgressHUD showInfoWithStatus:@"请设置封面" userInteractionEnabled:YES];
        return;
    }
    [JPProgressHUD showWithStatus:@"准备中..."];
    if (self.saveAlbumBtn.selected) {
        if (self.albumAccessAuthority) {
            [JPPhotoToolSI saveVideoToAppAlbumWithFileURL:self.videoURL successHandle:^(NSString *assetID) {
                JPLog(@"保存到相册成功");
            } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                JPLog(@"保存到相册失败");
            }];
        } else {
            JPLog(@"没有访问相册的权利");
        }
    }
    [self saveAction:nil];
}

#pragma mark - 重写父类方法

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - 私有方法

- (void)setIsCanSend:(BOOL)isCanSend {
    if (_isCanSend == isCanSend) return;
    _isCanSend = isCanSend;
    self.sendBtn.userInteractionEnabled = isCanSend;
    UIColor *color = isCanSend ? JPRGBColor(56, 121, 242) : JPRGBColor(51, 51, 74);
    [self.sendBtn jp_addPOPBasicAnimationWithPropertyNamed:kPOPViewBackgroundColor toValue:color duration:0.2 completionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) self.sendBtn.backgroundColor = color; // UIButton的记得在动画结束后调用方法再设置一下，因为动画修改的只是表象
    }];
}

- (void)__checkIsCanSaveAndSend {
    NSString *title = self.textView.text;
    UIImage *coverImage = self.coverImage;
    BOOL titleEmpty = !title.jp_isNotEmpty;
    BOOL nilCoverImage = coverImage == nil;
    
    self.isCanSend = !(titleEmpty || nilCoverImage);
}

#pragma mark - 公开方法





















#pragma mark - <AVPlayerViewControllerDelegate>

//- (void)playerViewController:(AVPlayerViewController *)playerViewController willBeginFullScreenPresentationWithAnimationCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    JPLog(@"willBeginFullScreenPresentationWithAnimationCoordinator");
//
//    //   UITransitionContextToViewKey
//    //   UITransitionContextFromViewKey
//
//    UIView *toView = [coordinator viewForKey:UITransitionContextToViewKey];
//    UIView *fromView = [coordinator viewForKey:UITransitionContextFromViewKey];
//
//    JPLog(@"toView %@", toView);
//    JPLog(@"fromView %@", fromView);
//
//
//    toView.frame = JPPortraitScreenBounds;
//    toView.transform = CGAffineTransformMakeScale(0.3, 0.3);
//    toView.alpha = 0;
//
////    UIView *containerView = [coordinator containerView];
////    [containerView addSubview:fromView];
////    [containerView addSubview:toView];
//
//    [coordinator animateAlongsideTransitionInView:fromView animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//
//        toView.transform = CGAffineTransformIdentity;
//        toView.alpha = 1;
//
//    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//
//    }];
//
////    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
////
////
////        toView.transform = CGAffineTransformIdentity;
////        toView.alpha = 1;
////
////    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
////
////        JPLog(@"toView %@", toView);
////        JPLog(@"fromView %@", fromView);
////
////    }];
//}

//- (void)playerViewController:(AVPlayerViewController *)playerViewController willEndFullScreenPresentationWithAnimationCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    JPLog(@"willEndFullScreenPresentationWithAnimationCoordinator");
//
//    UIView *toView = [coordinator viewForKey:UITransitionContextToViewKey];
//    UIView *fromView = [coordinator viewForKey:UITransitionContextFromViewKey];
//
//    [coordinator animateAlongsideTransitionInView:toView animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//
//        fromView.transform = CGAffineTransformMakeScale(0.3, 0.3);
//        fromView.alpha = 0;
//
//    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//
//    }];
//}

- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    JPLog(@"playerViewControllerWillStartPictureInPicture");
}

- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    JPLog(@"playerViewControllerDidStartPictureInPicture");
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error {
    JPLog(@"failedToStartPictureInPictureWithError");
}

- (void)playerViewControllerWillStopPictureInPicture:(AVPlayerViewController *)playerViewController {
    JPLog(@"playerViewControllerWillStopPictureInPicture");
}

- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController {
    JPLog(@"playerViewControllerDidStopPictureInPicture");
}

- (BOOL)playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart:(AVPlayerViewController *)playerViewController {
    JPLog(@"playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart");
    return YES;
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    JPLog(@"restoreUserInterfaceForPictureInPictureStopWithCompletionHandler");
}

@end
