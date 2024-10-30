//
//  JPGPUImageCameraViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/2/13.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPGPUImageCameraViewController.h"
#import "AVPlayerViewController+JPExtension.h"
#import "GPUImageBeautifyFilter.h"
#import "JPImageFilter.h"
#import "UIAlertController+JPExtension.h"
#import "LFGPUImageBeautyFilter.h"
#import "JPMovieWriter.h"
#import "JPWatermarkElement.h"
#import "JPPhotoTool.h"

#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif

@interface JPGPUImageCameraViewController () <JPMovieWriterDelegate> //<GPUImageMovieWriterDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *placeholderView;
@property (weak, nonatomic) IBOutlet GPUImageView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *writeLastView;
@property (weak, nonatomic) IBOutlet UIView *userGrView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, strong) GPUImageStillCamera *camera;

@property (nonatomic, weak) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, weak) GPUImageSketchFilter *sketchFilter;
@property (nonatomic, weak) GPUImagePixellateFilter *pixellateFilter;

@property (nonatomic, strong) LFGPUImageBeautyFilter *beautifyFilter;
@property (nonatomic, weak) JPImageFilter *imageFilter;

@property (nonatomic, weak) GPUImageFilterGroup *filterGroup;

@property (nonatomic, strong) GPUImagePicture *lookupImageSource;
@property (nonatomic, strong) GPUImageLookupFilter *lookupFilter;

@property (nonatomic, strong) GPUImageSwirlFilter *swirlFilter;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) BOOL isPaning;

//@property (nonatomic, weak) GPUImageMovieWriter *movieWriter;
@property (nonatomic, weak) JPMovieWriter *movieWriter;

@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;
//@property (nonatomic, strong) GPUImageUIElement *element;
@property (nonatomic, strong) JPWatermarkElement *element; // 修正后的GPUImageUIElement
@property (nonatomic, strong) UIImageView *watermark;
@end

@implementation JPGPUImageCameraViewController
{
    BOOL _isPreviewing;
}

// 设置处理链条（一层一层往上叠）
// camera -> bilateralFilter（磨皮） -> brightnessFilter（美白） -> previewView
// [self.camera addTarget:bilateralFilter];
// [bilateralFilter addTarget:brightnessFilter];
// [brightnessFilter addTarget:self.previewView];

#pragma mark - 编码参数

- (NSDictionary *)videoOutputSettings:(CGSize)videoSize {
#pragma mark 参考于：https://blog.csdn.net/sinat_31177681/article/details/75252341
//    // 写入视频大小
//    NSInteger numPixels = videoSize.width * videoSize.height;
//    // 每像素比特
//    CGFloat bitsPerPixel = 6.0;
//    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
//    // 码率和帧率设置
//    NSDictionary *compressionProperties =
//        @{AVVideoAverageBitRateKey: @(bitsPerSecond),
//          AVVideoExpectedSourceFrameRateKey: @(15),
//          AVVideoMaxKeyFrameIntervalKey: @(15),
//          AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel};
//    return @{AVVideoCodecKey: AVVideoCodecH264,
//             AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
//             AVVideoWidthKey: @(videoSize.width),
//             AVVideoHeightKey: @(videoSize.height),
//             AVVideoCompressionPropertiesKey: compressionProperties};
    
#pragma mark 源码的设置，有待考量
    NSDictionary *videoCleanApertureSettings = @{AVVideoCleanApertureWidthKey: @(videoSize.width),
                                                 AVVideoCleanApertureHeightKey: @(videoSize.height),
                                                 AVVideoCleanApertureHorizontalOffsetKey: @0,
                                                 AVVideoCleanApertureVerticalOffsetKey: @0};
    NSDictionary *videoAspectRatioSettings = @{AVVideoPixelAspectRatioHorizontalSpacingKey: @3,
                                               AVVideoPixelAspectRatioVerticalSpacingKey: @3};
    NSDictionary *compressionProperties = @{AVVideoCleanApertureKey: videoCleanApertureSettings,
                                            AVVideoPixelAspectRatioKey: videoAspectRatioSettings,
                                            AVVideoAverageBitRateKey: @(1000000), // 2000000 降低码率 体积更小
                                            AVVideoMaxKeyFrameIntervalKey: @16,
                                            AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31};
    return @{AVVideoCodecKey: AVVideoCodecTypeH264,
             AVVideoWidthKey: @(videoSize.width),
             AVVideoHeightKey: @(videoSize.height),
             AVVideoCompressionPropertiesKey: compressionProperties};
}

- (NSDictionary *)audioOutputSettings {
#pragma mark 参考于：https://blog.csdn.net/sinat_31177681/article/details/75252341
//    return @{AVEncoderBitRatePerChannelKey : @(28000),
//             AVFormatIDKey : @(kAudioFormatMPEG4AAC),
//             AVNumberOfChannelsKey : @(1),
//             AVSampleRateKey : @(22050)};
    
#pragma mark 源码的设置，有待考量
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    return @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
             AVNumberOfChannelsKey: @1,
             AVSampleRateKey: @(44100.0),
             AVEncoderBitRateKey: @64000,
             AVChannelLayoutKey: [NSData dataWithBytes:&acl length: sizeof(acl)]};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [JPFileTool removeFile:JPMoviePath];
    self.writeLastView.alpha = 0.2;
    
#pragma mark GPUImageStillCamera
    self.camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = YES;
    
#pragma mark 美颜滤镜
    self.beautifyFilter = [[LFGPUImageBeautyFilter alloc] init];
    self.slider.value = self.beautifyFilter.beautyLevel;
    
#pragma mark 滤镜组（测试）
//    GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];
//
//    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
//    GPUImageSketchFilter *sketchFilter = [[GPUImageSketchFilter alloc] init];
//    GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
//
//
//    [filterGroup addFilter:sketchFilter];
//    [filterGroup addFilter:brightnessFilter];
//    [filterGroup addFilter:pixellateFilter];
//
//    [sketchFilter addTarget:brightnessFilter];
//    [brightnessFilter addTarget:pixellateFilter];
//
//    filterGroup.initialFilters = @[sketchFilter];
//    filterGroup.terminalFilter = pixellateFilter;
//
//    [self.camera addTarget:filterGroup];
//
//    self.filterGroup = filterGroup;
//    self.brightnessFilter = brightnessFilter;
//    self.sketchFilter = sketchFilter;
//    self.pixellateFilter = pixellateFilter;
    
#pragma mark 场景滤镜
    self.lookupFilter = [[GPUImageLookupFilter alloc] init];
    self.lookupFilter.intensity = 1;
    
#pragma mark 🌀滤镜
    self.swirlFilter = [[GPUImageSwirlFilter alloc] init];
    self.swirlFilter.radius = 0;
    
#pragma mark 录制器
    CGSize videoSize = CGSizeMake(720, 1280);
    JPMovieWriter *movieWriter = [[JPMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:JPMoviePath] size:videoSize fileType:AVFileTypeMPEG4 outputSettings:[self videoOutputSettings:videoSize]];
    movieWriter.delegate = self;
    movieWriter.encodingLiveVideo = YES; // 是否对视频进行编码，这个设置为YES，AVAssetWriterInput的expectsMediaDataInRealTime则也为YES，代表需要从capture session实时获取数据
    movieWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid; // MP4格式需要设置这个
    movieWriter.shouldPassthroughAudio = NO;
    [movieWriter setHasAudioTrack:YES audioSettings:[self audioOutputSettings]];
    self.camera.audioEncodingTarget = (GPUImageMovieWriter *)movieWriter; //把采集的音频交给movieWriter写入
    self.movieWriter = movieWriter;
    
#pragma mark 水印滤镜
    self.blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    self.blendFilter.mix = 1;
    
#pragma mark 创建链
    // 水印不显示，只录制
//    [self.camera addTarget:self.beautifyFilter];
//    [self.beautifyFilter addTarget:self.lookupFilter];
//    [self.lookupFilter addTarget:self.swirlFilter];
//    [self.swirlFilter addTarget:self.previewView];
//    [self.swirlFilter addTarget:self.blendFilter];
//    [self.blendFilter addTarget:self.movieWriter];
    // 水印能看到
    [self.camera addTarget:self.beautifyFilter];
    [self.beautifyFilter addTarget:self.lookupFilter];
    [self.lookupFilter addTarget:self.swirlFilter];
    [self.swirlFilter addTarget:self.blendFilter];
    [self.blendFilter addTarget:self.previewView];
    [self.blendFilter addTarget:self.movieWriter];
    
#pragma mark 滤镜图片
    NSString *filterPath = [JPMainBundleResourcePath(@"FilterResource", @"bundle") stringByAppendingPathComponent:@"chaotuo.png"];
    UIImage *lookupTableImage = [UIImage imageWithContentsOfFile:filterPath];
    self.lookupImageSource = [[GPUImagePicture alloc] initWithImage:lookupTableImage];
    // 图像处理
    [self.lookupImageSource addTarget:self.lookupFilter];
    [self.lookupImageSource useNextFrameForImageCapture];
    [self.lookupImageSource processImage];
    
#pragma mark 水印
    UIView *watermarkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JPPortraitScreenWidth, JPPortraitScreenWidth * (videoSize.height / videoSize.width))];
    watermarkView.backgroundColor = [UIColor clearColor];
    self.watermark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Lisa.png"]];
    self.watermark.contentMode = UIViewContentModeScaleAspectFit;
    self.watermark.frame = CGRectMake(0, 0, 220, 220);
    [watermarkView addSubview:self.watermark];
    self.watermark.center = CGPointMake(200, 200);
    
    self.element = [[JPWatermarkElement alloc] initWithView:watermarkView];
    [self.element addTarget:self.blendFilter];
    
    /*
     * 参考：https://github.com/BradLarson/GPUImage/issues/2211
     * 修改GPUImage源码，以修复<<单次刷新静态水印导致崩溃>>的问题：
        // TODO: This may not work
        outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:layerPixelSize textureOptions:self.outputTextureOptions onlyTexture:YES];
        [outputFramebuffer disableReferenceCounting]; // Add this line, because GPUImageTwoInputFilter.m frametime updatedMovieFrameOppositeStillImage is YES, but the secondbuffer not lock. 添加此行，因为GPUImageTwoInputFilter.m frametime updatedMovieFrameOppositeStillImage为YES，但第二个缓冲区未锁定。

        glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
        // no need to use self.outputTextureOptions here, we always need these texture options
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)layerPixelSize.width, (int)layerPixelSize.height, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
        
        free(imageData);
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
                
                [currentTarget setInputSize:layerPixelSize atIndex:textureIndexOfTarget];
                [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget]; // add this line, because the outputFramebuffer is update above. 添加此行，因为outputFramebuffer在上面更新。
                [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndexOfTarget];
            }
        }
     */
    
    // 修改源码后就只需要update一下就好，不再需要每帧都update
    [self.element update];
    
    //每一帧渲染完毕后的回调
//    @jp_weakify(self);
//    [self.beautifyFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//        @jp_strongify(self);
//        if (!self) return;
//       //需要调用update操作：因为update只会输出一次纹理信息，只适用于一帧，所以需要实时更新水印层图像
//       [self.element updateWithTimestamp:time];
//    }];
    
#pragma mark 🌀定时器
    [self.userGrView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)]];
    self.link = [CADisplayLink displayLinkWithTarget:JPTargetProxy(self) selector:@selector(linkHandle)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    if (_isPreviewing) return;
    _isPreviewing = YES;
    // 开始采集
    [self.camera startCameraCapture];
    // 停止采集
//    [self.camera stopCameraCapture];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)dealloc {
    [self.movieWriter cancelRecording];
    [self.camera removeAllTargets];
    [self.camera stopCameraCapture];
    
    [self.link invalidate];
    self.link = nil;
    
    JPLog(@"JPGPUImageCameraViewController死了");
}

#pragma mark - 按钮事件

// 切换摄像头
- (IBAction)switchCamera:(id)sender {
    [self.camera rotateCamera];
}

// 开始录制
- (IBAction)play:(id)sender {
    if (self.movieWriter.isRecording) {
        if (self.movieWriter.isPaused) {
            [JPProgressHUD showImage:nil status:@"继续" userInteractionEnabled:YES];
            self.movieWriter.paused = NO;
        } else {
            [JPProgressHUD showInfoWithStatus:@"已经在录制" userInteractionEnabled:YES];
        }
        return;
    }
    
    // 移除残影
    if (self.writeLastView.subviews.count > 0) {
        [UIView transitionWithView:self.writeLastView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            for (UIView *subview in self.writeLastView.subviews) {
                [subview removeFromSuperview];
            }
        } completion:nil];
    }
    
    [JPFileTool removeFile:JPMoviePath];
    
    [self.movieWriter startRecording];
    
    [JPProgressHUD showImage:nil status:@"开始录制" userInteractionEnabled:YES];
}

// 暂停录制
- (IBAction)pause:(id)sender {
    if (!self.movieWriter.isRecording) {
        return;
    }
    
    if (self.movieWriter.isPaused) {
        [JPProgressHUD showInfoWithStatus:@"已经暂停" userInteractionEnabled:YES];
    } else {
        [JPProgressHUD showImage:nil status:@"暂停" userInteractionEnabled:YES];
        self.movieWriter.paused = YES;
        
        // 设置残影
        UIView *snView = [self.previewView snapshotViewAfterScreenUpdates:NO];
        snView.frame = self.writeLastView.bounds;
        [UIView transitionWithView:self.writeLastView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            for (UIView *subview in self.writeLastView.subviews) {
                [subview removeFromSuperview];
            }
            [self.writeLastView addSubview:snView];
        } completion:nil];
    }
}

// 停止录制
- (IBAction)stop:(id)sender {
    if (!self.movieWriter.isRecording) {
        return;
    }
    
    // 移除残影
    if (self.writeLastView.subviews.count > 0) {
        [UIView transitionWithView:self.writeLastView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            for (UIView *subview in self.writeLastView.subviews) {
                [subview removeFromSuperview];
            }
        } completion:nil];
    }
    
    [JPProgressHUD showWithStatus:@"正在结束录制..."];
    [self.movieWriter finishRecordingWithCompletionHandler:^{
//        [self.movieWriter jp_removeAssetWriter]; // 使用GPUImageMovieWriter就调用这方法
        
        long long totalSize = [JPFileTool fileSize:JPMoviePath];
        NSString *sizeStr = JPFileSizeString(totalSize);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"保存相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [JPProgressHUD showWithStatus:@"正在保存录像..."];
                [JPPhotoToolSI saveVideoToAppAlbumWithFileURL:[NSURL fileURLWithPath:JPMoviePath] successHandle:^(NSString *assetID) {
                    [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
                } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                    [JPProgressHUD showErrorWithStatus:@"保存失败" userInteractionEnabled:YES];
                }];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"观看录像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                UIViewController *vc = [[NSClassFromString(@"JPPlayerViewController") alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
                [AVPlayerViewController playLocalVideo:JPMoviePath isAutoPlay:YES];
            }];
            UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [JPProgressHUD showWithStatus:@"正在删除录像..."];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [JPFileTool removeFile:JPMoviePath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [JPProgressHUD showSuccessWithStatus:@"删除成功" userInteractionEnabled:YES];
                    });
                });
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
            [UIAlertController jp_alertControllerWithStyle:UIAlertControllerStyleAlert title:@"录制完成" message:sizeStr actions:@[action1, action2, action3, cancel] fromVC:self];
        });
    }];
}

// 采集一帧画面
- (IBAction)capturePhoto:(id)sender {
    [self.camera capturePhotoAsImageProcessedUpToFilter:self.brightnessFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        JPLog(@"%@", processedImage);
        self.placeholderView.image = processedImage;
    }];
}

- (IBAction)sliderDidChanged:(UISlider *)sender {
    float value = sender.value;
    
//    self.lookupFilter.intensity = value;
    self.beautifyFilter.beautyLevel = value;
    self.beautifyFilter.brightLevel = value;
    
    if (self.camera && self.camera.inputCamera) {
        AVCaptureDevice *device = (AVCaptureDevice *)self.camera.inputCamera;
        if ([device lockForConfiguration:nil]) {
            device.videoZoomFactor = 1 + value;
            [device unlockForConfiguration];
        }
    }
}

static BOOL aaa = NO;
- (IBAction)changeFilter:(id)sender {
    if (!self.lookupFilter) {
        return;
    }
    
    aaa = !aaa;
    
    UIImage *lookupTableImage;
    if (aaa) {
        NSString *filterPath = [JPMainBundleResourcePath(@"FilterResource", @"bundle") stringByAppendingPathComponent:@"landiao.png"];
        lookupTableImage = [UIImage imageWithContentsOfFile:filterPath];
    } else {
        NSString *filterPath = [JPMainBundleResourcePath(@"FilterResource", @"bundle") stringByAppendingPathComponent:@"chaotuo.png"];
        lookupTableImage = [UIImage imageWithContentsOfFile:filterPath];
    }
    
    [self.lookupImageSource removeOutputFramebuffer];
    [self.lookupImageSource removeAllTargets];
    
    self.lookupImageSource = [[GPUImagePicture alloc] initWithImage:lookupTableImage];
    [self.lookupImageSource addTarget:self.lookupFilter];
    [self.lookupImageSource useNextFrameForImageCapture];
    [self.lookupImageSource processImage];
}

- (IBAction)shuiyin:(UIButton *)sender {
    self.watermark.center = CGPointMake(JPRandomNumber(0, JPPortraitScreenWidth), JPRandomNumber(JPNavTopMargin, JPPortraitScreenHeight - JPDiffTabBarH));
    
    // 修改源码后就只需要update一下就好，不再需要每帧都update
    [self.element update];
}

#pragma mark - <JPMovieWriterDelegate>
//#pragma mark - <GPUImageMovieWriterDelegate>

- (void)movieRecordingCompleted {
    JPLog(@"movieRecordingCompleted");
}

- (void)movieRecordingFailedWithError:(NSError*)error {
    JPLog(@"movieRecordingFailedWithError");
}

#pragma mark - pan手势

- (void)panAction:(UIPanGestureRecognizer *)panGR {
    if (panGR.state == UIGestureRecognizerStateBegan || panGR.state == UIGestureRecognizerStateChanged) {
        self.isPaning = YES;
        CGPoint location = [panGR locationInView:self.userGrView];
        self.swirlFilter.center = CGPointMake(location.x / self.userGrView.jp_width, location.y / self.userGrView.jp_height);
    } else {
        self.isPaning = NO;
    }
}

- (void)linkHandle {
    CGFloat radius = self.swirlFilter.radius;
    if (self.isPaning) {
        radius += 0.01;
    } else {
        radius -= 0.01;
    }
    if (radius > 1) {
        radius = 1;
    } else if (radius < 0) {
        radius = 0;
    }
    self.swirlFilter.radius = radius;
}

@end
