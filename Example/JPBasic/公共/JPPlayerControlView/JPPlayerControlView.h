//
//  JPPlayerControlView.h
//
//  Created by ios app on 16/6/14.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JPPlayerFullViewController.h"
@class JPPlayerControlView;

@protocol JPPlayerControlViewDelegate <NSObject>

@optional
-(void)switchOrientation:(JPPlayerControlView *)playerControlView isFull:(BOOL)isFull;

@end

@interface JPPlayerControlView : UIView

+(instancetype)playerControlView;

+(instancetype)playerControlViewWithPlayerItem:(AVPlayerItem *)playItem;

@property (nonatomic,weak) id <JPPlayerControlViewDelegate> delegate;

/* 播放器 */
@property (nonatomic, strong) AVPlayer *player;

/** 播放器的Layer（用于显示播放页面） */
@property (weak, nonatomic) AVPlayerLayer *playerLayer;

@property (nonatomic,strong) AVPlayerItem *playerItem;

@end
