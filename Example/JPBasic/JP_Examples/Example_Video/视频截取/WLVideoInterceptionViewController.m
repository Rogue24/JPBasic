//
//  WLVideoInterceptionViewController.m
//  WoLive
//
//  Created by 周健平 on 2020/3/31.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import "WLVideoInterceptionViewController.h"
#import "AVPlayer+SeekSmoothly.h"
//#import "JPImageresizerViewController.h"
#import "WLVideoInterceptionThumbnail.h"

@interface WLVideoInterceptionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) WLVideoInterceptionTool *interceptionTool;
@property (nonatomic, weak) WLVideoInterceptionPreviewView *previewView;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) NSInteger frameTotal;
@property (nonatomic, strong) NSArray<WLVideoInterceptionThumbnail *> *thumbnails;
@end

@implementation WLVideoInterceptionViewController
{
    BOOL _isDidAppear;
    CGFloat _allItemWidth;
}

#pragma mark - 常量

#pragma mark - setter

#pragma mark - getter

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] initWithPlayerItem:[AVPlayerItem playerItemWithURL:self.interceptionTool.videoURL]];
        _player.volume = 0;
        _player.rate = 0;
    }
    return _player;
}

#pragma mark - 创建方法

- (instancetype)initWithVideoURL:(NSURL *)videoURL imageresizerComplete:(void (^)(UIImage *))imageresizerComplete {
    if (self = [super init]) {
        _isNeedResize = YES;
        self.interceptionTool = [[WLVideoInterceptionTool alloc] initWithVideoURL:videoURL];
        self.imageresizerComplete = imageresizerComplete;
    }
    return self;
}

- (instancetype)initWithInterceptionTool:(WLVideoInterceptionTool *)interceptionTool imageresizerComplete:(void (^)(UIImage *))imageresizerComplete {
    if (self = [super init]) {
        _isNeedResize = YES;
        self.interceptionTool = interceptionTool;
        self.imageresizerComplete = imageresizerComplete;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupBase];
    [self __setupBottomView];
    [self __setupPlayerLayer];
    [self __setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
#pragma clang diagnostic pop
    
    if (_isDidAppear) return;
    
    [self.playerLayer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerOpacity toValue:@1 duration:0.2];
    
    @jp_weakify(self);
    [self.interceptionTool asyncGetDurationAndVideoSizeWithComplete:^(NSTimeInterval duration, CGSize videoSize) {
        @jp_strongify(self);
        if (!self || duration == 0 || videoSize.width == 0 || videoSize.height == 0) return;
        
        CGFloat frameInterval = 1.0 + duration / 60.0;
        if (frameInterval < 1) {
            frameInterval = 1;
        }
        NSInteger frameTotal = duration / frameInterval;
        if (frameTotal > 60) {
            frameTotal = 60;
        }
        
        NSMutableArray *thumbnails = [NSMutableArray array];
        for (NSInteger i = 1; i <= frameTotal; i++) {
            NSTimeInterval second = floor(i * frameInterval * 10) / 10.0;
            CMTime time = CMTimeMakeWithSeconds(second, NSEC_PER_SEC);
            
            WLVideoInterceptionThumbnail *thumbnail = [WLVideoInterceptionThumbnail new];
            thumbnail.index = i - 1;
            thumbnail.time = time;
            [thumbnails addObject:thumbnail];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbnails = thumbnails.copy;
            self->_allItemWidth = WLVideoInterceptionCell.cellWH * thumbnails.count;
            [self.previewView.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isDidAppear) return;
    _isDidAppear = YES;
}

#pragma mark - 初始布局

- (void)__setupBase {
    self.title = @"视频截取";
    self.view.backgroundColor = JPRGBColor(14, 14, 36);
}

- (void)__setupNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
}

- (void)__setupBottomView {
    WLVideoInterceptionPreviewView *previewView = [WLVideoInterceptionPreviewView videoInterceptionPreviewViewWithPlayer:self.player delegate:self];
    
    CGFloat h = previewView.jp_height + JPDiffTabBarH;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, JPPortraitScreenHeight - h, JPPortraitScreenWidth, h)];
    bottomView.backgroundColor = JPRGBColor(35, 35, 55);
    [self.view addSubview:bottomView];
    
    [bottomView addSubview:previewView];
    self.previewView = previewView;
}

- (void)__setupPlayerLayer {
    CGFloat x = JP12Margin;
    CGFloat y = JPNavTopMargin + JP12Margin;
    CGFloat w = JPPortraitScreenWidth - 2 * x;
    CGFloat h = self.previewView.superview.jp_y - JP12Margin - y;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(x, y, w, h);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.opacity = 0;
    [self.view.layer addSublayer:playerLayer];
    self.playerLayer = playerLayer;
}

#pragma mark - 通知方法

#pragma mark - 事件触发方法

- (void)confirmAction {
    [JPProgressHUD show];
    @jp_weakify(self);
    [self.interceptionTool asyncGetCoverImageWithTime:self.player.currentTime pixelWidth:750 complete:^(UIImage *coverImage) {
        @jp_strongify(self);
        if (!self) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (coverImage) {
                [JPProgressHUD dismiss];
                if (self.isNeedResize) {
                    [self __goResize:coverImage];
                } else {
                    !self.imageresizerComplete ? : self.imageresizerComplete(coverImage);
                }
            } else {
                [JPProgressHUD showErrorWithStatus:@"截取失败，请重试" userInteractionEnabled:YES];
            }
        });
    }];
}

#pragma mark - 重写父类方法

#pragma mark - 系统方法

#pragma mark - 私有方法

- (void)__goResize:(UIImage *)image {
//    JPImageresizerViewController *imageresizerVC = [[UIStoryboard storyboardWithName:@"JPLiveModuleStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"JPImageresizerViewController"];
//    imageresizerVC.resizeImage = image;
//    imageresizerVC.resizeWHScale = self.interceptionTool.videoSize.width / self.interceptionTool.videoSize.height;
//    imageresizerVC.isOriginImageresizer = YES;
//    @jp_weakify(self);
//    imageresizerVC.viewWillAppearBlock = ^{
//        @jp_strongify(self);
//        if (!self) return;
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//    };
//    imageresizerVC.imageresizerComplete = ^(UIImage * _Nonnull resizeDoneImage) {
//        @jp_strongify(self);
//        if (!self) return;
//        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
//        if (index > 0) [self.navigationController popToViewController:self.navigationController.viewControllers[index - 1] animated:YES];
//        !self.imageresizerComplete ? : self.imageresizerComplete(resizeDoneImage);
//    };
//    [self.navigationController pushViewController:imageresizerVC animated:YES];
}

#pragma mark - 公开方法

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnails.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLVideoInterceptionThumbnail *thumbnail = self.thumbnails[indexPath.item];
    // 这时候调用 cellForItemAtIndexPath 会获取nil，因为此时的这个cell超出显示范围或还没初始完毕
    return [self.previewView dequeueReusableCellForIndexPath:indexPath imageRef:thumbnail.imageRef];;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(WLVideoInterceptionCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    WLVideoInterceptionThumbnail *thumbnail = self.thumbnails[indexPath.item];
    if (thumbnail.imageRef) return;
    
    __weak typeof(thumbnail) weakThumbnail = thumbnail;
    @jp_weakify(self);
    [self.interceptionTool asyncGetOneThumbnailWithTime:thumbnail.time complete:^(id kThumbnail) {
        @jp_strongify(self);
        if (!self || !weakThumbnail)  return;
        weakThumbnail.imageRef = kThumbnail;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([collectionView.indexPathsForVisibleItems containsObject:indexPath]) [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        });
    }];
    
    // 在这里调用 cellForItemAtIndexPath 还是会获取nil，因为此时的这个cell超出显示范围或还没初始完毕，不过在这里之后就获取到了，例如在 dispatch_async(dispatch_get_main_queue(), ^{} 里面调用就获取就可以拿到，因为任务是排在这个方法之后。
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat process = offsetX / _allItemWidth;
    NSTimeInterval second = _interceptionTool.duration * process;
    CMTime time = CMTimeMakeWithSeconds(second, _interceptionTool.timescale); // NSEC_PER_SEC
    CMTime toleranceTime = _interceptionTool.toleranceTime;
    [_player ss_seekToTime:time toleranceBefore:toleranceTime toleranceAfter:toleranceTime completionHandler:nil];
}

@end
