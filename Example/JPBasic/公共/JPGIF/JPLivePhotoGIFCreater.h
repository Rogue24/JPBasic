//
//  JPLivePhotoGIFCreater.h
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/2.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPGIFCreaterProtocol.h"
#import <Photos/Photos.h>

@interface JPLivePhotoGIFCreater : NSObject <JPGIFCreaterProtocol>
@property (nonatomic, strong, readonly) dispatch_semaphore_t maxConcurrentOperationLock;
@property (nonatomic, strong, readonly) dispatch_semaphore_t operationLock;
@property (nonatomic, strong, readonly) dispatch_group_t operationGroup;
@property (nonatomic, strong, readonly) dispatch_queue_t operationQueue;

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

- (void)createGIF:(NSArray<PHAsset *> *)assets completion:(void(^)(NSURL *gifFileURL))completion;
@end

@interface JPLivePhotoGIFObject : NSObject
- (instancetype)initWithVideoFileURL:(NSURL *)videoFileURL frameInterval:(NSUInteger)frameInterval;
@property (nonatomic, strong, readonly) NSURL *videoFileURL;
@property (nonatomic, strong, readonly) AVAsset *videoAsset;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSUInteger frameTotal;
@end
