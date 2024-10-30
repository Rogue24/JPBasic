//
//  UIImage+YYImageExtension.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/4/13.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "UIImage+YYImageExtension.h"

@implementation UIImage (YYImageExtension)

+ (YYWebImageManager *)roundImageManager {
    static YYWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = JPCacheFilePath(@"jp_roundimages");
        YYImageCache *cache = [[YYImageCache alloc] initWithPath:path];
        manager = [[YYWebImageManager alloc] initWithCache:cache queue:[YYWebImageManager sharedManager].queue];
        manager.sharedTransformBlock = ^(UIImage *image, NSURL *url) {
            if (!image) return image;
//            return [image jp_imageByRoundWithBorderWidth:0 borderColor:nil];
            return [image jp_imageByRoundWithCornerRadius:6 whScale:(16.0 / 9.0)];
        };
    });
    return manager;
}

- (UIImage *)jp_imageByRoundWithCornerRadius:(CGFloat)cornerRadius whScale:(CGFloat)whScale {
    
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    CGSize size = CGSizeMake(w, w / whScale);
    cornerRadius *= self.scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -size.height);
    
    CGRect roundRect = (CGRect){CGPointZero, size};
    
    UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:roundRect cornerRadius:cornerRadius];
    [roundPath closePath];
    [roundPath addClip];
    
    CGRect rect = (CGRect){CGPointMake((size.width - w) * 0.5, (size.height - h) * 0.5), self.size};
    CGContextDrawImage(context, rect, self.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)jp_imageByRoundWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    CGFloat minSide = MIN(w, h);
    CGFloat cornerRadius = minSide * 0.5;
    CGSize size = CGSizeMake(minSide, minSide);
    
    if (borderWidth >= cornerRadius) return self;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -size.height);
    
    UIRectCorner corners = UIRectCornerAllCorners;
    CGRect roundRect = (CGRect){CGPointZero, size};
    
    UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:roundRect byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, 0)];
    [roundPath closePath];
    [roundPath addClip];
    
    CGRect rect = (CGRect){CGPointMake((size.width - w) * 0.5, (size.height - h) * 0.5), self.size};
    CGContextDrawImage(context, rect, self.CGImage);
    
    if (borderWidth > 0 && borderColor) {
        CGFloat strokeInset = borderWidth * 0.5;
        CGRect strokeRect = CGRectInset(roundRect, strokeInset, strokeInset);
        CGFloat strokeRadius = strokeRect.size.width * 0.5;
        
        UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect byRoundingCorners:corners cornerRadii:CGSizeMake(strokeRadius, 0)];
        [strokePath closePath];
        strokePath.lineWidth = borderWidth;
        
        [borderColor setStroke];
        [strokePath stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
