//
//  TCIFilterViewController.m
//  TestBlurAVPlayer
//
//  Created by 谢艺欣 on 2017/11/28.
//  Copyright © 2017年 谢艺欣. All rights reserved.
//
//  来自：https://www.jianshu.com/p/84b2a1d05db9

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "TCIFilterViewController.h"

@interface TCIFilterViewController ()
@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@end

@implementation TCIFilterViewController
{
    BOOL _isDidAppear;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupPlayerLayer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isDidAppear) return;
    _isDidAppear = YES;
    [self __setupBlurVideoLink];
}

- (void)__setupPlayerLayer {
    AVPlayer *player = [[AVPlayer alloc] init];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.frame = CGRectMake(0, JPHalfOfDiff(JPPortraitScreenHeight - JPNavTopMargin - JPDiffTabBarH, JPPortraitScreenWidth), JPPortraitScreenWidth, JPPortraitScreenWidth);
    playerLayer.backgroundColor = JPRandomColor.CGColor;
    [self.view.layer addSublayer:playerLayer];
    self.view.backgroundColor = JPRandomColor;
    self.playerLayer = playerLayer;
    self.player = player;
}

- (void)__setupBlurVideoLink {
    // 1.读取本地的视频路径
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:JPMainBundleResourcePath(@"yaorenmao_dance", @"mp4")]];
    
    // 2.设置CIFilter效果，使用AVVideoComposition处理渲染过程
    CIFilter *filter = [CIFilter filterWithName:@"CIDotScreen"]; // CIGaussianBlur
    
    AVVideoComposition *composition = [AVVideoComposition videoCompositionWithAsset:asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
//        JPLog(@"每一帧都会来这里（在子线程）");
        
        // 3.获取视频帧并转换成CIImage以供CIFilter进行渲染，可以设定渲染的时间
        CIImage *source = request.sourceImage.imageByClampingToExtent;
        
        long currentTime = request.compositionTime.value / request.compositionTime.timescale;
        if (currentTime < 3) {
            [request finishWithImage:source context:nil];
        } else {
            [filter setValue:source forKey:kCIInputImageKey];
            
            // 4.将渲染完成的CIImage返还给request
            CIImage *output = [filter.outputImage imageByCroppingToRect:request.sourceImage.extent];
            [request finishWithImage:output context:nil];
        }
    }];
    
    // 5.将视频组成装入播放文件中播放即可
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
    item.videoComposition = composition;
    
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
}

@end
