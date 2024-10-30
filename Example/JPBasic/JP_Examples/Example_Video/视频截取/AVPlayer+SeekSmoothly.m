//
//  AVPlayer+SeekSmoothly.m
//  JPGIFCreater_Example
//
//  Created by 周健平 on 2020/1/8.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "AVPlayer+SeekSmoothly.h"
#import <objc/runtime.h>

@interface AVPlayerSeeker : NSObject
{
    CMTime targetTime;
    BOOL isSeeking;
}

@property (weak, nonatomic) AVPlayer *player;

@end

@implementation AVPlayerSeeker

- (instancetype)initWithPlayer:(AVPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

- (void)seekSmoothlyToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    targetTime = time;
    if (!isSeeking) {
        [self trySeekToTargetTimeWithToleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
    }
}

- (void)trySeekToTargetTimeWithToleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [self seekToTargetTimeToleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
    }
}

- (void)seekToTargetTimeToleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    isSeeking = YES;
    CMTime seekingTime = targetTime;
    @jp_weakify(self);
    [self.player seekToTime:seekingTime toleranceBefore:toleranceBefore
             toleranceAfter:toleranceAfter completionHandler:^(BOOL isFinished) {
        @jp_strongify(self);
        if (!self) return;
        if (CMTIME_COMPARE_INLINE(seekingTime, ==, self->targetTime)) {
            // seek completed
            self->isSeeking = NO;
            if (completionHandler) {
                completionHandler(isFinished);
            }
        } else {
            // targetTime has changed, seek again
            [self trySeekToTargetTimeWithToleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
        }
    }];
}

@end


static const char seekerKey = '\0';

@implementation AVPlayer (SeekSmoothly)

- (void)ss_seekToTime:(CMTime)time {
    [self ss_seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
}

- (void)ss_seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {

    AVPlayerSeeker *seeker = objc_getAssociatedObject(self, &seekerKey);
    if (!seeker) {
        seeker = [[AVPlayerSeeker alloc] initWithPlayer:self];
        objc_setAssociatedObject(self, &seekerKey, seeker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    [self pause];
    [seeker seekSmoothlyToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}

@end
