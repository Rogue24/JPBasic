//
//  JPImageVideoViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2021/5/16.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPImageVideoViewController.h"
#import <AVKit/AVKit.h>
#import "JPPlayerViewController.h"

@interface JPImageVideoViewController ()

@end

@implementation JPImageVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
    UIButton *btn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = JPScaleFont(20);
        [btn setTitle:@"开始！" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        btn.backgroundColor = JPRandomColor;
        [btn addTarget:self action:@selector(begin) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(50, 100, 100, 100);
        btn;
    });
    [self.view addSubview:btn];
}

- (void)begin {
    [JPProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self aaa];
    });
}

#define kBitsPerSecondScale             (16)
#define kMaxKeyFrameIntervalKey         (10)

- (NSDictionary *)getVideoSettingsWithSize:(CGSize)size bitsPerSecond:(NSUInteger)bitsPerSecond{
    return @{
        AVVideoCodecKey: AVVideoCodecTypeH264,
        AVVideoWidthKey: @(size.width),
        AVVideoHeightKey: @(size.height),
        AVVideoCompressionPropertiesKey: @{
            AVVideoAverageBitRateKey: @(bitsPerSecond),
            AVVideoMaxKeyFrameIntervalKey: @(kMaxKeyFrameIntervalKey),
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
        },
    };
}

- (void)aaa {
//    NSThread  *currentThread = [NSThread currentThread];
//    CGSize size = [(NSValue *)[userInfo objectForKey:@"size"] CGSizeValue];
    NSUInteger frameRate = 24;
//    NSUInteger bitsPerSecond = [(NSNumber *)[userInfo objectForKey:@"bitsPerSecond"] unsignedIntegerValue];
    NSTimeInterval duration = 10;
//    void (^dataInputHandler)(NSUInteger frame,CVPixelBufferRef *pixelBuffer,BOOL *stop) = [userInfo objectForKey:@"dataInputHandler"];
//    void(^completionHandler)(NSString *outPath,NSError *error) = [userInfo objectForKey:@"completionHandler"];
    
    UIImage *image = [UIImage imageWithContentsOfFile:JPMainBundleResourcePath(@"Lisa", @"png")];
    CVPixelBufferRef buffer = [JPImageVideoViewController CVPixelBufferRefFromUiImage:image size:CGSizeMake(704, 704) flag:0];
    
    UIImage *image2 = [UIImage imageWithContentsOfFile:JPMainBundleResourcePath(@"Joker", @"jpg")];
    CVPixelBufferRef buffer2 = [JPImageVideoViewController CVPixelBufferRefFromUiImage:image2 size:CGSizeMake(704, 704) flag:0];
    
    NSString *exporterFileName = [NSString stringWithFormat:@"%.0lf_%@.mp4", [[NSDate date] timeIntervalSince1970], @"jpjpjp123"];
    NSString *exporterFilePath = JPTmpFilePath(exporterFileName);

    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:exporterFilePath] fileType:AVFileTypeMPEG4 error:&error];
    NSParameterAssert(videoWriter);

    NSDictionary *videoSettings = [self getVideoSettingsWithSize:CGSizeMake(704, 704) bitsPerSecond:5000 * 1024];
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                       assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:videoSettings];

    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    JPLog(@"000 --- %zd %d", videoWriter.status, adaptor.assetWriterInput.isReadyForMoreMediaData);
    [videoWriter addInput:writerInput];
    JPLog(@"111 --- %zd %d", videoWriter.status, adaptor.assetWriterInput.isReadyForMoreMediaData);

    NSUInteger totalFrame = 0;
    NSUInteger currentFrame = 0;

    if(duration > 0){
        totalFrame = ceil(duration * frameRate);
    }
    
    JPLog(@"222 --- %zd %d", videoWriter.status, adaptor.assetWriterInput.isReadyForMoreMediaData);
    BOOL start = [videoWriter startWriting];
    JPLog(@"333 --- %zd %d", videoWriter.status, adaptor.assetWriterInput.isReadyForMoreMediaData);
    
    if(!adaptor || !videoWriter || videoWriter.error || !start){
        //返回错误
//        MPAVCreateError(error, -1, @"videoWriter error!");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            !completionHandler ? :completionHandler(nil,error);
//        });
//        [currentThread cancel];
        return;
    }
    JPLog(@"444 --- %zd %d", videoWriter.status, adaptor.assetWriterInput.isReadyForMoreMediaData);
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    JPLog(@"555 --- %zd %d", videoWriter.status, adaptor.assetWriterInput.isReadyForMoreMediaData);

    BOOL stop = NO;
    CVPixelBufferRef emptyBuffer = nil;
    
//    [adaptor.assetWriterInput requestMediaDataWhenReadyOnQueue:dispatch_get_global_queue(0, 0) usingBlock:^{
//
//    }];
    
    while (!stop) {
        @autoreleasepool {
            if(duration >= 0 && currentFrame >= totalFrame){
                break;
            }
            
            CVPixelBufferRef pixelBuffer = nil;
            
//            dataInputHandler(currentFrame,&pixelBuffer,&stop); // 自定义图片
//            if(stop) break;
            
//            if(pixelBuffer == nil){
//                UIImage *image = [UIImage jp_createImageWithColor:UIColor.orangeColor];
//                emptyBuffer = [JPImageVideoViewController CVPixelBufferRefFromUiImage:image];
//                pixelBuffer = emptyBuffer;
//            }
            
            if (currentFrame <= totalFrame / 2) {
                pixelBuffer = buffer;
            } else {
                pixelBuffer = buffer2;
            }
            
            JPLog(@"合成中 --- %zd %d", videoWriter.status, adaptor.assetWriterInput.isReadyForMoreMediaData);
            while (true) {
                if (adaptor.assetWriterInput.isReadyForMoreMediaData) break;
                if (videoWriter.status != AVAssetWriterStatusWriting) break;
//                [NSThread sleepForTimeInterval:0.005];
            }
            if (videoWriter.status != AVAssetWriterStatusWriting) break;
            
            CMTime ct = CMTimeMake(currentFrame, (int32_t)frameRate);
            [adaptor appendPixelBuffer:pixelBuffer withPresentationTime:ct];
            currentFrame ++;
        }
    }

    if(totalFrame == 0 && currentFrame > 0){
        totalFrame = currentFrame - 1;
    }
    
    if(emptyBuffer) CVPixelBufferRelease(emptyBuffer);
    if(buffer) CVPixelBufferRelease(buffer);
    if(buffer2) CVPixelBufferRelease(buffer2);
    
    [writerInput markAsFinished];
    [videoWriter endSessionAtSourceTime:CMTimeMake(totalFrame, (int32_t)frameRate)];
    [videoWriter finishWritingWithCompletionHandler:^{
        JPLog(@"合成结束 --- %zd", videoWriter.status);
        
        if (videoWriter.status == AVAssetWriterStatusCompleted) {
            [JPFileTool removeFile:JPMoviePath];
            [JPFileTool moveFile:exporterFilePath toPath:JPMoviePath];
            [JPFileTool removeFile:exporterFilePath];
            
            JPLog(@"合成成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [JPProgressHUD dismiss];
                [self pushPlayerVC];
            });
            
        } else {
            JPLog(@"合成失败 --- %zd", videoWriter.status);
            dispatch_async(dispatch_get_main_queue(), ^{
                [JPProgressHUD showErrorWithStatus:@"合成失败" userInteractionEnabled:YES];
            });
            
        }
    }];
}


#pragma mark - push播放器
- (void)pushPlayerVC {
    JPPlayerViewController *vc = [[NSClassFromString(@"JPPlayerViewController") alloc] init];
    vc.videoURLStr = JPMoviePath;
    [self.navigationController pushViewController:vc animated:YES];
}








static OSType inputPixelFormat(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType(OSType inputPixelFormat, bool hasAlpha){
    
    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    }else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    }else{
        NSLog(@"不支持此格式");
        return 0;
    }
}

// alpha的判断
BOOL CGImageRefContainsAlpha(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

// 此方法能还原真实的图片

+ (CVPixelBufferRef)CVPixelBufferRefFromUiImage:(UIImage *)img size:(CGSize)size flag:(CVPixelBufferLockFlags)flag {
    CGImageRef image = [img CGImage];
    
//    BOOL hasAlpha = CGImageRefContainsAlpha(image);
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary *options = @{
        (NSString *)kCVPixelBufferCGImageCompatibilityKey: @(YES),
        (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES),
        (NSString *)kCVPixelBufferIOSurfacePropertiesKey: CFBridgingRelease(empty),
    };
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             @(YES), kCVPixelBufferCGImageCompatibilityKey,
//                             @(YES), kCVPixelBufferCGBitmapContextCompatibilityKey,
//                             empty, kCVPixelBufferIOSurfacePropertiesKey,
//                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          inputPixelFormat(),
                                          (__bridge CFDictionaryRef)options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, flag);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
//    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType(inputPixelFormat(), (bool)hasAlpha);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, bitmapInfo);
    NSParameterAssert(context);
    
    CGContextClearRect(context, (CGRect){CGPointZero, size});
    
//    CGContextSetFillColorWithColor(context, UIColor.clearColor.CGColor);
//    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    CGRect rect;
    if (img.size.width > img.size.height) {
        CGFloat h = size.width * (img.size.height / img.size.width);
        rect = CGRectMake(0, JPHalfOfDiff(size.height, h), size.width, h);
    } else {
        CGFloat w = size.height * (img.size.width / img.size.height);
        rect = CGRectMake(JPHalfOfDiff(size.width, w), 0, w, size.height);
    }
    
    CGContextDrawImage(context, rect, image);
    CVPixelBufferUnlockBaseAddress(pxbuffer, flag);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    return pxbuffer;
}

@end
