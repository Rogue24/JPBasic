//
//  JPWebImageTestViewController.m
//  JPBasic_Example
//
//  Created by aa on 2020/10/22.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPWebImageTestViewController.h"

@interface JPWebImageTestViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation JPWebImageTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
    CGFloat wh = JPPortraitScreenWidth - 40;
    UIImageView *imageView = ({
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, JPHalfOfDiff(JPPortraitScreenHeight, wh), wh, wh)];
        aImgView.contentMode = UIViewContentModeScaleAspectFit;
        aImgView;
    });
    imageView.backgroundColor = JPRandomColor;
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *urlStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"JPJPJPURL"];
    if (!urlStr) {
        CGFloat wh = self.imageView.jp_width;
        urlStr = [NSString stringWithFormat:@"https://picsum.photos/%.0lf", wh];
        [[NSUserDefaults standardUserDefaults] setObject:urlStr forKey:@"JPJPJPURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self.imageView jp_fakeSetPictureWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
}

@end
