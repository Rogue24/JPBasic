//
//  AVPlayer+SeekSmoothly.h
//  JPGIFCreater_Example
//
//  Created by 周健平 on 2020/1/8.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVPlayer (SeekSmoothly)

- (void)ss_seekToTime:(CMTime)time;

- (void)ss_seekToTime:(CMTime)time
      toleranceBefore:(CMTime)toleranceBefore
       toleranceAfter:(CMTime)toleranceAfter
    completionHandler:(void (^)(BOOL))completionHandler;
@end
