//
//  JPLoadBigImageViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/3/13.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//
//  https://cloud.tencent.com/developer/article/1186094

#import "JPLoadBigImageViewController.h"

@interface JPLoadBigImageViewController ()
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation JPLoadBigImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    CGFloat w = JPPortraitScreenWidth;
    CGFloat h = w * (10110.0 / 7033.0);
    CGFloat x = 0;
    CGFloat y = JPHalfOfDiff(JPPortraitScreenHeight, h);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [self.view addSubview:imgView];
    self.imgView = imgView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *imageData = [NSData dataWithContentsOfFile:JPMainBundleResourcePath(@"big_image", @"jpg")];
        JPLog(@"xxx %@", JPFileSizeString(imageData.length));
        
        UIImage *image = [UIImage imageWithData:imageData];
        CGFloat imageW = CGImageGetWidth(image.CGImage);
        CGFloat imageH = CGImageGetHeight(image.CGImage);
        long long imageSize = imageW * imageH * 4;
        JPLog(@"000 %.2lf x %.2lf, %@", imageW, imageH, JPFileSizeString(imageSize));
        
        CGFloat pixelWidth = JPPortraitScreenWidth * JPScreenScale;
        CGFloat maxPixelValue = (image.jp_hwRatio > 1.0) ? (pixelWidth * image.jp_hwRatio) : pixelWidth;
        
        image = [self ioResizeImageWithImageData:imageData imageSize:maxPixelValue];
        imageW = CGImageGetWidth(image.CGImage);
        imageH = CGImageGetHeight(image.CGImage);
        imageSize = imageW * imageH * 4;
        JPLog(@"111 %.2lf x %.2lf, %@", imageW, imageH, JPFileSizeString(imageSize));
        
        dispatch_async(dispatch_get_main_queue(), ^{
            JPLog(@"%@", image);
            self.imgView.image = image;
        });
    });
}

- (UIImage *)ioResizeImageWithImageData:(NSData *)imageData imageSize:(int)imageSize {
    CFStringRef optionKeys[1];
    CFTypeRef optionValues[4];
    optionKeys[0] = kCGImageSourceShouldCache;
    optionValues[0] = (CFTypeRef)kCFBooleanFalse;
    CFDictionaryRef sourceOption = CFDictionaryCreate(kCFAllocatorDefault, (const void **)optionKeys, (const void **)optionValues, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, sourceOption);
    CFRelease(sourceOption);
    if (!imageSource) {
        NSLog(@"imageSource is Null!");
        return nil;
    }
    
    CFStringRef keys[5];
    CFTypeRef values[5];
    // 设置缩略图的宽高尺寸 需要设置为CFNumber值
    // 创建缩略图等比缩放大小，会根据长宽值比较大的作为imageSize进行缩放
    keys[0] = kCGImageSourceThumbnailMaxPixelSize;
    CFNumberRef thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    values[0] = (CFTypeRef)thumbnailSize;
    // 设置是否创建缩略图，无论原图像有没有包含缩略图，默认kCFBooleanFalse
    keys[1] = kCGImageSourceCreateThumbnailFromImageAlways;
    values[1] = (CFTypeRef)kCFBooleanTrue;
    // 设置缩略图是否进行Transfrom变换
    keys[2] = kCGImageSourceCreateThumbnailWithTransform;
    values[2] = (CFTypeRef)kCFBooleanTrue;
    // 设置如果不存在缩略图则创建一个缩略图，缩略图的尺寸受开发者设置影响
    // 如果不设置尺寸极限，则为图片本身大小，默认为kCFBooleanFalse
    keys[3] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    values[3] = (CFTypeRef)kCFBooleanTrue;
    // 设置是否以解码的方式读取图片数据 默认为kCFBooleanTrue
    // 如果设置为true，在读取数据时就进行解码，如果为false，则在渲染时才进行解码
    keys[4] = kCGImageSourceShouldCacheImmediately;
    values[4] = (CFTypeRef)kCFBooleanTrue;
    /*
     * 还有另外这两个：
     * kCGImageSourceTypeIdentifierHint
        - 设置一个预期的图片文件格式，需要设置为字符串类型的值
     * kCGImageSourceShouldAllowFloa
        - 返回CGImage对象时是否允许使用浮点值，默认为kCFBooleanFalse
     */
    
    CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageRef thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    UIImage *resultImg = [UIImage imageWithCGImage:thumbnailImage];

    CFRelease(thumbnailSize);
    CFRelease(options);
    CFRelease(imageSource);
    CFRelease(thumbnailImage);

    return resultImg;
}

@end
