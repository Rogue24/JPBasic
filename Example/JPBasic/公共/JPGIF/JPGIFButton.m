//
//  JPGIFButton.m
//  JPPlayer
//
//  Created by 周健平 on 2019/12/20.
//  Copyright © 2019 cb2015. All rights reserved.
//

#import "JPGIFButton.h"
#import "JPFileTool.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+JPExtension.h"
#import "JPProxy.h"

@interface JPGIFButton ()
@property (nonatomic, weak) AVPlayerItem *playerItem;
@property (nonatomic, weak) AVPlayerItemVideoOutput *videoOutput;

@property (nonatomic, strong) CADisplayLink *link;

@property (nonatomic, strong) NSMutableDictionary *pixelBuffers;

@property (nonatomic, strong) dispatch_semaphore_t operationSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t linkSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t maxCountSemaphore;
@property (nonatomic, strong) dispatch_group_t group;
@property (nonatomic, strong) dispatch_queue_t myQueue;

@property (nonatomic, strong) UIImage *firstImage;
@property (nonatomic, weak) UILongPressGestureRecognizer *lpGR;

//@property (nonatomic, strong) UIImage *titleImage;
@end

@implementation JPGIFButton
{
    float _fps;
    NSTimeInterval _startPlaySecond;
    NSTimeInterval _finalPlaySecond;
    NSTimeInterval _minPlaySecond;
    NSUInteger _recordFrameInterval;
    JPGifFailReason _failReason;
    BOOL _isInGroup;
}

#pragma mark - 常量

static NSString *const gifFileName_ = @"gifFile.gif";

#pragma mark - setter

- (void)setGifState:(JPGifState)gifState {
    if (_gifState == gifState) {
        return;
    }
    _gifState = gifState;
    
    switch (gifState) {
        case JPGifState_Idle:
        {
            JPLog(@"恢复空闲");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [JPFileTool removeFile:self.tmpFilePath];
                [JPFileTool removeFile:self.gifFilePath];
                [self.pixelBuffers removeAllObjects];
                self.firstImage = nil;
            });
            break;
        }
            
        case JPGifState_Recording:
        {
            JPLog(@"开始录制");
            if (self.gifStartRecord) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.gifStartRecord();
                });
            }
            break;
        }
            
        case JPGifState_PrepareCreate:
        {
            JPLog(@"准备创建");
            if (self.gifPrepareCreate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.gifPrepareCreate();
                });
            }
            break;
        }
            
        case JPGifState_Creating:
        {
            JPLog(@"开始创建");
            if (self.gifStartCreate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.gifStartCreate(self.firstImage);
                });
            }
            break;
        }
            
        case JPGifState_CreateFailed:
        {
            _isCreateGIF = NO;
            if (self.gifCreateFailed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.gifCreateFailed(self->_failReason);
                });
            }
            break;
        }
            
        case JPGifState_CreateSuccess:
        {
            JPLog(@"成功");
            if (self.gifCreateSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.gifCreateSuccess(self.gifFilePath);
                });
            }
            break;
        }
    }
}

#pragma mark - getter

- (NSMutableDictionary *)pixelBuffers {
    if (!_pixelBuffers) {
        _pixelBuffers = [NSMutableDictionary dictionary];
    }
    return _pixelBuffers;
}

- (NSString *)gifFilePath {
    return JPCacheFilePath(gifFileName_);
}

- (NSString *)tmpFilePath {
    return JPTmpFilePath(gifFileName_);
}

#pragma mark - 创建方法

- (instancetype)init {
    if (self = [super init]) {
        [self __setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self __setup];
}

- (void)dealloc {
    [self reset];
}

#pragma mark - 初始方法

- (void)__setup {
    _gifState = JPGifState_Idle;
    
    _gifMaxSize = CGSizeMake(500, 500);
    
    _frameInterval = 15;
    _minRecordSecond = 2.0;
    _maxRecordSecond = 8.0;
    
    _operationSemaphore = dispatch_semaphore_create(1);
    _linkSemaphore = dispatch_semaphore_create(1);
    _maxCountSemaphore = dispatch_semaphore_create(10);
    _group = dispatch_group_create();
    _myQueue = dispatch_queue_create("jp_gif", DISPATCH_QUEUE_CONCURRENT);
    
    UILongPressGestureRecognizer *lpGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__touchBegin)];
    lpGR.minimumPressDuration = 0.25;
    [self addGestureRecognizer:lpGR];
    self.lpGR = lpGR;
    
//    NSString *title = @"周健平帅得无可匹敌";
//    UIFont *font = [UIFont systemFontOfSize:10];
//    CGSize titleSize = [title boundingRectWithSize:CGSizeMake(999, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
//    CATextLayer *titleLayer = [CATextLayer layer];
//    titleLayer.foregroundColor = UIColor.whiteColor.CGColor;
//    titleLayer.alignmentMode = kCAAlignmentJustified;
//    titleLayer.wrapped = YES;
//    titleLayer.contentsScale = JPScreenScale;
//    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
//    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
//    titleLayer.font = fontRef;
//    titleLayer.fontSize = font.pointSize;
//    CGFontRelease(fontRef);
//    titleLayer.string = title;
//    titleLayer.bounds = CGRectMake(0, 0, titleSize.width, titleSize.height);
//    self.titleImage = [titleLayer jp_convertToImage];
}

#pragma mark - 事件触发方法

- (void)__touchBegin {
    UIGestureRecognizerState state = self.lpGR.state;
    if (state == UIGestureRecognizerStateBegan) {
        JPLog(@"begin touch")
        [self addLink];
    } else if (state == UIGestureRecognizerStateEnded ||
               state == UIGestureRecognizerStateCancelled ||
               state == UIGestureRecognizerStateFailed) {
        JPLog(@"end touch");
        [self removeLink:NO];
    }
}

#pragma mark - 重写父类方法

#pragma mark - 公开方法

- (void)setupPlayerItem:(AVPlayerItem *)playerItem videoOutput:(AVPlayerItemVideoOutput *)videoOutPut {
    _playerItem = playerItem;
    _videoOutput = videoOutPut;
    if (_playerItem && !_videoOutput) {
        AVPlayerItemVideoOutput *videoOutPut = [[AVPlayerItemVideoOutput alloc] init];
        [_playerItem addOutput:videoOutPut];
        _videoOutput = videoOutPut;
    }
}

- (void)reset {
    _isCreateGIF = NO;
    [self removeLink:YES];
    self.gifState = JPGifState_Idle;
}

#pragma mark - 私有方法

- (void)addLink {
    if (!_playerItem || !_videoOutput) {
        JPLog(@"没有播放源");
        return;
    }
    
    if (_isInGroup) {
        JPLog(@"还没出组");
        return;
    }
    if (self.gifState != JPGifState_Idle) {
        JPLog(@"请先清空");
        return;
    }
    
    _isCreateGIF = NO;
    
    NSTimeInterval startPlaySecond = CMTimeGetSeconds(self.playerItem.currentTime);
    if (isnan(startPlaySecond)) {
        JPLog(@"无法录制");
        return;
    }
    
    float rate = self.player ? self.player.rate : 1.0;
    
    NSTimeInterval minPlaySecond = _minRecordSecond * rate;
    NSTimeInterval maxPlaySecond = _maxRecordSecond * rate;
    
    NSTimeInterval finalPlaySecond = CMTimeGetSeconds(self.playerItem.duration);
    if (isnan(finalPlaySecond)) {
        finalPlaySecond = startPlaySecond + maxPlaySecond;
    } else {
        NSTimeInterval diffPlaySecond = finalPlaySecond - startPlaySecond;
        if (diffPlaySecond < minPlaySecond) {
            JPLog(@"剩余时间太短，解码失败");
            _failReason = JPGifFailReason_FewTotalDuration;
            self.gifState = JPGifState_CreateFailed;
            return;
        } else if (diffPlaySecond > maxPlaySecond) {
            finalPlaySecond = startPlaySecond + maxPlaySecond;
        }
    }
    
    _minPlaySecond = minPlaySecond;
    _startPlaySecond = startPlaySecond;
    _finalPlaySecond = finalPlaySecond;
    
    _factRecordSecond = (finalPlaySecond - startPlaySecond) / rate;
    
    _recordFrameInterval = _frameInterval * rate;
    _fps = 1.0 / (float)_recordFrameInterval;
    
    _isInGroup = YES;
    dispatch_group_enter(self.group);
    
    dispatch_group_notify(self.group, self.myQueue, ^{
        self->_isInGroup = NO;
        
        if (self.gifState != JPGifState_PrepareCreate) {
            return;
        }
        
        if (self.pixelBuffers.count < self->_recordFrameInterval) {
            JPLog(@"拿到的帧数太少，失败");
            self->_failReason = JPGifFailReason_FewFrameInterval;
            self.gifState = JPGifState_CreateFailed;
            return;
        }
        
        [self createGIF];
    });
    
    self.gifState = JPGifState_Recording;
    
    dispatch_semaphore_wait(self.linkSemaphore, DISPATCH_TIME_FOREVER);
    JPLog(@"开启定时器~~");
    self.link = [CADisplayLink displayLinkWithTarget:JPTargetProxy(self) selector:@selector(linkHandle)];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (@available(iOS 10.0, *)) {
        self.link.preferredFramesPerSecond = _recordFrameInterval;
    } else {
        self.link.frameInterval = UIScreen.mainScreen.maximumFramesPerSecond / _recordFrameInterval;
    }
#pragma clang diagnostic pop
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    dispatch_semaphore_signal(self.linkSemaphore);
}

- (void)removeLink:(BOOL)isReset {
    dispatch_semaphore_wait(self.linkSemaphore, DISPATCH_TIME_FOREVER);
    if (self.link) {
        JPLog(@"移除定时器~~");
        [self.link invalidate];
        self.link = nil;
        
        if (!isReset) {
            if (!_isCreateGIF) {
                JPLog(@"录制时间太短，失败");
                _failReason = JPGifFailReason_FewRecordDuration;
                self.gifState = JPGifState_CreateFailed;
            } else {
                self.gifState = JPGifState_PrepareCreate;
            }
        }
        
        dispatch_group_leave(self.group);
    }
    dispatch_semaphore_signal(self.linkSemaphore);
}

#pragma mark - CVPixelBufferRef的做法

- (void)linkHandle {
    dispatch_group_async(self.group, self.myQueue, ^{
        dispatch_semaphore_wait(self.maxCountSemaphore, DISPATCH_TIME_FOREVER);
        
        if (!self.link) {
            dispatch_semaphore_signal(self.maxCountSemaphore);
            return;
        }
        
        CMTime currentTime = self.playerItem.currentTime;
        NSTimeInterval currentSecond = CMTimeGetSeconds(currentTime);
        
        if (currentSecond >= self->_finalPlaySecond) {
            [self removeLink:NO];
            dispatch_semaphore_signal(self.maxCountSemaphore);
            return;
        }
        
        if (!self->_isCreateGIF && ((currentSecond - self->_startPlaySecond) >= self->_minPlaySecond)) {
            dispatch_semaphore_wait(self.operationSemaphore, DISPATCH_TIME_FOREVER);
            self->_isCreateGIF = YES;
            if (self.gifConfirmCreate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.gifConfirmCreate();
                });
            }
            dispatch_semaphore_signal(self.operationSemaphore);
        }
        
        CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:nil];
        if (!pixelBuffer) {
            dispatch_semaphore_signal(self.maxCountSemaphore);
            return;
        }
        
        dispatch_semaphore_wait(self.operationSemaphore, DISPATCH_TIME_FOREVER);
        NSInteger count = self.pixelBuffers.count;
        self.pixelBuffers[@(count)] = (__bridge id)pixelBuffer;
//        JPLog(@"录制了%zd帧 %@", self.pixelBuffers.count, [NSThread currentThread]);
        if (self.pixelBuffers.count == 1) {
            CIContext *context = [CIContext contextWithOptions:nil];
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            CGFloat w = CVPixelBufferGetWidth(pixelBuffer);
            CGFloat h = w * (9.0 / 16.0);
            CGFloat y = JPHalfOfDiff(CVPixelBufferGetHeight(pixelBuffer), h);
            CGRect rect = CGRectMake(0, y, w, h);
            CGImageRef imageRef = [context createCGImage:ciImage fromRect:rect];
            CGImageRef resizeImageRef = JPCGImageResizeCreateDecodedCopy(imageRef, [self resizeScaleWithImageSize:rect.size]/*, self.titleImage.CGImage*/);
            self.firstImage = [UIImage imageWithCGImage:resizeImageRef];
            CGImageRelease(imageRef);
        }
        dispatch_semaphore_signal(self.operationSemaphore);
        
        dispatch_semaphore_signal(self.maxCountSemaphore);
    });
}

- (void)createGIF {
    self.gifState = JPGifState_Creating;
    
    JPLog(@"starat create gif");
    
    NSString *tmpFilePath = self.tmpFilePath;
    NSString *gifFilePath = self.gifFilePath;
    [JPFileTool removeFile:tmpFilePath];
    [JPFileTool removeFile:gifFilePath];
    
    NSInteger pixelBufferCount = self.pixelBuffers.count;
    
    NSMutableDictionary *imageDics = [NSMutableDictionary dictionary];
    
    dispatch_apply(pixelBufferCount, self.myQueue, ^(size_t index) {
        dispatch_semaphore_wait(self.maxCountSemaphore, DISPATCH_TIME_FOREVER);
        
        CVPixelBufferRef pixelBuffer = (__bridge CVPixelBufferRef)self.pixelBuffers[@(index)];
        [self.pixelBuffers removeObjectForKey:@(index)];
        
        CGImageRef resizeImageRef;
        if (index == 0) {
            resizeImageRef = CGImageCreateCopy(self.firstImage.CGImage);
        } else {
            CIContext *context = [CIContext contextWithOptions:nil];
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            CGFloat w = CVPixelBufferGetWidth(pixelBuffer);
            CGFloat h = w * (9.0 / 16.0);
            CGFloat y = JPHalfOfDiff(CVPixelBufferGetHeight(pixelBuffer), h);
            CGRect rect = CGRectMake(0, y, w, h);
            CGImageRef imageRef = [context createCGImage:ciImage fromRect:rect];
            resizeImageRef = JPCGImageResizeCreateDecodedCopy(imageRef, [self resizeScaleWithImageSize:rect.size]/*, self.titleImage.CGImage*/);
            CGImageRelease(imageRef);
        }
        
        CVPixelBufferRelease(pixelBuffer);
        
        if (resizeImageRef) {
            imageDics[@(index)] = (__bridge id)resizeImageRef;
        }
        
        dispatch_semaphore_signal(self.maxCountSemaphore);
    });
    
    NSDictionary *fileProperties = @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFLoopCount: @0}}; // 0：无限循环

    NSDictionary *frameProperties =
     @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFDelayTime: @(_fps)},
       (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB};
     
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:tmpFilePath], kUTTypeGIF , pixelBufferCount, NULL);
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
    
    for (NSInteger i = 0; i < pixelBufferCount; i++) {
        CGImageRef imageRef = (__bridge CGImageRef)(imageDics[@(i)]);
        if (imageRef) {
//            JPLog(@"解码成功 第%zd帧 %@", i, [NSThread currentThread]);
            [imageDics removeObjectForKey:@(i)];
            CGImageDestinationAddImage(destination, imageRef, (CFDictionaryRef)frameProperties);
            CGImageRelease(imageRef);
        }
        
        if (i == pixelBufferCount - 1) {
            BOOL isSuccess = CGImageDestinationFinalize(destination);
            CFRelease(destination);
            
            if (isSuccess) {
                [JPFileTool moveFile:tmpFilePath toPath:gifFilePath];
                self.gifState = JPGifState_CreateSuccess;
            } else {
                JPLog(@"制作GIF时，失败");
                _failReason = JPGifFailReason_CreateFailed;
                self.gifState = JPGifState_CreateFailed;
            }
            [JPFileTool removeFile:tmpFilePath];
        }
    }
}

- (CGFloat)resizeScaleWithImageSize:(CGSize)imageSize {
    CGFloat imageW = imageSize.width;
    CGFloat imageH = imageSize.height;
    CGFloat w;
    CGFloat h;
    if (imageW >= imageH) {
        w = _gifMaxSize.width;
        h = w * (imageH / imageW);
        if (h > imageH) {
            h = _gifMaxSize.height;
            w = h * (imageW / imageH);
        }
    } else {
        h = _gifMaxSize.height;
        w = h * (imageW / imageH);
        if (w > imageW) {
            w = _gifMaxSize.width;
            h = w * (imageH / imageW);
        }
    }
    if (w >= imageW) {
        return 1;
    } else {
        return w / imageW;
    }
}

CGColorSpaceRef JPCGColorSpaceGetDeviceRGB(void) {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

CGImageRef JPCGImageResizeCreateDecodedCopy(CGImageRef imageRef, CGFloat scale/*, CGImageRef titleImage*/) {
    if (!imageRef || scale <= 0) return NULL;
    if (scale >= 1) return CGImageCreateCopy(imageRef);
    
    CGFloat pixelWidth = CGImageGetWidth(imageRef);
    CGFloat pixelHeight = CGImageGetHeight(imageRef);
    CGFloat width = pixelWidth * scale;
    CGFloat height = width * (pixelHeight / pixelWidth);
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    // BGRA8888 (premultiplied) or BGRX8888
    // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, JPCGColorSpaceGetDeviceRGB(), bitmapInfo);
    if (!context) return NULL;
    
    // 普通绘制
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    return newImage;
    
    // logo+文字
//    CGContextSaveGState(context);
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
//    CGContextRestoreGState(context);
//
//    CGContextSaveGState(context);
//    CGImageRef logoImage = [UIImage imageNamed:@"wtvLogooo"].CGImage;
//    CGFloat logoWidth = CGImageGetWidth(logoImage) * 0.5;
//    CGFloat logoHeight = CGImageGetHeight(logoImage) * 0.5;
//    CGContextDrawImage(context, CGRectMake(10, 10, logoWidth, logoHeight), logoImage);
//    CGContextRestoreGState(context);
//
//    CGFloat titleWidth = CGImageGetWidth(titleImage) * 0.5;
//    CGFloat titleHeight = CGImageGetHeight(titleImage) * 0.5;
//    CGRect titleFrame = CGRectMake(10 + logoWidth + 8, 10 + JPHalfOfDiff(logoHeight, titleHeight), titleWidth, titleHeight);
//    CGContextDrawImage(context, titleFrame, titleImage);
//
//    CGImageRef newImage = CGBitmapContextCreateImage(context);
//    CFRelease(context);
//    return newImage;
}

















































#pragma mark - AVAssetImageGenerator的做法

//@property (nonatomic, strong) AVAssetImageGenerator *generator;
//    AVAsset *asset = self.playerItem.asset;
//    self.generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
//    self.generator.appliesPreferredTrackTransform = YES;
//    self.generator.requestedTimeToleranceBefore = kCMTimeZero;
//    self.generator.requestedTimeToleranceAfter = kCMTimeZero;
//    self.generator.maximumSize = CGSizeMake(200, 200);

//- (void)linkHandle2 {
//    dispatch_group_async(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        CMTime currentTime = self.playerItem.currentTime;
//        NSTimeInterval currentSecond = CMTimeGetSeconds(currentTime);
//
//        if (currentSecond > self.finalSecond) {
//            [self removeLink];
//            return;
//        }
//
//        NSError *error;
//        CGImageRef imageRef = [self.generator copyCGImageAtTime:currentTime actualTime:nil error:&error];
//        if (error) {
//            return;
//        }
//
//        dispatch_semaphore_wait(self.pixelBufferSemaphore, DISPATCH_TIME_FOREVER);
//        NSInteger count = self.pixelBuffers.count;
//        self.pixelBuffers[@(count)] = (__bridge id)imageRef; //CFBridgingRelease(imageRef);// (__bridge id)imageRef;
//        JPLog(@"imageCount --- %zd", self.pixelBuffers.count);
//        dispatch_semaphore_signal(self.pixelBufferSemaphore);
//    });
//}
//
//- (void)createGIF2 {
//    NSString *filePath = kCacheFilePath(@"jpgif2.gif");
//    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
//    [JPFileTool removeFile:filePath];
//
//    //GIF播放
//    //0不循环 1无限循环
//    NSDictionary *fileProperties = @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFLoopCount: @(1)}};
//
//    NSDictionary *frameProperties =
//    @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFDelayTime: @(_fps)},
//      (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB};
//
//    NSInteger pixelBufferCount = self.pixelBuffers.count;
//
//    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF , pixelBufferCount, NULL);
//    CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
//
//    JPLog(@"starat create gif");
//
//    for (NSInteger i = 0; i < pixelBufferCount; i++) {
//        @autoreleasepool {
//            CGImageRef imageRef = (__bridge CGImageRef)self.pixelBuffers[@(i)];
//
//            CGImageDestinationAddImage(destination, imageRef, (CFDictionaryRef)frameProperties);
//
//            CGImageRelease(imageRef);
//
//            JPLog(@"已解码第%zd帧", i);
//
//            if (i == pixelBufferCount - 1) {
//                // Finalize the GIF
//                if (CGImageDestinationFinalize(destination)) {
//                    JPLog(@"success!");
//                } else {
//                    JPLog(@"failed!");
//                }
//                CFRelease(destination);
//                [self.pixelBuffers removeAllObjects];
//            }
//        }
//    }
//}

@end
