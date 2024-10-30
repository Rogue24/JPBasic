//
//  JPPhotoPreviewViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2019/12/31.
//  Copyright © 2019 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPPhotoPreviewViewController.h"
#import "JPPhotoViewModel.h"
#import "JPPhotoTool.h"
#import <PhotosUI/PHLivePhotoView.h>
#import "JPPlayerViewController.h"

#import "JPLivePhotoGIFCreater.h"

@interface JPPhotoPreviewViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *behindImgView;
@property (weak, nonatomic) UIImageView *frontImgView;
@property (nonatomic, weak) PHLivePhotoView *livePHView;

@property (nonatomic, strong) AVAssetImageGenerator *generator;


@property (nonatomic, strong) JPLivePhotoGIFCreater *gifCreater;
@end

@implementation JPPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gifCreater = [[JPLivePhotoGIFCreater alloc] init];
    
    BOOL isLive = self.photoVM.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive;
    if (isLive) {
        JPLog(@"实况");
        PHLivePhotoView *livePHView = [[PHLivePhotoView alloc] init];
        livePHView.userInteractionEnabled = YES;
        livePHView.backgroundColor = UIColor.clearColor;
        livePHView.contentMode = UIViewContentModeScaleAspectFit;
        livePHView.layer.masksToBounds = YES;
        [self.view addSubview:livePHView];
        self.livePHView = livePHView;
        
        [livePHView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    } else {
        JPLog(@"其他");
        UIImageView *frontImgView = ({
            UIImageView *aImgView = [[UIImageView alloc] init];
            aImgView.contentMode = UIViewContentModeScaleAspectFit;
            aImgView;
        });
        [self.view addSubview:frontImgView];
        self.frontImgView = frontImgView;
        [frontImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    [self.view layoutIfNeeded];
    
    @jp_weakify(self);
    CGSize size = CGSizeMake(self.photoVM.bigPhotoSize.width * JPScreenScale, self.photoVM.bigPhotoSize.height * JPScreenScale);
    [JPPhotoToolSI requestPhotoImageForAsset:self.photoVM.asset targetSize:size isFastMode:YES isFixOrientation:NO isJustGetFinalPhoto:YES resultHandler:^(PHAsset *requestAsset, UIImage *resultImage, BOOL isFinalImage) {
        @jp_strongify(self);
        if (!self) return;
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.behindImgView.image = resultImage;
            self.frontImgView.image = resultImage;
        } completion:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.livePHView) {
        CGSize size = CGSizeMake(self.photoVM.bigPhotoSize.width * JPScreenScale, self.photoVM.bigPhotoSize.height * JPScreenScale);
        [JPPhotoToolSI requestLivePhotoForAsset:self.photoVM.asset targetSize:size options:nil isJustGetFinalPhoto:YES resultHandler:^(PHAsset *requestAsset, PHLivePhoto *livePhoto, BOOL isFinalLivePhoto) {
            [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.livePHView.livePhoto = livePhoto;
            } completion:^(BOOL finished) {
//                    PHLivePhotoViewPlaybackStyleUndefined = 0,
//                    PHLivePhotoViewPlaybackStyleFull,
//                    PHLivePhotoViewPlaybackStyleHint,
                [self.livePHView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
            }];
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    JPLog(@"%.2lf", self.photoVM.asset.duration);
    
//    [self.gifCreater createGIF:self.photoVM.asset];
    
    
}

@end
