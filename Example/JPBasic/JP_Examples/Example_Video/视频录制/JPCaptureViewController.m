//
//  JPCaptureViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/2/12.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPCaptureViewController.h"
#import "JPCaptureVideoPreviewView.h"
#import "UIAlertController+JPExtension.h"
#import "JPPhotoTool.h"

@interface JPCaptureViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *placeholderView;
@property (weak, nonatomic) IBOutlet JPCaptureVideoPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *writeLastView;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak) AVCaptureDeviceInput *videoInput;
@property (nonatomic, weak) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, weak) AVCaptureAudioDataOutput *audioOutput;

@property (nonatomic, weak) AVCaptureMovieFileOutput *fileOutput;

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, weak) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, weak) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) NSDictionary *videoCompressionSettings;
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;
@property (nonatomic, assign) BOOL isWriting;
@property (nonatomic, assign) BOOL isCanWrite;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, weak) AVCaptureStillImageOutput *captureStillImageOutput;
@end

@implementation JPCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    self.previewView.backgroundColor = UIColor.blackColor;
    self.writeLastView.alpha = 0.2;
    
    self.serialQueue = dispatch_queue_create("zhoujianping", DISPATCH_QUEUE_SERIAL);
    
    [JPFileTool removeFile:JPMoviePath];
    
    // 1.创建AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    // 2.添加输入的源
    // 2.1 添加视频的输入源
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    if ([self.session canAddInput:videoInput]) [self.session addInput:videoInput];
    self.videoInput = videoInput;
    // 2.2 添加音频的输入源
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audiInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    if ([self.session canAddInput:audiInput]) [self.session addInput:audiInput];
    
    // 3.添加输出的源
    // 3.1 添加视频的输出源
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    if ([self.session canAddOutput:videoOutput]) [self.session addOutput:videoOutput];
    self.videoOutput = videoOutput;
    // 3.2 添加音频的输出源
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    if ([self.session canAddOutput:audioOutput]) [self.session addOutput:audioOutput];
    self.audioOutput = audioOutput;
    
    // 3.设置视频输出方向
    // 注意：设置方向，必须在将output添加到session之后才有效
    AVCaptureDevicePosition position = videoInput.device.position;
    AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if (connection.isVideoMirroringSupported) connection.videoMirrored = position == AVCaptureDevicePositionFront;
    
    // 4.添加预览图层
    self.previewView.previewLayer.session = self.session;
    
    // 5.开始采集
    
    // 6.添加写入文件的输出源
//    AVCaptureMovieFileOutput *fileOutput = [[AVCaptureMovieFileOutput alloc] init];
//    if ([self.session canAddOutput:fileOutput]) [self.session addOutput:fileOutput];
//    self.fileOutput = fileOutput;
    // 注释则使用AVAssetWriter
    
    // 7.添加采集截图的输出源
    AVCaptureStillImageOutput *captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    captureStillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    if ([self.session canAddOutput:captureStillImageOutput]) [self.session addOutput:captureStillImageOutput];
    self.captureStillImageOutput = captureStillImageOutput;
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
    [self.fileOutput stopRecording];
    [self.session stopRunning];
    self.previewView.previewLayer.session = nil;
    JPLog(@"JPCaptureViewController死了");
}

// 切换摄像头
- (IBAction)switchCamera:(id)sender {
    // 1.获取之前的镜头的方向
    AVCaptureDevicePosition position = self.videoInput.device.position;
    // 2.切换方向
    position = position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    // 3.根据方向，获取最新的设备
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray<AVCaptureDevice *> *devices = AVCaptureDevice.devices;
#pragma clang diagnostic pop
    // 4.获取对应的设备
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            // 5.根据最新的设备创建最新的input
            AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            // 6.移除旧的input，添加新的input
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            [self.session addInput:newInput];
            // 视频输出方向
            // 注意：设置方向，必须在将output添加到session之后才有效
            AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
            if (connection.isVideoOrientationSupported) connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            if (connection.isVideoMirroringSupported) connection.videoMirrored = position == AVCaptureDevicePositionFront;
            [self.session commitConfiguration];
            // 7.保存最新的newInput
            self.videoInput = newInput;
            break;
        }
    }
    
}

// 开始采集
- (IBAction)preview:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.session startRunning];
    } else {
        [self.fileOutput stopRecording];
        [self.session stopRunning];
    }
}

// 开始录制
- (IBAction)play:(id)sender {
    if (self.isWriting) {
        [JPProgressHUD showInfoWithStatus:@"已经在录制" userInteractionEnabled:YES];
        return;
    }
    
    JPLog(@"开始录制");
    
    NSString *path = JPMoviePath;
    [JPFileTool removeFile:path];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    if (self.fileOutput) {
        [self.fileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
        return;
    }
    
    self.assetWriter = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:nil];
    
    if (!self.videoCompressionSettings) {
        //写入视频大小
        NSInteger numPixels = JPScreenWidth * JPScreenHeight;
        
        //每像素比特
        CGFloat bitsPerPixel = 12.0;
        NSInteger bitsPerSecond = numPixels * bitsPerPixel;
        
        // 码率和帧率设置
        NSDictionary *compressionProperties = @{AVVideoAverageBitRateKey: @(bitsPerSecond),
                                                AVVideoExpectedSourceFrameRateKey: @(15),
                                                AVVideoMaxKeyFrameIntervalKey: @(15),
                                                AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel};
        
        // 1280x720;
        // 先写死：
        CGFloat width = 720;
        CGFloat height = 1280;
        // 规定格式为1280x720，为什么这里写成720x1280呢？
        // 因为默认是横屏的格式，而我们输出方向设置为竖屏，所以反过来了
        
        //视频属性
        self.videoCompressionSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
                                          AVVideoWidthKey: @(width),
                                          AVVideoHeightKey: @(height),
                                          AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
                                          AVVideoCompressionPropertiesKey: compressionProperties};
    }
    
    AVAssetWriterInput *assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoCompressionSettings];
    // expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    if ([self.assetWriter canAddInput:assetWriterVideoInput]) {
        [self.assetWriter addInput:assetWriterVideoInput];
        self.assetWriterVideoInput = assetWriterVideoInput;
    } else {
        JPLog(@"AssetWriter videoInput append Failed");
    }
    
    // 音频设置
    if (!self.audioCompressionSettings) {
        self.audioCompressionSettings = @{AVEncoderBitRatePerChannelKey: @(28000),
                                          AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                          AVNumberOfChannelsKey: @(1),
                                          AVSampleRateKey: @(22050)};
    }
    
    AVAssetWriterInput *assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioCompressionSettings];
    assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    if ([self.assetWriter canAddInput:assetWriterAudioInput]) {
        [self.assetWriter addInput:assetWriterAudioInput];
        self.assetWriterAudioInput = assetWriterAudioInput;
    } else {
        JPLog(@"AssetWriter audioInput Append Failed");
    }
    
    self.isWriting = YES;
    [JPProgressHUD showImage:nil status:@"开始录制" userInteractionEnabled:YES];
}

// 结束录制
- (IBAction)pause:(id)sender {
    if (!self.isWriting) {
        return;
    }
    
    JPLog(@"结束录制");
    
    if (self.fileOutput) {
        [self.fileOutput stopRecording];
        return;
    }
    
    // 设置残影
    UIView *snView = [self.previewView snapshotViewAfterScreenUpdates:NO];
    snView.frame = self.writeLastView.bounds;
    [UIView transitionWithView:self.writeLastView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        for (UIView *subview in self.writeLastView.subviews) {
            [subview removeFromSuperview];
        }
        [self.writeLastView addSubview:snView];
    } completion:nil];
    
    self.isWriting = NO;
    [JPProgressHUD showWithStatus:@"正在结束录制..."];
    
    @jp_weakify(self);
    [self.assetWriter finishWritingWithCompletionHandler:^{
        JPLog(@"搞定了？%@", [NSThread currentThread]);
        dispatch_sync(self.serialQueue, ^{
            @jp_strongify(self);
            if (!self) return;
            self.isCanWrite = NO;
            self.assetWriter = nil;
            
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
                [UIAlertController jp_alertControllerWithStyle:UIAlertControllerStyleAlert title:@"录制完成" message:sizeStr actions:@[action1, action2, action3, cancel] fromVC:self];
            });
        });
    }];
}

- (IBAction)capturePhoto:(id)sender {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            self.placeholderView.image = image;
        }
    }];
}

#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

// 已经输出的帧（能看到的）
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (!self.isWriting) {
        return;
    }
    
    dispatch_sync(self.serialQueue, ^{
        if ([self.videoOutput connectionWithMediaType:AVMediaTypeVideo] == connection) {
//            JPLog(@"获取视频的一帧画面 %@", [NSThread currentThread]);
            
            if (!self.isCanWrite) {
                [self.assetWriter startWriting];
                [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.isCanWrite = YES;
            }
            
            if (self.isCanWrite) {
                if (self.assetWriterVideoInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        //
                    }
                }
            }
            
        } else if ([self.audioOutput connectionWithMediaType:AVMediaTypeAudio] == connection) {
//            JPLog(@"获取音频数据 %@", [NSThread currentThread]);
            
            if (self.isCanWrite) {
                if (self.assetWriterAudioInput.readyForMoreMediaData)  {
                    BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        //
                    }
                }
            }
        }
    });
    
    
}

// 已经遗弃的帧（不需要处理的）
//- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//
//}

#pragma mark - <AVCaptureFileOutputRecordingDelegate>

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    JPLog(@"didStartRecordingToOutputFileAtURL");
}

//- (void)captureOutput:(AVCaptureFileOutput *)output didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
//    JPLog(@"didPauseRecordingToOutputFileAtURL");
//}
//
//- (void)captureOutput:(AVCaptureFileOutput *)output didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
//    JPLog(@"didResumeRecordingToOutputFileAtURL");
//}
//
//- (void)captureOutput:(AVCaptureFileOutput *)output willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
//    JPLog(@"willFinishRecordingToOutputFileAtURL");
//}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    JPLog(@"didFinishRecordingToOutputFileAtURL");
}


#pragma mark - 通过抽样缓存数据创建一个UIImage对象
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer pBGRA:(unsigned char**)pBGRA {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    //return (unsigned char*)baseAddress;
    *pBGRA = (unsigned char *)malloc(bytesPerRow * height);
    memcpy(*pBGRA, baseAddress, bytesPerRow * height);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    
    return image;
}

@end
