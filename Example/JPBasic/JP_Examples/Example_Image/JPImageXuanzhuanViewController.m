//
//  JPImageXuanzhuanViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/8/28.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPImageXuanzhuanViewController.h"
#import "JPImageViewController.h"

@interface JPImageXuanzhuanViewController ()

@end

@implementation JPImageXuanzhuanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [JPProgressHUD show];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        UIImage *finalImage = [self testRotate1];
        UIImage *finalImage = [self testRotate2];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];
            
            JPImageViewController *vc = [[JPImageViewController alloc] init];
            vc.image = finalImage;
            [self.navigationController pushViewController:vc animated:YES];
        });
    });
}

#pragma mark - CGBitmap（逆时针旋转的）
- (UIImage *)testRotate1 {
    
    UIImage *image = [UIImage imageNamed:@"Car.jpg"];
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    CGFloat radians = M_PI_2 * 0.5;
    
    BOOL fitSize = YES;
    size_t width = (size_t)imageSize.width;
    size_t height = (size_t)imageSize.height;
    CGRect newRect = CGRectApplyAffineTransform(CGRectMake(0., 0., width, height),
                                                fitSize ? CGAffineTransformMakeRotation(radians) : CGAffineTransformIdentity);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 (size_t)newRect.size.width,
                                                 (size_t)newRect.size.height,
                                                 8,
                                                 (size_t)newRect.size.width * 4,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    // 1.先挪到新的区域的中心位置（锚点在左下角）
    CGContextTranslateCTM(context, +(newRect.size.width * 0.5), +(newRect.size.height * 0.5));
    
    // 2.旋转（锚点在左下角）
    CGContextRotateCTM(context, radians);
        
    // 3.往左下角方向偏移自身宽高的一半的位置为初始点画上去
    // 因为锚点在左下角，这样做类似于：以自身宽高的一半往左下角方向挪，将锚点从左下角挪回到中点
    //【方式一】：先挪后画
//    CGContextTranslateCTM(context, -(width * 0.5), -(height * 0.5));
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    //【方式二】：又挪又画
    CGContextDrawImage(context, CGRectMake(-(width * 0.5), -(height * 0.5), width, height), imageRef);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    CGContextRelease(context);
    return img;
}

#pragma mark - UIGraphics（顺时针旋转的）
- (UIImage *)testRotate2 {
    UIImage *image = [UIImage imageNamed:@"Car.jpg"];
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    CGRect imageRect = (CGRect){CGPointZero, imageSize};
    
    CGFloat radians = M_PI_2 * 0.5;
    
    // 获取旋转后的rect
    CGRect rotatedRect = CGRectApplyAffineTransform(imageRect, CGAffineTransformMakeRotation(radians));
    rotatedRect.origin.x = 0;
    rotatedRect.origin.y = 0;
    
    UIGraphicsBeginImageContextWithOptions(rotatedRect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
    CGContextFillRect(context, rotatedRect);
    
    // 位图的CGContext以原点为轴旋转。为了使图片以中心为轴旋转，先把CGContext的原点移至中心
    CGContextTranslateCTM(context,
                          rotatedRect.size.width / 2.0,
                          rotatedRect.size.height / 2.0);
    // 然后再旋转
    CGContextRotateCTM(context, radians);
    // 此时，context的原点在位图的中心，需要按照原图大小的一半进行位移，使整张图从原点绘制后图的中心在位图区域的中心。
    CGContextTranslateCTM(context,
                          -imageSize.width / 2.0,
                          -imageSize.height / 2.0);
    // 绘制
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
