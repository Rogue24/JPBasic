//
//  WLVideoInterceptionTool.h
//  WoLive
//
//  Created by 周健平 on 2020/3/31.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface WLVideoInterceptionTool : NSObject

- (instancetype)initWithVideoURL:(NSURL *)videoURL;

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) CMTimeScale timescale;
@property (nonatomic, assign, readonly) CMTime toleranceTime;
@property (nonatomic, assign, readonly) CGSize videoSize;

- (void)asyncGetDurationAndVideoSizeWithComplete:(void(^)(NSTimeInterval duration, CGSize videoSize))complete;

- (void)asyncGetCoverImageWithTime:(CMTime)time pixelWidth:(CGFloat)pixelWidth complete:(void(^)(UIImage *coverImage))complete;

- (void)asyncGetThumbnailsWithFrameTotal:(NSInteger)frameTotal pixelWidth:(CGFloat)pixelWidth singleComplete:(void(^)(NSInteger index, id thumbnail))singleComplete;

- (void)asyncGetOneThumbnailWithTime:(CMTime)time complete:(void(^)(id thumbnail))complete;

@end
