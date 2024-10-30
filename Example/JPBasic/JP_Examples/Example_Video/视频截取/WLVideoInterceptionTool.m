//
//  WLVideoInterceptionTool.m
//  WoLive
//
//  Created by 周健平 on 2020/3/31.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import "WLVideoInterceptionTool.h"
#import "WLVideoInterceptionPreviewView.h"

@interface WLVideoInterceptionTool ()
@property (nonatomic, strong) NSOperationQueue *serialQueue;
@property (nonatomic, strong) AVAssetImageGenerator *thumbnailGenerator;
@end

@implementation WLVideoInterceptionTool

- (NSOperationQueue *)serialQueue {
    if (!_serialQueue) {
        _serialQueue = [[NSOperationQueue alloc] init];
        _serialQueue.maxConcurrentOperationCount = 1;
    }
    return _serialQueue;
}

- (AVAssetImageGenerator *)thumbnailGenerator {
    if (!_thumbnailGenerator) {
        CGFloat pixelWidth = WLVideoInterceptionCell.cellWH * JPScreenScale;
        CGSize size = CGSizeMake(pixelWidth, pixelWidth * (self.videoSize.height / self.videoSize.width));
        _thumbnailGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
        _thumbnailGenerator.maximumSize = size;
        _thumbnailGenerator.appliesPreferredTrackTransform = YES;
        _thumbnailGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _thumbnailGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    }
    return _thumbnailGenerator;
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    
    [self __cancelAllOperations];
    
    _asset = [AVURLAsset assetWithURL:videoURL];
    _duration = 0;
    _timescale = NSEC_PER_SEC;
    _toleranceTime = kCMTimeZero;
    _videoSize = CGSizeZero;
    
//    JPLog(@"1");
    
    if ([self.asset statusOfValueForKey:JPKeyPath(self.asset, duration) error:nil] == AVKeyValueStatusLoaded &&
        [self.asset statusOfValueForKey:JPKeyPath(self.asset, tracks) error:nil] == AVKeyValueStatusLoaded) {
        [self __getDurationAndVideoSize];
    } else {
        [self asyncGetDurationAndVideoSizeWithComplete:nil];
    }
    
//    JPLog(@"2");
//    JPLog(@"%.2lf %@", _duration, NSStringFromCGSize(_videoSize));
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL {
    if (self = [super init]) {
        self.videoURL = videoURL;
    }
    return self;
}

- (void)dealloc {
    JPLog(@"%s 死了！", __func__);
    [self __cancelAllOperations];
}

- (void)__addOperation:(void (^)(void (^blockComplete)(void)))block {
    if (!block) return;
    @jp_weakify(self);
    // 创建任务
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        @jp_strongify(self);
        if (!self) return;
        self.serialQueue.suspended = YES;
        block(^{self.serialQueue.suspended = NO;});
    }];
    // 添加任务
    [self.serialQueue addOperation:operation];
}

- (void)__cancelAllOperations {
    if (_serialQueue) {
        [_serialQueue cancelAllOperations];
        _serialQueue.suspended = NO;
    }
}

- (void)__getDurationAndVideoSize {
    self->_duration = CMTimeGetSeconds(self.asset.duration);
    self->_timescale = self.asset.duration.timescale;
    self->_toleranceTime = CMTimeMake(0, self->_timescale);
    for (AVAssetTrack *track in self.asset.tracks) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            self->_videoSize = track.naturalSize;
            break;
        }
    }
}

- (void)asyncGetDurationAndVideoSizeWithComplete:(void (^)(NSTimeInterval, CGSize))complete {
    if (self.duration > 0 || self.videoSize.width > 0 || self.videoSize.height > 0) {
        !complete ? : complete(self.duration, self.videoSize);
        return;
    }
    @jp_weakify(self);
    [self __addOperation:^(void (^blockComplete)(void)) {
        @jp_strongify(self);
        if (!self) return;
        [self.asset loadValuesAsynchronouslyForKeys:@[JPKeyPath(self.asset, duration), JPKeyPath(self.asset, tracks)] completionHandler:^{
            if ([self.asset statusOfValueForKey:JPKeyPath(self.asset, duration) error:nil] == AVKeyValueStatusLoaded &&
                [self.asset statusOfValueForKey:JPKeyPath(self.asset, tracks) error:nil] == AVKeyValueStatusLoaded) {
                [self __getDurationAndVideoSize];
            }
            !complete ? : complete(self.duration, self.videoSize);
            blockComplete();
        }];
    }];
}

- (void)asyncGetCoverImageWithTime:(CMTime)time pixelWidth:(CGFloat)pixelWidth complete:(void (^)(UIImage *))complete {
    if (!complete || self.duration == 0 || self.videoSize.width == 0 || self.videoSize.height == 0) return;
    
    @jp_weakify(self);
    [self __addOperation:^(void (^blockComplete)(void)) {
        @jp_strongify(self);
        if (!self) return;
        
        CGSize size = CGSizeMake(pixelWidth, pixelWidth * (self.videoSize.height / self.videoSize.width));
        
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
        generator.maximumSize = size;//如果是CGSizeMake(480,136)，则获取到的图片是{240, 136}。与实际大小成比例 --- 700, 700
        generator.appliesPreferredTrackTransform = YES; //这个属性保证我们获取的图片的方向是正确的。比如有的视频需要旋转手机方向才是视频的正确方向。
                /**因为有误差，所以需要设置以下两个属性。如果不设置误差有点大，设置了之后相差非常非常的小**/
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        
        CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:nil error:nil];
        UIImage *image = imageRef ? [UIImage imageWithCGImage:imageRef] : nil;
        if (imageRef) CGImageRelease(imageRef);
        
        complete(image);
        
        blockComplete();
    }];
}

- (void)asyncGetThumbnailsWithFrameTotal:(NSInteger)frameTotal pixelWidth:(CGFloat)pixelWidth singleComplete:(void(^)(NSInteger index, id thumbnail))singleComplete {
    if (!singleComplete || self.duration == 0 || self.videoSize.width == 0 || self.videoSize.height == 0) return;
    
    @jp_weakify(self);
    [self __addOperation:^(void (^blockComplete)(void)) {
        @jp_strongify(self);
        if (!self) return;
        
        float frameInterval = self.duration / frameTotal;
        
        NSMutableArray *times = [NSMutableArray array];
        for (NSInteger i = 1; i <= frameTotal; i++) {
            NSTimeInterval second = floor(i * frameInterval * 10) / 10.0;
            CMTime time = CMTimeMakeWithSeconds(second, NSEC_PER_SEC);
            [times addObject:[NSValue valueWithCMTime:time]];
        }
        
        CGSize size = CGSizeMake(pixelWidth, pixelWidth * (self.videoSize.height / self.videoSize.width));
        
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
        generator.maximumSize = size;
        generator.appliesPreferredTrackTransform = YES;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        
        [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            if (result != AVAssetImageGeneratorSucceeded) {
                JPLog(@"拿不到啊艹");
            }
            NSInteger index = [times indexOfObject:[NSValue valueWithCMTime:requestedTime]];
            singleComplete(index, (__bridge id)imageRef);
        }];
        
        blockComplete();
    }];
}

- (void)asyncGetOneThumbnailWithTime:(CMTime)time complete:(void(^)(id thumbnail))complete {
    if (!complete || self.duration == 0 || self.videoSize.width == 0 || self.videoSize.height == 0) return;
    
    @jp_weakify(self);
    [self __addOperation:^(void (^blockComplete)(void)) {
        @jp_strongify(self);
        if (!self) return;
        
        CGImageRef imageRef = [self.thumbnailGenerator copyCGImageAtTime:time actualTime:nil error:nil];
        
        complete((__bridge id)imageRef);
        
        blockComplete();
    }];
}

@end
