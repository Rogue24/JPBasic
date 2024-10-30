//
//  WLVideoInterceptionPreviewView.m
//  WoLive
//
//  Created by 周健平 on 2020/4/1.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import "WLVideoInterceptionPreviewView.h"

@interface WLVideoInterceptionCell ()
@property (nonatomic, weak) CALayer *imageLayer;
@end
@implementation WLVideoInterceptionCell
+ (CGFloat)cellWH {
    return JPScaleValue(70);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = JPRGBColor(14, 14, 36);
        
        CGFloat cellWH = self.class.cellWH;
        CALayer *imageLayer = [CALayer layer];
        imageLayer.frame = CGRectMake(0, 0, cellWH, cellWH);
        imageLayer.contentsGravity = kCAGravityResizeAspectFill;
        imageLayer.masksToBounds = YES;
        imageLayer.contentsScale = 1;
        [self.contentView.layer addSublayer:imageLayer];
        self.imageLayer = imageLayer;
    }
    return self;
}

- (void)setImageRef:(id)imageRef {
    self.imageLayer.contents = imageRef;
}
@end

@interface WLVideoInterceptionCurrentView ()
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@end
@implementation WLVideoInterceptionCurrentView
+ (instancetype)currentViewWithPlayer:(AVPlayer *)player {
    return [[self alloc] initWithPlayer:player];
}

- (instancetype)initWithPlayer:(AVPlayer *)player  {
    if (self = [super init]) {
        CGFloat cellWH = WLVideoInterceptionCell.cellWH;
        CGFloat verMargin = JPScaleValue(4);
        CGFloat horMargin = JP8Margin;
        
        self.frame = CGRectMake(0, 0, cellWH + horMargin * 2, cellWH + verMargin * 2);
        self.backgroundColor = JPRGBColor(56, 121, 242);
        self.layer.cornerRadius = verMargin;
        self.layer.masksToBounds = YES;
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playerLayer.masksToBounds = YES;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        playerLayer.backgroundColor = JPRGBColor(14, 14, 36).CGColor;
        playerLayer.frame = CGRectInset(self.bounds, horMargin, verMargin);
        [self.layer addSublayer:playerLayer];
        self.playerLayer = playerLayer;
    }
    return self;
}

- (void)dealloc {
    JPRemoveNotification(self);
}
@end

@interface WLVideoInterceptionPreviewView ()
@property (nonatomic, weak) WLVideoInterceptionCurrentView *currentView;
@end
@implementation WLVideoInterceptionPreviewView

+ (instancetype)videoInterceptionPreviewViewWithPlayer:(AVPlayer *)player delegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)delegate {
    WLVideoInterceptionPreviewView *previewView = [[self alloc] initWithPlayer:player];
    previewView.collectionView.dataSource = delegate;
    previewView.collectionView.delegate = delegate;
    return previewView;
}

- (instancetype)initWithPlayer:(AVPlayer *)player {
    if (self = [super init]) {
        CGFloat cellWH = WLVideoInterceptionCell.cellWH;
        
        self.frame = CGRectMake(0, 0, JPPortraitScreenWidth, cellWH * 2);
        self.backgroundColor = UIColor.clearColor;
        
        CGFloat verInset = (self.jp_height - cellWH) * 0.5;
        CGFloat horInset = self.jp_width * 0.5;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(cellWH, cellWH);
        layout.minimumLineSpacing = layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(verInset, horInset, verInset, horInset);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [collectionView jp_contentInsetAdjustmentNever];
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.bounces = NO;
        [collectionView registerClass:WLVideoInterceptionCell.class forCellWithReuseIdentifier:@"WLVideoInterceptionCell"];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        WLVideoInterceptionCurrentView *currentView = [WLVideoInterceptionCurrentView currentViewWithPlayer:player];
        currentView.center = CGPointMake(self.jp_width * 0.5, self.jp_height * 0.5);
        currentView.userInteractionEnabled = NO;
        [self addSubview:currentView];
        self.currentView = currentView;
    }
    return self;
}

- (WLVideoInterceptionCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath imageRef:(id)imageRef {
    WLVideoInterceptionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"WLVideoInterceptionCell" forIndexPath:indexPath];
    cell.imageRef = imageRef;
    return cell;
}

@end
