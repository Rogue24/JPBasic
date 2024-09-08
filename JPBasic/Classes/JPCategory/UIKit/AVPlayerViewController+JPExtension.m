//
//  AVPlayerViewController+JPExtension.m
//  JPBasic
//
//  Created by aa on 2022/3/11.
//

#import "AVPlayerViewController+JPExtension.h"
#import "UIWindow+JPExtension.h"
#import "JPProgressHUD.h"
#import "JPFileTool.h"

@implementation AVPlayerViewController (JPExtension)
+ (BOOL)playLocalVideo:(NSString *)filePath isAutoPlay:(BOOL)isAutoPlay {
    if (![JPFileTool fileExists:filePath]) {
        [JPProgressHUD showErrorWithStatus:@"文件不存在！" userInteractionEnabled:YES];
        return NO;
    }
    
    UIViewController *topVC = [UIWindow jp_topViewControllerFromKeyWindow];
    if (!topVC) {
        [JPProgressHUD showErrorWithStatus:@"木有控制器！" userInteractionEnabled:YES];
        return NO;
    }
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    
    [topVC presentViewController:playerVC animated:YES completion:^{
        if (isAutoPlay) {
            [playerVC.player play];
        }
    }];
    
    return YES;
}

+ (BOOL)playLocalVideo:(NSString *)filePath {
    return [self playLocalVideo:filePath isAutoPlay:NO];
}
@end
