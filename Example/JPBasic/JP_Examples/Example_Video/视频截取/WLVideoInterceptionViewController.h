//
//  WLVideoInterceptionViewController.h
//  WoLive
//
//  Created by 周健平 on 2020/3/31.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLVideoInterceptionTool.h"
#import "WLVideoInterceptionPreviewView.h"

@interface WLVideoInterceptionViewController : UIViewController
- (instancetype)initWithVideoURL:(NSURL *)videoURL imageresizerComplete:(void (^)(UIImage *resizeDoneImage))imageresizerComplete;
- (instancetype)initWithInterceptionTool:(WLVideoInterceptionTool *)interceptionTool imageresizerComplete:(void (^)(UIImage *resizeDoneImage))imageresizerComplete;
@property (nonatomic, assign) BOOL isNeedResize;
@property (nonatomic, copy) void (^imageresizerComplete)(UIImage *resizeDoneImage);
@end
