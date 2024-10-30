//
//  JPGIFTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/7/20.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPGIFTestViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "YYWebImage.h"

@interface JPGIFTestViewController ()
@property (nonatomic, strong) NSData *data;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation JPGIFTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self addTimer];
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (NSInteger i = 0; i < 100; i++) {
//            UIView *a = [[UIView alloc] initWithFrame:CGRectMake(i, 1, 100, 100)];
//            CGRect frame = a.frame;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                JPLog(@"%@", NSStringFromCGRect(frame));
//            });
//        }
//    });
//
//    JPLog(@"活了 %@", self.timer);
}

static NSTimeInterval JPImageSourceGetGIFFrameDelayAtIndex(CGImageSourceRef source, size_t index) {
    NSTimeInterval delay = 0;
    CFDictionaryRef dic = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    if (dic) {
        CFDictionaryRef dicGIF = CFDictionaryGetValue(dic, kCGImagePropertyGIFDictionary);
        if (dicGIF) {
            NSNumber *num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFUnclampedDelayTime);
            if (num.doubleValue <= __FLT_EPSILON__) {
                num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFDelayTime);
            }
            delay = num.doubleValue;
        }
        CFRelease(dic);
    }
    // http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
    if (delay < 0.02) delay = 0.1;
    return delay;
};

- (IBAction)start:(id)sender {
//    a = 0, b = -1, c = -1, d = 0, tx = 192, ty = 88
//    a = 0, b = 1, c = 1, d = 0, tx = 0, ty = 0
//    self.label.transform = CGAffineTransformMake(0, -1, -1, 0, self.label.jp_height, self.label.jp_width);
//    return;
    
//    if (!self.layer) {
//        CALayer *layer = [CALayer layer];
//        layer.frame = self.view2.frame;
//        layer.jp_y += self.view2.jp_maxY - self.view1.jp_maxY;
//        layer.backgroundColor = JPRandomColor.CGColor;
//        [self.view.layer addSublayer:layer];
//        self.layer = layer;
//
//        self.label.hidden = YES;
//    }
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:3 animations:^{
//            self.view1.jp_centerX += 200;
//        }];
//
//        [UIView animateWithDuration:3 animations:^{
//            self.view2.layer.jp_positionX += 200;
//        }];
//
//        [UIView animateWithDuration:3 animations:^{
//            self.layer.jp_positionX += 200;
//        }];
//    });
//
//    return;
    
    [JPProgressHUD show];
    [self begin:^(BOOL isCacheSuccess) {
        if (isCacheSuccess) {
            [JPProgressHUD showSuccessWithStatus:nil userInteractionEnabled:YES];
        } else {
            [JPProgressHUD showErrorWithStatus:nil userInteractionEnabled:YES];
        }
    }];
}

#define JPGIFOldPath @"/Users/zhoujianping/Desktop/TE/jp_gif_file.GIF"
#define JPGIFNewPath @"/Users/zhoujianping/Desktop/TE/cardstyle.gif"

- (void)begin:(void(^)(BOOL isCacheSuccess))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
        NSData *data = [NSData dataWithContentsOfFile:JPGIFOldPath];
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)(data), NULL);
        if (!source) return;
        
        size_t count = CGImageSourceGetCount(source);
        if (count <= 1) {
            CFRelease(source);
            return;
        }
        
        NSUInteger frames[count];
        double oneFrameTime = 1 / 50.0; // 50 fps
        NSTimeInterval totalTime = 0;
        NSUInteger totalFrame = 0;
        NSUInteger gcdFrame = 0;
        NSMutableArray *delays = [NSMutableArray array];
        for (size_t i = 0; i < count; i++) {
            NSTimeInterval delay = JPImageSourceGetGIFFrameDelayAtIndex(source, i);
            totalTime += delay;
            [delays addObject:@(delay)];
            NSInteger frame = lrint(delay / oneFrameTime);
            if (frame < 1) frame = 1;
            NSLog(@"%zd", frame);
            frames[i] = frame;
            totalFrame += frames[i];
            if (i == 0) gcdFrame = frames[i];
            else {
                NSUInteger frame = frames[i], tmp;
                if (frame < gcdFrame) {
                    tmp = frame; frame = gcdFrame; gcdFrame = tmp;
                }
                while (true) {
                    tmp = frame % gcdFrame;
                    if (tmp == 0) break;
                    frame = gcdFrame;
                    gcdFrame = tmp;
                }
            }
        }
        NSMutableArray *array = [NSMutableArray new];
        for (size_t i = 0; i < count; i++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!imageRef) {
                CFRelease(source);
                return;
            }
            size_t width = CGImageGetWidth(imageRef);
            size_t height = CGImageGetHeight(imageRef);
            if (width == 0 || height == 0) {
                CFRelease(source);
                CFRelease(imageRef);
                return;
            }
            
    //        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
            BOOL hasAlpha = NO;
    //        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
    //            alphaInfo == kCGImageAlphaPremultipliedFirst ||
    //            alphaInfo == kCGImageAlphaLast ||
    //            alphaInfo == kCGImageAlphaFirst) {
    //            hasAlpha = YES;
    //        }
            // BGRA8888 (premultiplied) or BGRX8888
            // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
            CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
            bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
            CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
            CGColorSpaceRelease(space);
            if (!context) {
                CFRelease(source);
                CFRelease(imageRef);
                return;
            }
            CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
            CGImageRef decoded = CGBitmapContextCreateImage(context);
            CFRelease(context);
            if (!decoded) {
                CFRelease(source);
                CFRelease(imageRef);
                return;
            }
            UIImage *image = [UIImage imageWithCGImage:decoded];
            CGImageRelease(imageRef);
            CGImageRelease(decoded);
            if (!image) {
                CFRelease(source);
                return;
            }
//            for (size_t j = 0, max = frames[i] / gcdFrame; j < max; j++) {
//                NSLog(@"%zd", j);
                [array addObject:image];
//            }
        }
        CFRelease(source);
        
        BOOL isCacheSuccess = [self __cacheGIF:array delays:delays cacheURL:[NSURL fileURLWithPath:JPGIFNewPath]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(isCacheSuccess);
        });
            
    });
}

#pragma mark 缓存GIF文件
- (BOOL)__cacheGIF:(NSArray<UIImage *> *)images delays:(NSArray *)delays cacheURL:(NSURL *)cacheURL {
    if (!cacheURL || images.count == 0) {
        return NO;
    }
    size_t count = images.count;
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)cacheURL, kUTTypeGIF , count, NULL);
    NSDictionary *gifProperty = @{(__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFLoopCount: @0}};
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperty);
    void (^cacheBlock)(NSInteger i);
    if (images.count == delays.count) {
        cacheBlock = ^(NSInteger i) {
           UIImage *img = images[i];
           NSTimeInterval delay = [delays[i] doubleValue];
           NSDictionary *frameProperty = @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFDelayTime: @(delay)}};
           CGImageDestinationAddImage(destination, img.CGImage, (CFDictionaryRef)frameProperty);
       };
    } else {
        NSTimeInterval delay = delays.count ? [delays.firstObject doubleValue] : 0.1;
        NSDictionary *frameProperty = @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFDelayTime: @(delay)}};
        cacheBlock = ^(NSInteger i) {
            UIImage *img = images[i];
            CGImageDestinationAddImage(destination, img.CGImage, (CFDictionaryRef)frameProperty);
        };
    }
    for (NSInteger i = 0; i < count; i++) {
        cacheBlock(i);
    }
    BOOL isCacheSuccess = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    if (!isCacheSuccess) [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
    return isCacheSuccess;
}

@end
