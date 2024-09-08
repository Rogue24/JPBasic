//
//  AVPlayerViewController+JPExtension.h
//  JPBasic
//
//  Created by aa on 2022/3/11.
//

#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVPlayerViewController (JPExtension)
+ (BOOL)playLocalVideo:(NSString *)filePath isAutoPlay:(BOOL)isAutoPlay;
+ (BOOL)playLocalVideo:(NSString *)filePath;
@end

NS_ASSUME_NONNULL_END
