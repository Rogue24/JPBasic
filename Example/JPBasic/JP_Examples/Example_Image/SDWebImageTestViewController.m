//
//  SDWebImageTestViewController.m
//  JPBasic
//
//  Created by 周健平 on 2023/5/21.
//  Copyright © 2023 zhoujianping24@hotmail.com. All rights reserved.
//

#import "SDWebImageTestViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <FunnyButton/FunnyButton-Swift.h>

@interface SDWebImageTestViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *imageView2;
@end

@implementation SDWebImageTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
    CGFloat wh = JPPortraitScreenWidth - 150;
    UIImageView *imageView = ({
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(JPHalfOfDiff(JPScreenWidth, wh), 130, wh, wh)];
        aImgView.contentMode = UIViewContentModeScaleAspectFit;
        aImgView;
    });
    imageView.backgroundColor = JPRandomColor;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    UIImageView *imageView2 = ({
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(JPHalfOfDiff(JPScreenWidth, wh), 130 + 10 + wh, wh, wh)];
        aImgView.contentMode = UIViewContentModeScaleAspectFit;
        aImgView;
    });
    imageView2.backgroundColor = JPRandomColor;
    [self.view addSubview:imageView2];
    self.imageView2 = imageView2;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    @jp_weakify(self);
    [self replaceFunnyActionWithWork:^{
        @jp_strongify(self);
        if (!self) return;
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://img1.gamersky.com/upimg/users/2023/05/22/small_202305221009591293.jpg"] placeholderImage:nil options:SDWebImageFromLoaderOnly completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                JPLog(@"1-111 %@ %zd", error.localizedDescription, cacheType);
            } else {
                JPLog(@"1-111 %@ %zd", NSStringFromCGSize(image.size), cacheType);
            }
        }];
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://img1.gamersky.com/upimg/users/2023/05/22/small_202305221009591293.jpg"] placeholderImage:nil options:SDWebImageFromLoaderOnly completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                JPLog(@"1-222 %@ %zd", error.localizedDescription, cacheType);
            } else {
                JPLog(@"1-222 %@ %zd", NSStringFromCGSize(image.size), cacheType);
            }
        }];

        [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://img1.gamersky.com/upimg/users/2023/05/22/small_202305221009591293.jpg"] placeholderImage:nil options:SDWebImageFromLoaderOnly completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                JPLog(@"1-333 %@ %zd", error.localizedDescription, cacheType);
            } else {
                JPLog(@"1-333 %@ %zd", NSStringFromCGSize(image.size), cacheType);
            }
        }];
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://img1.gamersky.com/upimg/users/2023/05/22/small_202305221009591293.jpg"] placeholderImage:nil options:SDWebImageFromLoaderOnly completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                JPLog(@"1-444 %@ %zd", error.localizedDescription, cacheType);
            } else {
                JPLog(@"1-444 %@ %zd", NSStringFromCGSize(image.size), cacheType);
            }
        }];
        
        // ------------------------------------------------------------------------------------------
        
        [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"https://img1.gamersky.com/upimg/users/2023/05/22/small_202305221009591293.jpg"] placeholderImage:nil options:SDWebImageFromLoaderOnly completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                JPLog(@"2-111 %@ %zd", error.localizedDescription, cacheType);
            } else {
                JPLog(@"2-111 %@ %zd", NSStringFromCGSize(image.size), cacheType);
            }
        }];
        
        [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"https://img1.gamersky.com/upimg/users/2023/05/22/small_202305221009591293.jpg"] placeholderImage:nil options:SDWebImageFromLoaderOnly completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                JPLog(@"2-222 %@ %zd", error.localizedDescription, cacheType);
            } else {
                JPLog(@"2-222 %@ %zd", NSStringFromCGSize(image.size), cacheType);
            }
        }];
        
        [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"https://img1.gamersky.com/upimg/users/2023/05/22/small_202305221009591293.jpg"] placeholderImage:nil options:SDWebImageFromLoaderOnly completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                JPLog(@"2-333 %@ %zd", error.localizedDescription, cacheType);
            } else {
                JPLog(@"2-333 %@ %zd", NSStringFromCGSize(image.size), cacheType);
            }
        }];
        
        [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"https://img1.gamersky.com/upimg/users/2023/05/22/small_202305221009591293.jpg"] placeholderImage:nil options:SDWebImageFromLoaderOnly completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                JPLog(@"2-444 %@ %zd", error.localizedDescription, cacheType);
            } else {
                JPLog(@"2-444 %@ %zd", NSStringFromCGSize(image.size), cacheType);
            }
        }];
        
    }];
}

@end

