//
//  JPGPUImageMovieViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/2/21.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//
//  参考：https://www.jianshu.com/p/6ae11336898c

#import "JPGPUImageMovieViewController.h"
#import "UIAlertController+JPExtension.h"
#import "JPPhotoTool.h"

#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif

@interface JPGPUImageMovieViewController () <GPUImageMovieDelegate, GPUImageMovieWriterDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *placeholderView;
@property (weak, nonatomic) IBOutlet GPUImageView *previewView;
@property (weak, nonatomic) IBOutlet UIView *userGrView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, strong) GPUImageMovie *movie;

@property (nonatomic, strong) GPUImagePicture *lookupImageSource;
@property (nonatomic, strong) GPUImageLookupFilter *lookupFilter;

@property (nonatomic, strong) GPUImageSwirlFilter *swirlFilter;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) BOOL isPaning;

@property (nonatomic, strong) GPUImageMovie *saveMovie;
@property (nonatomic, strong) GPUImageGlassSphereFilter *glassSphereFilter;
@end

@implementation JPGPUImageMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [JPFileTool removeFile:JPMoviePath];
    
    NSURL *url = [NSURL fileURLWithPath:JPMainBundleResourcePath(@"minion_01", @"mp4")];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    CGSize videoSize = CGSizeMake(720, 1280);
    for (AVAssetTrack *track in asset.tracks) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
            break;
        }
    }
    
#pragma mark GPUImageMovie
    /**
     *  初始化 movie
     */
//    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
//    self.movie = [[GPUImageMovie alloc] initWithPlayerItem:item]; // 用asset方式创建会卡住主线程 不知道为啥
    self.movie = [[GPUImageMovie alloc] initWithURL:url]; // 用asset方式创建会卡住主线程 不知道为啥
    
    /**
     *  是否重复播放
     */
    self.movie.shouldRepeat = NO;
    
    /**
     *  控制GPUImageView预览视频时的速度是否要保持真实的速度。
     *  如果设为NO，则会将视频的所有帧无间隔渲染，导致速度非常快。
     *  设为YES，则会根据视频本身时长计算出每帧的时间间隔，然后每渲染一帧，就sleep一个时间间隔，从而达到正常的播放速度。
     */
    self.movie.playAtActualSpeed = YES;
    
    /**
     *  设置代理 GPUImageMovieDelegate，只有一个方法 didCompletePlayingMovie
     */
    self.movie.delegate = self;
    
    /**
     *  This enables the benchmarking mode, which logs out instantaneous and average frame times to the console
     *
     *  这使当前视频处于基准测试的模式，记录并输出瞬时和平均帧时间到控制台
     *
     *  每隔一段时间打印： Current frame time : 51.256001 ms，直到播放或加滤镜等操作完毕
     */
//    self.movie.runBenchmark = YES;
    
#pragma mark 场景滤镜
    self.lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self.movie addTarget:self.lookupFilter];
    // 图像处理器
    NSString *filterPath = [JPMainBundleResourcePath(@"FilterResource", @"bundle") stringByAppendingPathComponent:@"chaotuo.png"];
    UIImage *lookupTableImage = [UIImage imageWithContentsOfFile:filterPath];
    self.lookupImageSource = [[GPUImagePicture alloc] initWithImage:lookupTableImage];
    // 图像处理
    [self.lookupImageSource addTarget:self.lookupFilter];
    [self.lookupImageSource processImage];
    self.lookupFilter.intensity = 0;
    
#pragma mark 🌀滤镜
    self.swirlFilter = [[GPUImageSwirlFilter alloc] init];
    self.swirlFilter.radius = 0;
    // 定时器
//    [self.userGrView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)]];
//    self.link = [CADisplayLink displayLinkWithTarget:JPTargetProxy(self) selector:@selector(linkHandle)];
//    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.lookupFilter addTarget:self.swirlFilter];
    [self.swirlFilter addTarget:self.previewView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)dealloc {
    [self.movie removeAllTargets];
    [self.movie cancelProcessing];
    
    [self.link invalidate];
    self.link = nil;
    
    JPLog(@"JPGPUImageMovieViewController死了");
}

#pragma mark - 按钮事件

// 切换摄像头
- (IBAction)switchCamera:(id)sender {
    
}

// 开始采集
- (IBAction)preview:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        /**
         *  视频处理后输出到 GPUImageView 预览时不支持播放声音，需要自行添加声音播放功能
         *
         *  开始处理并播放...
         */
        [self.movie startProcessing];
    } else {
        [self.movie cancelProcessing];
    }
}

// 开始录制
- (IBAction)play:(id)sender {
    
    NSURL *url = [NSURL fileURLWithPath:JPMainBundleResourcePath(@"minion_01", @"mp4")];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    CGSize videoSize = CGSizeMake(720, 1280);
    for (AVAssetTrack *track in asset.tracks) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
            break;
        }
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    GPUImageMovie *saveMovie = [[GPUImageMovie alloc] initWithPlayerItem:item];
    saveMovie.shouldRepeat = NO;
    saveMovie.playAtActualSpeed = NO;
    self.saveMovie = saveMovie;
    
    self.glassSphereFilter = [[GPUImageGlassSphereFilter alloc] init];
    
    GPUImageMovieWriter *movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:JPMoviePath] size:videoSize];
    movieWriter.encodingLiveVideo = YES; // 是否对视频进行编码
    movieWriter.shouldPassthroughAudio = YES; //是否使用声音
    saveMovie.audioEncodingTarget = movieWriter; //把采集的音频交给movieWriter写入
    
    [saveMovie addTarget:self.glassSphereFilter];
    [self.glassSphereFilter addTarget:movieWriter];
    
    [saveMovie enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    [saveMovie startProcessing];
    [movieWriter startRecording];
    
    [JPProgressHUD show];
    @jp_weakify(self);
    [movieWriter setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];
            @jp_strongify(self);
            if (!self) return;
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"保存相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [JPProgressHUD showWithStatus:@"正在保存录像..."];
                [JPPhotoToolSI saveVideoToAppAlbumWithFileURL:[NSURL fileURLWithPath:JPMoviePath] successHandle:^(NSString *assetID) {
                    [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
                } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                    [JPProgressHUD showErrorWithStatus:@"保存失败" userInteractionEnabled:YES];
                }];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"观看录像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIViewController *vc = [[NSClassFromString(@"JPPlayerViewController") alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
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
            [UIAlertController jp_alertControllerWithStyle:UIAlertControllerStyleAlert title:@"录制完成" message:nil actions:@[action1, action2, action3, cancel] fromVC:self];
        });
    }];
    
    [movieWriter setFailureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", error] userInteractionEnabled:YES];
        });
    }];
}

// 暂停录制
- (IBAction)pause:(id)sender {
    
}

// 采集一帧画面
- (IBAction)capturePhoto:(id)sender {
//    [self.camera capturePhotoAsImageProcessedUpToFilter:self.brightnessFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
//        JPLog(@"%@", processedImage);
//        self.placeholderView.image = processedImage;
//    }];
}

- (IBAction)sliderDidChanged:(UISlider *)sender {
    float value = sender.value;
    self.lookupFilter.intensity = value;
}

static BOOL aaa = NO;
- (IBAction)changeFilter:(id)sender {
    aaa = !aaa;
    
    UIImage *lookupTableImage;
    if (aaa) {
        NSString *filterPath = [JPMainBundleResourcePath(@"FilterResource", @"bundle") stringByAppendingPathComponent:@"landiao.png"];
        lookupTableImage = [UIImage imageWithContentsOfFile:filterPath];
    } else {
        NSString *filterPath = [JPMainBundleResourcePath(@"FilterResource", @"bundle") stringByAppendingPathComponent:@"chaotuo.png"];
        lookupTableImage = [UIImage imageWithContentsOfFile:filterPath];
    }
    
    CGFloat intensity = self.lookupFilter.intensity;
    [self.lookupFilter removeAllTargets];
    [self.movie removeTarget:self.lookupFilter];
    
    self.lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self.movie addTarget:self.lookupFilter];
    
    self.lookupImageSource = [[GPUImagePicture alloc] initWithImage:lookupTableImage];
    [self.lookupImageSource addTarget:self.lookupFilter];
    
    [self.lookupImageSource processImage];
    self.lookupFilter.intensity = intensity;
    
    [self.lookupFilter addTarget:self.swirlFilter];
    [self.swirlFilter addTarget:self.previewView];
}

#pragma mark - <GPUImageMovieWriterDelegate>

- (void)movieRecordingCompleted {
    JPLog(@"movieRecordingCompleted");
}

- (void)movieRecordingFailedWithError:(NSError*)error {
    JPLog(@"movieRecordingFailedWithError");
}

#pragma mark - <GPUImageMovieDelegate>

- (void)didCompletePlayingMovie {
    [self pause:nil];
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
    if (radius > self.slider.value) {
        radius = self.slider.value;
    } else if (radius < 0) {
        radius = 0;
    }
    self.swirlFilter.radius = radius;
}

@end
