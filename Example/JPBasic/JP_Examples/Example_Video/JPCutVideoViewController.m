//
//  JPCutVideoViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/6/18.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPCutVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "JPPlayerViewController.h"
#import "UIImage+YYWebImage.h"

@interface JPCutVideoViewController ()
@property (nonatomic, strong) UIImage *gifImage;
@property (nonatomic, strong) NSMutableArray<UIImage *> *images;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *delays;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@end

@implementation JPCutVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    UIButton *btn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = JPScaleFont(50);
        [btn setTitle:@"开始裁剪！" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        btn.backgroundColor = JPRandomColor;
//        [btn addTarget:self action:@selector(cut) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(huanqianghuanjieCut) forControlEvents:UIControlEventTouchUpInside];
//        [btn addTarget:self action:@selector(cut222) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:btn];
    
    [btn sizeToFit];
    btn.center = CGPointMake(JPPortraitScreenWidth * 0.5, JPPortraitScreenHeight * 0.5);
    
    
    NSData *data = [NSData dataWithContentsOfFile:JPMainBundleResourcePath(@"huanjie", @"gif")];
    self.gifImage = [UIImage yy_imageWithSmallGIFData:data scale:1];
    
    
    // 3.从Data种获取CGImageSource对象
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFTypeRef)(data), NULL);
    
    // 4.获取Gif图片中，分解出来图片的个数
    NSInteger count = CGImageSourceGetCount(imageSource);
    
    // 5.遍历所有图片，获取图片数组，以及gif图片播放时长
    self.images = [NSMutableArray array];
    self.delays = [NSMutableArray array];
    
    for (NSInteger i = 0; i < count; i++) {
        
        // 5.1 获取图片
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
        if (cgImage == NULL) {
            continue;
        }
        
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        [self.images addObject:image];
        
        // 5.2 获取时长
        CFDictionaryRef proertyDic = CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
        if (proertyDic != NULL) {
            CFDictionaryRef gifDic = CFDictionaryGetValue(proertyDic, kCGImagePropertyGIFDictionary);
            if (gifDic != NULL) {
                NSNumber *num = CFDictionaryGetValue(gifDic, kCGImagePropertyGIFUnclampedDelayTime);
                if (num.doubleValue <= __FLT_EPSILON__) {
                    num = CFDictionaryGetValue(gifDic, kCGImagePropertyGIFDelayTime);
                }
                [self.delays addObject:num];
                NSTimeInterval delay = num.doubleValue;
                self.totalDuration += delay;
            }
            CFRelease(proertyDic);
        }
    }
    
    CFRelease(imageSource);
    
//    // 6.给image设置动画属性
//    imageView.animationImages = images
//    imageView.animationDuration = totalDuration
//    imageView.animationRepeatCount = 1
//
//    // 7.开始动画
//    imageView.startAnimating()
    
    
    
    
    UIImageView *gifImgView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 120, 150, 150 * (450.0 / 369.0))];
    gifImgView.backgroundColor = UIColor.blackColor;
    gifImgView.contentMode = UIViewContentModeScaleAspectFit;
    gifImgView.animationImages = self.images;
    gifImgView.animationDuration = self.totalDuration;
//    [self.view addSubview:gifImgView];
    [self.view.layer addSublayer:gifImgView.layer];
    [gifImgView startAnimating];
    
//    YYAnimatedImageView *gifView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(200, 120, 150, 150 * (450.0 / 369.0))];
//    gifView.contentMode = UIViewContentModeScaleAspectFit;
//    gifView.backgroundColor = UIColor.blackColor;
//    gifView.yy_imageURL = [NSURL fileURLWithPath:JPMainBundleResourcePath(@"huanjie", @"gif")];
//    [self.view addSubview:gifView];
    
    CALayer *gifLayer = [CALayer layer];
    gifLayer.contents = (__bridge id)self.gifImage.CGImage;
    gifLayer.frame = CGRectMake(0, 120, 150, 150 * (450.0 / 369.0));
    [self.view.layer addSublayer:gifLayer];
}

#pragma mark - 随便裁剪
- (void)cut {
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
    NSString *videoFileName = @"1001";

    NSDictionary *optDict = @{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}; // 为YES，duration需要返回一个精确值，计算量会比较大，耗时比较长。
    NSString *videoURLStr = JPMainBundleResourcePath(videoFileName, @"MP4");
    NSURL *videoURL = [NSURL fileURLWithPath:videoURLStr];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:optDict];

    NSError *error;
    AVKeyValueStatus status = [asset statusOfValueForKey:JPKeyPath(asset, tracks) error:&error];

    if (status != AVKeyValueStatusLoaded) {
        JPLog(@"损坏了");
        return;
    }

    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!videoTrack) {
        JPLog(@"损坏了");
        return;
    }

    CGSize videoSize = videoTrack.naturalSize;
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (audioTrack) [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    
#pragma mark 核心代码
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
//    [layerInstruciton setTransform:CGAffineTransformMakeScale(0.5, 0.5) atTime:kCMTimeZero];
//    [layerInstruciton setTransform:CGAffineTransformMakeRotation(M_PI_2) atTime:kCMTimeZero];
    [layerInstruciton setTransform:CGAffineTransformMakeTranslation(-videoSize.width * 0.5, 0) atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = timeRange;
    mainInstruciton.layerInstructions = @[layerInstruciton];

    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderScale = 1;
    mainCompositionInst.renderSize = CGSizeMake(videoSize.width * 0.5, videoSize.height);// CGSizeMake(400, 500);
    
    NSString *exporterFileName = [NSString stringWithFormat:@"%.0lf_%@.mp4", [[NSDate date] timeIntervalSince1970], videoFileName];
    NSString *exporterFilePath = JPTmpFilePath(exporterFileName);
    [JPFileTool removeFile:exporterFilePath];
    
    AVAssetExportSession *exporterSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    exporterSession.videoComposition = mainCompositionInst;
    
    exporterSession.outputFileType = AVFileTypeMPEG4;
    exporterSession.outputURL = [NSURL fileURLWithPath:exporterFilePath]; //如果文件已存在，将造成导出失败
    exporterSession.shouldOptimizeForNetworkUse = YES; //用于互联网传输
    
//    static WLVideosMergeProgresser *progresser_;
//    if (mergeProgressBlock) {
//        progresser_ = [WLVideosMergeProgresser new];
//        progresser_.mergeProgressBlock = mergeProgressBlock;
//    }
    
    
    [exporterSession exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = exporterSession.status;
//        progresser_ = nil;
//        exporterSession_ = nil;
        
        if (status == AVAssetExportSessionStatusCompleted) {
            [JPFileTool removeFile:JPMoviePath];
            [JPFileTool moveFile:exporterFilePath toPath:JPMoviePath];
            [JPFileTool removeFile:exporterFilePath];
            
            JPLog(@"合成成功");
            
            [self pushPlayerVC];
            
        } else {
            JPLog(@"合成失败 --- %zd", status);
        }
    }];
}

#pragma mark - 焕强焕杰
- (void)huanqianghuanjieCut {
    JPLog(@"123");
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSString *videoFileName = @"1001";

    NSDictionary *optDict = @{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}; // 为YES，duration需要返回一个精确值，计算量会比较大，耗时比较长。
    NSString *videoURLStr = JPMainBundleResourcePath(videoFileName, @"MP4");
    NSURL *videoURL = [NSURL fileURLWithPath:videoURLStr];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:optDict];

    NSError *error;
    AVKeyValueStatus status = [asset statusOfValueForKey:JPKeyPath(asset, tracks) error:&error];
    
    if (status != AVKeyValueStatusLoaded) {
        JPLog(@"损坏了");
        return;
    }

    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!videoTrack) {
        JPLog(@"损坏了");
        return;
    }
    
    CGSize videoSize = videoTrack.naturalSize;
    

    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];

    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (audioTrack) [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    
    
    
#pragma mark 核心代码
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
//    [layerInstruciton setTransform:CGAffineTransformMakeScale(0.5, 0.5) atTime:kCMTimeZero];
//    [layerInstruciton setTransform:CGAffineTransformMakeRotation(M_PI_2) atTime:kCMTimeZero];
//    [layerInstruciton setTransform:CGAffineTransformMakeTranslation(0, 1) atTime:kCMTimeZero];

    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = timeRange;
    mainInstruciton.layerInstructions = @[layerInstruciton];

    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    //截取的事最头上的，左上角，宽f1，高f2
    mainCompositionInst.renderScale = 1;
    mainCompositionInst.renderSize = videoSize;// CGSizeMake(400, 500);
    
    // 父layer
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = (CGRect){CGPointZero, videoSize};
    parentLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    // 视频layer
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = (CGRect){CGPointZero, videoSize};
    [parentLayer addSublayer:videoLayer];
    
    // 背景
//    CALayer *bgLayer = [CALayer layer];
//    bgLayer.frame = (CGRect){CGPointZero, videoSize};
//    bgLayer.masksToBounds = YES;
//    bgLayer.contentsGravity = kCAGravityResizeAspectFill;
//    bgLayer.contents = (id)[UIImage imageNamed:@"Joker.jpg"].CGImage;
//    [parentLayer addSublayer:bgLayer];
    
    // 分段动画
    CALayer *box = [CALayer layer];
    box.frame = CGRectMake(0, 0, 30, 30);
    box.zPosition = 1;
    box.backgroundColor = JPRandomColor.CGColor;
    box.cornerRadius = 15;
    box.position = CGPointMake(15, 15);
    [parentLayer addSublayer:box];
    CGPoint lastPoint = CGPointMake(15, 15);
    NSTimeInterval lastBeginTime = 0.0;
    for (NSInteger i = 0; i < 3; i++) {
        CABasicAnimation *a1 = [CABasicAnimation animationWithKeyPath:@"position"];
        a1.removedOnCompletion = NO;
        a1.fillMode = kCAFillModeForwards;
        a1.fromValue = @(lastPoint);
        lastPoint = CGPointMake((CGFloat)(JPRandomNumber(15, videoSize.width - 15)),
                                (CGFloat)(JPRandomNumber(15, videoSize.height - 15)));
        a1.toValue = @(lastPoint);
        a1.duration = 1;
        a1.beginTime = AVCoreAnimationBeginTimeAtZero + lastBeginTime;
        lastBeginTime += a1.duration;
        [box addAnimation:a1 forKey:nil];
    }
    
    // GIF
    CALayer *huanjieLayer = [CALayer layer];
    huanjieLayer.backgroundColor = UIColor.redColor.CGColor;
    huanjieLayer.frame = CGRectMake(0, 0, 150, 150 * (450.0 / 369.0));
    [parentLayer addSublayer:huanjieLayer];
    UIImage *currImage = self.images.firstObject;
    huanjieLayer.contents = (__bridge id)currImage.CGImage;
    // 方式1：CABasicAnimation逐帧添加
//    NSTimeInterval totalDelay = [self.delays.firstObject doubleValue];
//    for (NSInteger i = 1; i < self.images.count; i++) {
//        UIImage *image = self.images[i];
//        NSTimeInterval delay = [self.delays[i] doubleValue];
//        CABasicAnimation *anim4 = [CABasicAnimation animationWithKeyPath:@"contents"];
//        anim4.fromValue = (__bridge id)image.CGImage;
//        anim4.toValue = (__bridge id)image.CGImage;
//        anim4.removedOnCompletion = NO;
//        anim4.beginTime = AVCoreAnimationBeginTimeAtZero + totalDelay;
//        anim4.duration = 0;
//        anim4.removedOnCompletion = NO;
//        anim4.fillMode = kCAFillModeForwards;
//        [huanjieLayer addAnimation:anim4 forKey:nil];
//        totalDelay += delay;
//    }
    // 方式2：CAKeyframeAnimation
    NSMutableArray *contents = [NSMutableArray array];
    NSTimeInterval duration = 0;
    for (NSInteger i = 0; i < self.images.count; i++) {
        UIImage *image = self.images[i];
        [contents addObject:(__bridge id)image.CGImage];
        NSTimeInterval delay = [self.delays[i] doubleValue];
        duration += delay;
    }
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    keyAnim.values = contents;
    keyAnim.beginTime = AVCoreAnimationBeginTimeAtZero;
    keyAnim.duration = duration;
    keyAnim.removedOnCompletion = NO;
    keyAnim.fillMode = kCAFillModeForwards;
    keyAnim.calculationMode = kCAAnimationLinear;
    keyAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    [huanjieLayer addAnimation:keyAnim forKey:nil];
    
    // huangqiang脸
    CGImageRef huanqiangRef = [UIImage imageNamed:@"huanqiang.png"].CGImage;
    CGFloat huanqiangW = CGImageGetWidth(huanqiangRef);
    CGFloat huanqiangH = CGImageGetHeight(huanqiangRef);
    CALayer *huanqiangLayer = [CALayer layer];
    huanqiangLayer.contents = (__bridge id)huanqiangRef;
    huanqiangLayer.frame = CGRectMake(0, 0, huanqiangW * 0.7, huanqiangH * 0.7);
    huanqiangLayer.position = CGPointMake(videoSize.width * 0.49, videoSize.height * 0.65);
    huanqiangLayer.transform = CATransform3DMakeRotation(M_PI_2 * 0.03, 0, 0, 1);
    huanqiangLayer.opacity = 0;
    [parentLayer addSublayer:huanqiangLayer];
    // 渐显
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @0;
    anim.toValue = @1;
    anim.removedOnCompletion = NO;
    anim.beginTime = AVCoreAnimationBeginTimeAtZero + 2.5;
    anim.duration = 0.15;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    [huanqiangLayer addAnimation:anim forKey:nil];
    // 渐大
    CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim2.fromValue = @(CGPointMake(1, 1));
    anim2.toValue = @(CGPointMake(1.15, 1.15));
    anim2.removedOnCompletion = NO;
    anim2.beginTime = AVCoreAnimationBeginTimeAtZero + 2.5;
    anim2.duration = 0.8;
    anim2.removedOnCompletion = NO;
    anim2.fillMode = kCAFillModeForwards;
    [huanqiangLayer addAnimation:anim2 forKey:nil];
    
    // huangqiang嗨
    UIFont *font = [UIFont boldSystemFontOfSize:50];
    CATextLayer *hiLayer = [CATextLayer layer];
    hiLayer.foregroundColor = UIColor.yellowColor.CGColor;
    hiLayer.alignmentMode = kCAAlignmentCenter;
    hiLayer.wrapped = YES;
    hiLayer.contentsScale = JPScreenScale;
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    hiLayer.font = fontRef;
    hiLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    hiLayer.string = @"嗨";
    hiLayer.frame = CGRectMake(250, 50, font.lineHeight, font.lineHeight);
    hiLayer.opacity = 0;
    [parentLayer addSublayer:hiLayer];
    // 渐显
    CABasicAnimation *anim3 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim3.fromValue = @0;
    anim3.toValue = @1;
    anim3.removedOnCompletion = NO;
    anim3.beginTime = AVCoreAnimationBeginTimeAtZero + 2.5;
    anim3.duration = 0.15;
    anim3.removedOnCompletion = NO;
    anim3.fillMode = kCAFillModeForwards;
    [hiLayer addAnimation:anim3 forKey:nil];
    
    // 将合成的parentLayer关联到composition中
    mainCompositionInst.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    
    
    
    NSString *exporterFileName = [NSString stringWithFormat:@"%.0lf_%@.mp4", [[NSDate date] timeIntervalSince1970], videoFileName];
    NSString *exporterFilePath = JPTmpFilePath(exporterFileName);
    [JPFileTool removeFile:exporterFilePath];
    
    AVAssetExportSession *exporterSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    exporterSession.videoComposition = mainCompositionInst;
    
    exporterSession.outputFileType = AVFileTypeMPEG4;
    exporterSession.outputURL = [NSURL fileURLWithPath:exporterFilePath]; //如果文件已存在，将造成导出失败
    exporterSession.shouldOptimizeForNetworkUse = YES; //用于互联网传输
    
//    static WLVideosMergeProgresser *progresser_;
//    if (mergeProgressBlock) {
//        progresser_ = [WLVideosMergeProgresser new];
//        progresser_.mergeProgressBlock = mergeProgressBlock;
//    }
    
    
    [exporterSession exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = exporterSession.status;
//        progresser_ = nil;
//        exporterSession_ = nil;
        
        if (status == AVAssetExportSessionStatusCompleted) {
            [JPFileTool removeFile:JPMoviePath];
            [JPFileTool moveFile:exporterFilePath toPath:JPMoviePath];
            [JPFileTool removeFile:exporterFilePath];
            
            JPLog(@"合成成功");
            
            [self pushPlayerVC];
            
        } else {
            JPLog(@"合成失败 --- %zd", status);
        }
    }];
}

#pragma mark - 视频叠加（开发ing）
- (void)cut222 {
    JPLog(@"123");
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSString *videoFileName = @"1001";

    NSDictionary *optDict = @{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}; // 为YES，duration需要返回一个精确值，计算量会比较大，耗时比较长。
    NSString *videoURLStr = JPMainBundleResourcePath(videoFileName, @"MP4");
    NSURL *videoURL = [NSURL fileURLWithPath:videoURLStr];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:optDict];

    NSError *error;
    AVKeyValueStatus status = [asset statusOfValueForKey:JPKeyPath(asset, tracks) error:&error];
    
    if (status != AVKeyValueStatusLoaded) {
        JPLog(@"损坏了");
        return;
    }

    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!videoTrack) {
        JPLog(@"损坏了");
        return;
    }
    
    CGSize videoSize = videoTrack.naturalSize;
    

    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];

    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (audioTrack) [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    
    
    
#pragma mark 核心代码
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
//    [layerInstruciton setTransform:CGAffineTransformMakeScale(0.5, 0.5) atTime:kCMTimeZero];
//    [layerInstruciton setTransform:CGAffineTransformMakeRotation(M_PI_2) atTime:kCMTimeZero];
//    [layerInstruciton setTransform:CGAffineTransformMakeTranslation(0, 1) atTime:kCMTimeZero];

    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = timeRange;
    mainInstruciton.layerInstructions = @[layerInstruciton];

    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    //截取的事最头上的，左上角，宽f1，高f2
    mainCompositionInst.renderScale = 1;
    mainCompositionInst.renderSize = videoSize;// CGSizeMake(400, 500);
    
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = (CGRect){CGPointZero, videoSize};
    parentLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = (CGRect){CGPointZero, videoSize};
    [parentLayer addSublayer:videoLayer];
    
    CGImageRef huanqiangRef = [UIImage imageNamed:@"huanqiang.png"].CGImage;
    CGFloat huanqiangW = CGImageGetWidth(huanqiangRef);
    CGFloat huanqiangH = CGImageGetHeight(huanqiangRef);
    
    CALayer *huanqiangLayer = [CALayer layer];
    huanqiangLayer.contents = (__bridge id)huanqiangRef;
    huanqiangLayer.frame = CGRectMake(0, 0, huanqiangW * 0.7, huanqiangH * 0.7);
    huanqiangLayer.position = CGPointMake(videoSize.width * 0.49, videoSize.height * 0.65);
    huanqiangLayer.transform = CATransform3DMakeRotation(M_PI_2 * 0.03, 0, 0, 1);
    huanqiangLayer.opacity = 0;
    [parentLayer addSublayer:huanqiangLayer];
    
    UIFont *font = [UIFont boldSystemFontOfSize:50];
    CATextLayer *hiLayer = [CATextLayer layer];
    hiLayer.foregroundColor = UIColor.yellowColor.CGColor;
    hiLayer.alignmentMode = kCAAlignmentCenter;
    hiLayer.wrapped = YES;
    hiLayer.contentsScale = JPScreenScale;
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    hiLayer.font = fontRef;
    hiLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    hiLayer.string = @"嗨";
    hiLayer.frame = CGRectMake(250, 50, font.lineHeight, font.lineHeight);
    hiLayer.opacity = 0;
    [parentLayer addSublayer:hiLayer];
    
    // GIF
    CALayer *huanjieLayer = [CALayer layer];
    huanjieLayer.backgroundColor = UIColor.redColor.CGColor;
    huanjieLayer.frame = CGRectMake(0, 0, 150, 150 * (450.0 / 369.0));
    [parentLayer addSublayer:huanjieLayer];
    UIImage *currImage = self.images.firstObject;
    huanjieLayer.contents = (__bridge id)currImage.CGImage;
    NSTimeInterval totalDelay = [self.delays.firstObject doubleValue];
    for (NSInteger i = 1; i < self.images.count; i++) {
        UIImage *image = self.images[i];
        NSTimeInterval delay = [self.delays[i] doubleValue];
        CABasicAnimation *anim4 = [CABasicAnimation animationWithKeyPath:@"contents"];
        anim4.fromValue = (__bridge id)image.CGImage;
        anim4.toValue = (__bridge id)image.CGImage;
        anim4.removedOnCompletion = NO;
        anim4.beginTime = AVCoreAnimationBeginTimeAtZero + totalDelay;
        anim4.duration = 0;
        anim4.removedOnCompletion = NO;
        anim4.fillMode = kCAFillModeForwards;
        [huanjieLayer addAnimation:anim4 forKey:nil];
        totalDelay += delay;
    }
    
    // 脸
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @0;
    anim.toValue = @1;
    anim.removedOnCompletion = NO;
    anim.beginTime = AVCoreAnimationBeginTimeAtZero + 2.5;
    anim.duration = 0.15;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    [huanqiangLayer addAnimation:anim forKey:nil];
    CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim2.fromValue = @(CGPointMake(1, 1));
    anim2.toValue = @(CGPointMake(1.15, 1.15));
    anim2.removedOnCompletion = NO;
    anim2.beginTime = AVCoreAnimationBeginTimeAtZero + 2.5;
    anim2.duration = 0.8;
    anim2.removedOnCompletion = NO;
    anim2.fillMode = kCAFillModeForwards;
    [huanqiangLayer addAnimation:anim2 forKey:nil];
    
    // 嗨
    CABasicAnimation *anim3 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim3.fromValue = @0;
    anim3.toValue = @1;
    anim3.removedOnCompletion = NO;
    anim3.beginTime = AVCoreAnimationBeginTimeAtZero + 2.5;
    anim3.duration = 0.15;
    anim3.removedOnCompletion = NO;
    anim3.fillMode = kCAFillModeForwards;
    [hiLayer addAnimation:anim3 forKey:nil];
    
    // 将合成的parentLayer关联到composition中
    mainCompositionInst.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    
    
    
    NSString *exporterFileName = [NSString stringWithFormat:@"%.0lf_%@.mp4", [[NSDate date] timeIntervalSince1970], videoFileName];
    NSString *exporterFilePath = JPTmpFilePath(exporterFileName);
    [JPFileTool removeFile:exporterFilePath];
    
    AVAssetExportSession *exporterSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    exporterSession.videoComposition = mainCompositionInst;
    
    exporterSession.outputFileType = AVFileTypeMPEG4;
    exporterSession.outputURL = [NSURL fileURLWithPath:exporterFilePath]; //如果文件已存在，将造成导出失败
    exporterSession.shouldOptimizeForNetworkUse = YES; //用于互联网传输
    
//    static WLVideosMergeProgresser *progresser_;
//    if (mergeProgressBlock) {
//        progresser_ = [WLVideosMergeProgresser new];
//        progresser_.mergeProgressBlock = mergeProgressBlock;
//    }
    
    
    [exporterSession exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = exporterSession.status;
//        progresser_ = nil;
//        exporterSession_ = nil;
        
        if (status == AVAssetExportSessionStatusCompleted) {
            [JPFileTool removeFile:JPMoviePath];
            [JPFileTool moveFile:exporterFilePath toPath:JPMoviePath];
            [JPFileTool removeFile:exporterFilePath];
            
            JPLog(@"合成成功");
            
            [self pushPlayerVC];
            
        } else {
            JPLog(@"合成失败 --- %zd", status);
        }
    }];
}

#pragma mark - push播放器
- (void)pushPlayerVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        JPPlayerViewController *vc = [[NSClassFromString(@"JPPlayerViewController") alloc] init];
        vc.videoURLStr = JPMoviePath;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

@end
