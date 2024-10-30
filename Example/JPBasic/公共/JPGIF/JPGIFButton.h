//
//  JPGIFButton.h
//  JPPlayer
//
//  Created by 周健平 on 2019/12/20.
//  Copyright © 2019 cb2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, JPGifState) {
    JPGifState_Idle,
    JPGifState_Recording,
    JPGifState_PrepareCreate,
    JPGifState_Creating,
    JPGifState_CreateFailed,
    JPGifState_CreateSuccess
};

typedef NS_ENUM(NSUInteger, JPGifFailReason) {
    JPGifFailReason_FewTotalDuration,
    JPGifFailReason_FewRecordDuration,
    JPGifFailReason_FewFrameInterval,
    JPGifFailReason_CreateFailed
};

@interface JPGIFButton : UIView
- (void)__setup;

@property (nonatomic, assign) CGSize gifMaxSize;
@property (nonatomic, assign) NSUInteger frameInterval;
@property (nonatomic, assign) NSTimeInterval minRecordSecond;
@property (nonatomic, assign) NSTimeInterval maxRecordSecond;
@property (nonatomic, assign, readonly) NSTimeInterval factRecordSecond;

@property (nonatomic, assign, readonly) JPGifState gifState;
@property (nonatomic, assign, readonly) BOOL isCreateGIF;

@property (nonatomic, copy) void (^gifStartRecord)(void);
@property (nonatomic, copy) void (^gifConfirmCreate)(void);
@property (nonatomic, copy) void (^gifPrepareCreate)(void);
@property (nonatomic, copy) void (^gifStartCreate)(UIImage *firstImage);
@property (nonatomic, copy) void (^gifCreateFailed)(JPGifFailReason failReason);
@property (nonatomic, copy) void (^gifCreateSuccess)(NSString *gifFilePath);

@property (nonatomic, weak) AVPlayer *player;
- (void)setupPlayerItem:(AVPlayerItem *)playerItem
            videoOutput:(AVPlayerItemVideoOutput *)videoOutPut;

- (void)reset;
@end
