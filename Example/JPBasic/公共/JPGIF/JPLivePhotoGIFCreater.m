//
//  JPLivePhotoGIFCreater.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/2.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPLivePhotoGIFCreater.h"
#import "JPFileTool.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+JPExtension.h"

#import "JPGIFPreviewViewController.h"

@interface JPLivePhotoGIFCreater ()
@property (nonatomic, strong) AVAssetImageGenerator *generator;
@end

@implementation JPLivePhotoGIFCreater

- (NSString *)tmpDirectoryPath {
    NSString *directoryPath = JPTmpFilePath(@"JPGIF");
    if ([JPFileTool fileExists:directoryPath]) {
        return directoryPath;
    }
    [JPFileTool createDirectoryAtPath: directoryPath];
    return directoryPath;
}

- (NSString *)tmpVideoFilePath:(NSInteger)index {
    NSString *fileName = [NSString stringWithFormat:@"jp_video_file%02zd.mov", index];
    return [self.tmpDirectoryPath stringByAppendingPathComponent:fileName];
}

- (NSString *)tmpGifFilePath {
    return [self.tmpDirectoryPath stringByAppendingPathComponent:@"jp_gif_file.gif"];
}


- (instancetype)init {
    if (self = [super init]) {
        _gifState = JPGifState_Idle;
        
        _frameInterval = 20; //24;
        _fps = 1.0 / (float)_frameInterval;
         
        _maxConcurrentOperationLock = dispatch_semaphore_create(10);
        _operationLock = dispatch_semaphore_create(1);
        _operationGroup = dispatch_group_create();
        _operationQueue = dispatch_queue_create("jp_gif", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - 视频合成
- (void)createGIF:(NSArray<PHAsset *> *)assets completion:(void (^)(NSURL *))completion {
    [JPFileTool clearFolder:self.tmpDirectoryPath];
    PHAsset *asset1 = assets[0];

    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;

    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestAVAssetForVideo:asset1
                            options:options
                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {

        NSString *gifFilePath = [self tmpGifFilePath];
        NSURL *gifFileURL = [NSURL fileURLWithPath:gifFilePath];
        [JPFileTool removeFile:gifFilePath];

        NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
        NSInteger total = duration * self.frameInterval;

//        total -= self.frameInterval * (4 + 0.5); // 剪短总时长

        NSDictionary *fileProperties = @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFLoopCount: @0}}; // 0：无限循环

        NSTimeInterval delayTime = self.fps;
        // 提速
//        delayTime = self.fps * 0.3;
//        // 多次测试发现最小是0.015，比这个更小会还原默认值（挺慢的）
//        if (delayTime < 0.015) {
//            delayTime = 0.015;
//        }

        NSDictionary *frameProperties =
         @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFDelayTime: @(delayTime)},
           (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB};

        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)gifFileURL, kUTTypeGIF , total, NULL);
        CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);

        dispatch_semaphore_wait(self.operationLock, DISPATCH_TIME_FOREVER);

        // 9秒视频，16帧，450*450 -> 4.8MB
        // 9秒视频，16帧，700*700 -> 9.2MB
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        generator.maximumSize = CGSizeMake(500, 500);//如果是CGSizeMake(480,136)，则获取到的图片是{240, 136}。与实际大小成比例 --- 700, 700
        generator.appliesPreferredTrackTransform = YES; //这个属性保证我们获取的图片的方向是正确的。比如有的视频需要旋转手机方向才是视频的正确方向。
        /**因为有误差，所以需要设置以下两个属性。如果不设置误差有点大，设置了之后相差非常非常的小**/
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;

        NSMutableArray *times = [NSMutableArray array];
        for (NSInteger i = 0; i < total; i++) {
            CMTime time = CMTimeMakeWithSeconds(i * self.fps, NSEC_PER_SEC);//想要获取图片的时间位置
//            CMTime time = CMTimeMakeWithSeconds(4 + i * self.fps, NSEC_PER_SEC); // 忽略前几秒
            [times addObject:[NSValue valueWithCMTime:time]];
        }
        
        // 倒放处理
//        times = [[times reverseObjectEnumerator] allObjects].mutableCopy;

        __block NSInteger index3 = 0;
        [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            NSTimeInterval actualTimeInt = CMTimeGetSeconds(actualTime);
            if (result == AVAssetImageGeneratorSucceeded) {

                // 加字（测试）
//                imageRef = JPCGImageResizeCreateDecodedCopy222(imageRef, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)));

                CGImageDestinationAddImage(destination, imageRef, (CFDictionaryRef)frameProperties);
            } else {
                JPLog(@"获取图片失败！！！%.2lf %@", actualTimeInt, [NSThread currentThread]);
            }


            index3 += 1;
            if (index3 == total) {
                BOOL isSuccess = CGImageDestinationFinalize(destination);
                CFRelease(destination);

                if (!completion) return;

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isSuccess) {
                        [JPProgressHUD showSuccessWithStatus:@"GIF合成成功" userInteractionEnabled:YES];
                        completion(gifFileURL);
                    } else {
                        [JPProgressHUD showErrorWithStatus:@"GIF制作失败" userInteractionEnabled:YES];
                        completion(nil);
                    }
                });
                dispatch_semaphore_signal(self.operationLock);
            }

        }];

    }];
}
    
#pragma mark - livePhoto合成
//- (void)createGIF:(NSArray<PHAsset *> *)assets completion:(void (^)(NSURL *))completion {
//    [JPFileTool clearFolder:self.tmpDirectoryPath];
//    NSMutableArray *objs = [NSMutableArray array];
//
//    __block NSInteger index = 0;
//    __block NSInteger total = 0;
//    for (NSInteger i = 0; i < assets.count; i++) {
//        PHAsset *asset = assets[i];
//
//        NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
//        PHAssetResource *resource;
//        for (PHAssetResource *assetRes in assetResources) {
//           if (assetRes.type == PHAssetResourceTypePairedVideo ||
//               assetRes.type == PHAssetResourceTypeVideo) {
//               resource = assetRes;
//               break;
//           }
//        }
//
//        if (!resource) {
//            continue;
//        }
//
//        NSString *videoFilePath = [self tmpVideoFilePath:i];
//        NSURL *videoFileURL = [NSURL fileURLWithPath:videoFilePath];
//
//        [JPProgressHUD showWithStatus:@"正在合成GIF..."];
//
//        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:videoFileURL options:nil completionHandler:^(NSError * _Nullable error) {
//            if (error) {
//                JPLog(@"视频提取失败 %@", error);
//            } else {
//                JPLog(@"视频提取成功");
//
//                JPLivePhotoGIFObject *obj = [[JPLivePhotoGIFObject alloc] initWithVideoFileURL:videoFileURL frameInterval:self.frameInterval];
//                [objs addObject:obj];
//                total += obj.frameTotal;
//            }
//
//
//            index += 1;
//            if (index == assets.count) {
//                index = 0;
//
//                if (!objs.count) {
//                    return;
//                }
//
//                NSString *gifFilePath = [self tmpGifFilePath];
//                NSURL *gifFileURL = [NSURL fileURLWithPath:gifFilePath];
//                [JPFileTool removeFile:gifFilePath];
//
//                NSDictionary *fileProperties = @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFLoopCount: @0}}; // 0：无限循环
//
//                NSTimeInterval delayTime = self.fps;
//                // 提速
////                delayTime = self.fps * 0.3;
////                // 多次测试发现最小是0.015，比这个更小会还原默认值（挺慢的）
////                if (delayTime < 0.015) {
////                    delayTime = 0.015;
////                }
//
//                NSDictionary *frameProperties =
//                 @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFDelayTime: @(delayTime)},
//                   (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB};
//
//                CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)gifFileURL, kUTTypeGIF , total, NULL);
//                CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
//
//                __block NSInteger index2 = 0;
//                for (JPLivePhotoGIFObject *obj in objs) {
//                    dispatch_semaphore_wait(self.operationLock, DISPATCH_TIME_FOREVER);
//
//                    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:obj.videoAsset];
//                    generator.maximumSize = CGSizeMake(500, 500);//如果是CGSizeMake(480,136)，则获取到的图片是{240, 136}。与实际大小成比例
//                    generator.appliesPreferredTrackTransform = YES; //这个属性保证我们获取的图片的方向是正确的。比如有的视频需要旋转手机方向才是视频的正确方向。
//                    /**因为有误差，所以需要设置以下两个属性。如果不设置误差有点大，设置了之后相差非常非常的小**/
//                    generator.requestedTimeToleranceAfter = kCMTimeZero;
//                    generator.requestedTimeToleranceBefore = kCMTimeZero;
//
//                    NSMutableArray *times = [NSMutableArray array];
//                    for (NSInteger i = 0; i < obj.frameTotal; i++) {
//                        CMTime time = CMTimeMakeWithSeconds(i * self.fps, NSEC_PER_SEC);//想要获取图片的时间位置
//                        [times addObject:[NSValue valueWithCMTime:time]];
//                    }
//
//                    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
//                        NSTimeInterval actualTimeInt = CMTimeGetSeconds(actualTime);
//                        if (result == AVAssetImageGeneratorSucceeded) {
////                            JPLog(@"获取图片成功！！！%.2lf %@", actualTimeInt, [NSThread currentThread]);
//
//                            static CGRect rect_;
//                            if (CGRectIsEmpty(rect_)) {
//                                // 获取第一帧画面的尺寸
//                                rect_ = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
//                            } else {
//                                // 以第一帧画面的尺寸为基准来绘制（ScaleAspectFit）
//                                imageRef = JPCGImageResizeCreateDecodedCopy111(imageRef, rect_);
//                            }
//
//                            // 加字（测试）
////                            imageRef = JPCGImageResizeCreateDecodedCopy222(imageRef, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)));
//
//                            // 裁剪+加字（测试）
////                            imageRef = JPCGImageResizeCreateDecodedCopy333(imageRef, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)));
//
//                            CGImageDestinationAddImage(destination, imageRef, (CFDictionaryRef)frameProperties);
//                        } else {
//                            JPLog(@"获取图片失败！！！%.2lf %@", actualTimeInt, [NSThread currentThread]);
//                        }
//
//
//                        index2 += 1;
//                        if (index2 == obj.frameTotal) {
//                            index += 1;
//                            if (index == objs.count) {
//                                BOOL isSuccess = CGImageDestinationFinalize(destination);
//                                CFRelease(destination);
//
//                                if (!completion) return;
//
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    if (isSuccess) {
//                                        [JPProgressHUD showSuccessWithStatus:@"GIF合成成功" userInteractionEnabled:YES];
//                                        completion(gifFileURL);
//                                    } else {
//                                        [JPProgressHUD showErrorWithStatus:@"GIF制作失败" userInteractionEnabled:YES];
//                                        completion(nil);
//                                    }
//                                });
//
//                            } else {
//                                index2 = 0;
//                            }
//                            dispatch_semaphore_signal(self.operationLock);
//                        }
//
//                    }];
//                }
//            }
//        }];
//    }
//}

CGColorSpaceRef JPCGColorSpaceGetDeviceRGB111(void) {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

// 适配第一张照片的尺寸范围
CGImageRef JPCGImageResizeCreateDecodedCopy111(CGImageRef imageRef, CGRect rect) {
    CGFloat pixelWidth = CGImageGetWidth(imageRef);
    CGFloat pixelHeight = CGImageGetHeight(imageRef);
    
    if (rect.size.width == pixelWidth && rect.size.height == pixelHeight) {
        return imageRef;
    }
    
    CGFloat whScale = pixelWidth / pixelHeight;
    CGFloat w = rect.size.width;
    CGFloat h = w / whScale;
    if (h > rect.size.height) {
        h = rect.size.height;
        w = h * whScale;
    }
    CGFloat x = JPHalfOfDiff(rect.size.width, w);
    CGFloat y = JPHalfOfDiff(rect.size.height, h);;

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
    CGContextRef context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, JPCGColorSpaceGetDeviceRGB111(), bitmapInfo);
    if (!context) return NULL;
    
    // 涂黑背景
    CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
    CGContextFillRect(context, rect);

    // 普通绘制
    CGContextDrawImage(context, CGRectMake(x, y, w, h), imageRef); // decode
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

// 加字
CGImageRef JPCGImageResizeCreateDecodedCopy222(CGImageRef imageRef, CGRect rect) {
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
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
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 0, JPCGColorSpaceGetDeviceRGB111(), bitmapInfo);
    if (!context) return NULL;
    
    // 涂黑背景
    CGContextSetFillColorWithColor(context, UIColor.yellowColor.CGColor);
    CGContextFillRect(context, rect);
        
    // 先把图片画上去
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), imageRef); // decode
    
    // 再把字画上去
    static UIImage *titleImage_ = nil;
//    static CGFloat titleImageX_ = 0;
    if (titleImage_ == nil) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
            UIFont *font = [UIFont boldSystemFontOfSize:40];
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowBlurRadius = 5;
            shadow.shadowOffset = CGSizeMake(0, 1);
            shadow.shadowColor = JPRGBAColor(0, 0, 0, 0.6);
            NSAttributedString *numberAttStr = [[NSAttributedString alloc] initWithString:@"挖槽，吓死老子！" attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.orangeColor, NSShadowAttributeName: shadow}];
            UILabel *label = ({
                UILabel *aLabel = [[UILabel alloc] init];
                aLabel.textAlignment = NSTextAlignmentLeft;
                aLabel.attributedText = numberAttStr;
                aLabel;
            });
            label.frame = CGRectMake(40, h - font.lineHeight - 20, w, font.lineHeight);
            [view addSubview:label];
            titleImage_ = [view jp_convertToImage];
        });
    } else {
//        titleImageX_ += 1;
    }
    CGImageRef titleImage = titleImage_.CGImage;
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), titleImage);
    
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    return newImage;
}

// 裁剪+加字
CGImageRef JPCGImageResizeCreateDecodedCopy333(CGImageRef imageRef, CGRect rect) {
    CGFloat w = rect.size.width - 100;
    CGFloat h = rect.size.height;
    
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
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 0, JPCGColorSpaceGetDeviceRGB111(), bitmapInfo);
    if (!context) return NULL;
    
    // 涂黑背景
    CGContextSetFillColorWithColor(context, UIColor.yellowColor.CGColor);
    CGContextFillRect(context, rect);

    CGFloat x1 = 0;
    CGFloat y1 = 0;
    CGFloat w1 = rect.size.width;
    CGFloat h1 = rect.size.height;
    x1 -= 30;
    
    // 先把图片画上去
    CGContextDrawImage(context, CGRectMake(x1, y1, w1, h1), imageRef); // decode
    
    // 再把字画上去
    static UIImage *titleImage_ = nil;
    if (titleImage_ == nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x1, y1, w1, h1)];
        UIFont *font = [UIFont boldSystemFontOfSize:35];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 1;
        shadow.shadowOffset = CGSizeMake(0, 1);
        shadow.shadowColor = JPRGBAColor(0, 0, 0, 1);
        NSAttributedString *numberAttStr = [[NSAttributedString alloc] initWithString:@"望下你个废柴！" attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.redColor, NSShadowAttributeName: shadow}];
        UILabel *label = ({
            UILabel *aLabel = [[UILabel alloc] init];
            aLabel.textAlignment = NSTextAlignmentRight;
            aLabel.attributedText = numberAttStr;
            aLabel;
        });
        label.frame = CGRectMake(-80, 70, w1, font.lineHeight);
        [view addSubview:label];
        titleImage_ = [view jp_convertToImage];
    }
    CGImageRef titleImage = titleImage_.CGImage;
    CGContextDrawImage(context, CGRectMake(x1, y1, w1, h1), titleImage);
    
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    return newImage;
}

- (void)jp_gifReset {
    [JPFileTool clearFolder:self.tmpDirectoryPath];
}

@end

@implementation JPLivePhotoGIFObject

- (instancetype)initWithVideoFileURL:(NSURL *)videoFileURL frameInterval:(NSUInteger)frameInterval {
    if (self = [super init]) {
        _videoFileURL = videoFileURL;
        _videoAsset = [AVAsset assetWithURL:videoFileURL];
        _duration = CMTimeGetSeconds(_videoAsset.duration);
        _frameTotal = _duration * frameInterval;
    }
    return self;
}

@end
