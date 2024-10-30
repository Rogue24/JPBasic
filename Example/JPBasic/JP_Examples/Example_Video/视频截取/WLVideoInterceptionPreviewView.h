//
//  WLVideoInterceptionPreviewView.h
//  WoLive
//
//  Created by 周健平 on 2020/4/1.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface WLVideoInterceptionCell : UICollectionViewCell
+ (CGFloat)cellWH;
- (void)setImageRef:(id)imageRef;
@end

@interface WLVideoInterceptionCurrentView : UIView
+ (instancetype)currentViewWithPlayer:(AVPlayer *)player;
@end

@interface WLVideoInterceptionPreviewView : UIView

+ (instancetype)videoInterceptionPreviewViewWithPlayer:(AVPlayer *)player delegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)delegate;

@property (nonatomic, weak) UICollectionView *collectionView;
- (WLVideoInterceptionCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath imageRef:(id)imageRef;

@end

