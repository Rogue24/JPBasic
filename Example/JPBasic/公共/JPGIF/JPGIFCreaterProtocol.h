//
//  JPGIFCreaterProtocol.h
//  JPBasic
//
//  Created by 周健平 on 2020/1/2.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
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

@protocol JPGIFCreaterProtocol <NSObject>

@property (nonatomic, strong, readonly) dispatch_semaphore_t maxConcurrentOperationLock;
@property (nonatomic, strong, readonly) dispatch_semaphore_t operationLock;
@property (nonatomic, strong, readonly) dispatch_group_t operationGroup;
@property (nonatomic, strong, readonly) dispatch_queue_t operationQueue;

//@property (nonatomic, assign) CGSize gifMaxSize;
//@property (nonatomic, assign) CGFloat gifWhScale;

@property (nonatomic, assign) NSUInteger frameInterval;
@property (nonatomic, assign, readonly) float fps;

@property (nonatomic, assign) NSTimeInterval gifMinSecond;
@property (nonatomic, assign) NSTimeInterval gifMaxSecond;
@property (nonatomic, assign, readonly) NSTimeInterval gifFactSecond;

@property (nonatomic, assign, readonly) JPGifState gifState;
@property (nonatomic, assign, readonly) BOOL isCreateGIF;

@property (nonatomic, copy) void (^gifStartRecord)(void);
@property (nonatomic, copy) void (^gifConfirmCreate)(void);
@property (nonatomic, copy) void (^gifPrepareCreate)(void);
@property (nonatomic, copy) void (^gifStartCreate)(UIImage *placeholder);
@property (nonatomic, copy) void (^gifCreateFailed)(JPGifFailReason failReason);
@property (nonatomic, copy) void (^gifCreateSuccess)(NSString *gifFilePath);
- (void)jp_gifReset;

@end
