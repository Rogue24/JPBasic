//
//  JPGIFPreviewViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/2.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPGIFPreviewViewController.h"
#import "YYWebImage.h"
#import "JPPhotoTool.h"
#import "JPLivePhotoGIFCreater.h"

@interface JPGIFPreviewViewController ()
@property (nonatomic, strong) JPLivePhotoGIFCreater *gifCreater;
@property (nonatomic, weak) YYAnimatedImageView *animView;
@end

@implementation JPGIFPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    
    UIButton *saveBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn setTitle:@"保存至相册" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    self.gifCreater = [[JPLivePhotoGIFCreater alloc] init];
    
    YYAnimatedImageView *animView = [[YYAnimatedImageView alloc] init];
    animView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:animView];
    self.animView = animView;
    
    [animView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(animView.mas_width);
        make.centerY.equalTo(self.view);
    }];
    
#warning YYAnimatedImageView iOS14无法显示
//    [self.animView yy_setImageWithURL:[NSURL fileURLWithPath:JPMainBundleResourcePath(@"huanjie", @"gif")] placeholder:nil options:(YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionIgnoreDiskCache) completion:nil];
//    [self.animView yy_setImageWithURL:[NSURL fileURLWithPath:JPMainBundleResourcePath(@"Joker", @"jpg")] placeholder:nil options:(YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionIgnoreDiskCache) completion:nil];
//    return;
    
    [self.gifCreater createGIF:self.assets completion:^(NSURL *gifFileURL) {
        if (!gifFileURL) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        self.gifFileURL = gifFileURL;
        [self.animView yy_setImageWithURL:gifFileURL placeholder:nil options:(YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionIgnoreDiskCache) completion:nil];
    }];
}

- (void)dealloc {
    [self.animView yy_cancelCurrentImageRequest];
    if (self.gifFileURL) [[YYWebImageManager sharedManager].cache removeImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:self.gifFileURL]];
    
    [self.gifCreater jp_gifReset];
}

- (void)saveAction {
    if (!self.gifFileURL) {
        [JPProgressHUD showInfoWithStatus:@"没有GIF文件" userInteractionEnabled:YES];
        return;
    }
    [JPProgressHUD showWithStatus:@"正在保存..."];
    [JPPhotoToolSI saveFileToAppAlbumWithFileURL:self.gifFileURL successHandle:^(NSString *assetID) {
        [JPProgressHUD showSuccessWithStatus:@"GIF保存成功" userInteractionEnabled:YES];
    } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
        [JPProgressHUD showErrorWithStatus:@"GIF保存失败" userInteractionEnabled:YES];
    }];
}

@end
