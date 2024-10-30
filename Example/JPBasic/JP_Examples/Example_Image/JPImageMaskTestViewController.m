//
//  JPImageMaskTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/2/20.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPImageMaskTestViewController.h"
#import "UIImage+JPExtension.h"

@interface JPImageMaskTestViewController ()
@property (nonatomic, strong) UIImageView *backImgView;

@property (nonatomic, assign) BOOL isOut;
@property (nonatomic, strong) UIImageView *maskImgView;
@end

@implementation JPImageMaskTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
//    self.backImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Joker.jpg"]];
//    self.backImgView.contentMode = UIViewContentModeScaleAspectFit;
//    self.backImgView.frame = JPScreenBounds;
//    [self.view addSubview:self.backImgView];
    
    self.maskImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, JPHalfOfDiff(JPPortraitScreenHeight, JPPortraitScreenWidth), JPPortraitScreenWidth, JPPortraitScreenWidth)];
    [self.view addSubview:self.maskImgView];
    
//    self.maskImgView.image = [self destinationInOrOut:self.isOut image:[UIImage imageNamed:@"vest.png"] size:self.maskImgView.jp_size color:JPRandomColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.isOut = !self.isOut;
//    self.maskImgView.image = [self destinationInOrOut:self.isOut image:[UIImage imageNamed:@"vest.png"] size:self.maskImgView.jp_size color:JPRandomColor];
    
    UIImage *souImage = [UIImage imageNamed:@"vest.png"];
    souImage = [souImage jp_imageWithTintColor:UIColor.blackColor size:souImage.size];

    UIGraphicsBeginImageContextWithOptions(souImage.size, NO, souImage.scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, UIColor.whiteColor.CGColor);
    CGContextFillRect(contextRef, CGRectMake(0, 0, souImage.size.width, souImage.size.height));
    [souImage drawInRect:CGRectMake(0, 0, souImage.size.width, souImage.size.height)];
    souImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.maskImgView.image = [self maskImageWithSouImage:souImage desImage:[UIImage imageNamed:@"Joker.jpg"]];
}

/**
 @method
 @brief 蒙版主方法
 @discussion
 @param souImage 要蒙的图片（使用它的轮廓）
 @param desImage 被蒙的图片（显示它的内容）
 @explain 注意：souImage（要蒙的图片）要弄成透明区域为白色，其他不透明区域为黑色
 @result 蒙好的图片
 */
- (UIImage *)maskImageWithSouImage:(UIImage *)souImage desImage:(UIImage *)desImage {
    
    CGImageRef souImageRef = souImage.CGImage;
    
    /*
    CGImageMaskCreate(<#size_t width#>,  图片宽度像素
                      <#size_t height#>,  图片高度像素
                      <#size_t bitsPerComponent#>,  每个颜色的比特数，例如在rgba-32模式下为8
                      <#size_t bitsPerPixel#>,  每个像素的总比特数
                      <#size_t bytesPerRow#>,  每一行占用的字节数，注意这里的单位是字节
                      <#CGDataProviderRef  _Nullable provider#>,  数据源提供者
                      <#const CGFloat * _Nullable decode#>,
                      <#bool shouldInterpolate#>)
     */
    
    CGImageRef souImageMask = CGImageMaskCreate(CGImageGetWidth(souImageRef),
                                                CGImageGetHeight(souImageRef),
                                                CGImageGetBitsPerComponent(souImageRef),
                                                CGImageGetBitsPerPixel(souImageRef),
                                                CGImageGetBytesPerRow(souImageRef),
                                                CGImageGetDataProvider(souImageRef),
                                                NULL,
                                                false);
    /**
     * CGImageMaskCreate 方法
            - 该方法是根据图片上的白色与黑色区分图片不透明区域
            - 黑色区域为有效轮廓，白色区域不显示
            - 黑色与白色之间则按比例显示，越接近黑色越明显（半透明状态）
     */
    
    CGImageRef desImageRef = desImage.CGImage;
    
    // 将 desImageRef（大图） 画到 souImageMask（小图） 的mask区域内
    CGImageRef masked = CGImageCreateWithMask(desImageRef, souImageMask);
    CGImageRelease(souImageMask);
    
    UIImage *maskImage = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(masked);
//    CGImageRelease(souImageRef);
//    CGImageRelease(desImageRef);
    
    return maskImage;
}

- (UIImage *)destinationInOrOut:(BOOL)isOut image:(UIImage *)image size:(CGSize)size color:(UIColor *)color {
    
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    if (MAX(w, h) > MAX(size.width, size.height)) {
        if (w >= h) {
            w = size.width;
            h = w * (image.size.height / image.size.width);
        } else {
            h = size.height;
            w = h * (image.size.width / image.size.height);
        }
    }
    CGFloat x = JPHalfOfDiff(size.width, w);
    CGFloat y = JPHalfOfDiff(size.height, h);
    CGRect imageRect = CGRectMake(x, y, w, h);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    [color setFill];
    
    CGRect rect = isOut ? CGRectMake(0, 0, size.width, size.height) : imageRect;
    UIRectFill(rect);
    
    // kCGBlendModeDestinationOut：透明的地方变成目标颜色，不透明的地方变透明
    // kCGBlendModeDestinationIn：透明的地方变透明，不透明的地方变成目标颜色
    CGBlendMode mode = isOut ? kCGBlendModeDestinationOut : kCGBlendModeDestinationIn;
    [image drawInRect:imageRect blendMode:mode alpha:1.0f];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
