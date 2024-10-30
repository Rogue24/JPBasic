//
//  JPFMDBViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/4/11.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPFMDBViewController.h"
#import <FMDB/FMDB.h>

#define JPDBCachePath @"/Users/zhoujianping/Desktop/帅哥平数据库测试位置"

#import "UIImage+YYImageExtension.h"

@interface JPFMDBViewController ()
@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, copy) NSString *imagePath;
@end

@implementation JPFMDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    
    [[UIImage roundImageManager].cache.memoryCache removeAllObjects];
    [[UIImage roundImageManager].cache.diskCache removeAllObjectsWithProgressBlock:nil endBlock:nil];
    
    self.imagePath = [[NSBundle mainBundle] pathForResource:@"Joker.jpg" ofType:nil];
    
    self.backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 200, JPPortraitScreenWidth - 20, JPPortraitScreenWidth)];
    self.backImgView.backgroundColor = JPRandomColor;
    self.backImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.backImgView.image = [UIImage imageWithContentsOfFile:self.imagePath];
    [self.view addSubview:self.backImgView];
    
    UISwitch *swh = [[UISwitch alloc] init];
    swh.center = CGPointMake(JPPortraitScreenWidth * 0.5, 150);
    [swh addTarget:self action:@selector(swhDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swh];
}

- (void)swhDidClick:(UISwitch *)swh {
    BOOL isOn = swh.isOn;
    JPLog(@"%d", isOn);
    if (isOn) {
        [self.backImgView yy_setImageWithURL:[NSURL fileURLWithPath:self.imagePath] placeholder:self.backImgView.image options:YYWebImageOptionSetImageWithFadeAnimation manager:[UIImage roundImageManager] progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            JPLog(@"%zd", from);
        }];
    } else {
        self.backImgView.image = [UIImage imageWithContentsOfFile:self.imagePath];
    }
}




@end
