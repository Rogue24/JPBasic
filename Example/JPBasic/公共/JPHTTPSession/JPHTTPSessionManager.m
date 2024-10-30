//
//  JPHTTPSessionManager.m
//  WoLive
//
//  Created by 周健平 on 2018/3/28.
//  Copyright © 2018年 沃直播. All rights reserved.
//

#import "JPHTTPSessionManager.h"
#import <AFNetworking/AFNetworking.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "JPDeviceTool.h"
#import "UIImage+JPExtension.h"

NSString *const JPReachabilityStatusDidChangeNotification = @"JPReachabilityStatusDidChangeNotification";

@interface JPHTTPSessionManager ()
- (AFHTTPSessionManager *)basicManager;
- (AFHTTPSessionManager *)uploadManager;
- (AFHTTPSessionManager *)downloadManager;
@property (nonatomic, assign) JPReachabilityStatus oldStatus;
@end

@implementation JPHTTPSessionManager
{
    AFHTTPSessionManager *_basicManager;
    AFHTTPSessionManager *_uploadManager;
    AFHTTPSessionManager *_downloadManager;
}

#pragma mark - singleton

JPSingtonImplement(JPHTTPSessionManager)

- (instancetype)init {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 开启网络监视器
            [self reachability];
        });
    }
    return self;
}

#pragma mark - manager lazy

- (AFHTTPSessionManager *)createSessionManager {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://github.com/Rogue24"] sessionConfiguration:configuration];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    manager.requestSerializer.timeoutInterval = 10.0;
    return manager;
}

- (AFHTTPSessionManager *)basicManager {
    if (!_basicManager) {
        _basicManager = [self createSessionManager];
        _basicManager.completionQueue = dispatch_queue_create("com.jp_basicSession.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _basicManager;
}

- (AFHTTPSessionManager *)uploadManager {
    if (!_uploadManager) {
        _uploadManager = [self createSessionManager];
        _uploadManager.completionQueue = dispatch_queue_create("com.jp_uploadSession.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _uploadManager;
}

- (AFHTTPSessionManager *)downloadManager {
    if (!_downloadManager) {
        _downloadManager = [self createSessionManager];
        _downloadManager.completionQueue = dispatch_queue_create("com.jp_downloadSession.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _downloadManager;
}

#pragma mark - API

#pragma mark 获取队列（并发）
- (dispatch_queue_t)basicQueue {
    return self.basicManager.completionQueue;
}
- (dispatch_queue_t)uploadQueue {
    return self.uploadManager.completionQueue;
}
- (dispatch_queue_t)downloadQueue {
    return self.downloadManager.completionQueue;
}

#pragma mark 获取网络状态
- (JPReachabilityStatus)reachabilityStatus {
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    switch (reachabilityManager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusUnknown:            // 未知网络
            return JPReachabilityStatus_Unknown;
        case AFNetworkReachabilityStatusNotReachable:       // 没有网络
            return JPReachabilityStatus_NotReachable;
        case AFNetworkReachabilityStatusReachableViaWWAN:   // 蜂窝网络
            return JPReachabilityStatus_ReachableViaWWAN;
        case AFNetworkReachabilityStatusReachableViaWiFi:   // WIFI
            return JPReachabilityStatus_ReachableViaWiFi;
    }
}

#pragma mark 监听网络状态
- (void)reachability {
    self.oldStatus = self.reachabilityStatus;
    
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    
    @jp_weakify(self);
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @jp_strongify(self);
        if (!self) return;
        
        JPReachabilityStatus oldStatus = self->_oldStatus;
        JPReachabilityStatus newStatus;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:            // 未知网络
                newStatus = JPReachabilityStatus_Unknown;
                break;
            case AFNetworkReachabilityStatusNotReachable:       // 没有网络
                newStatus = JPReachabilityStatus_NotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:   // 蜂窝网络
                newStatus = JPReachabilityStatus_ReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:   // WIFI
                newStatus = JPReachabilityStatus_ReachableViaWiFi;
                break;
        }
        self->_oldStatus = newStatus;
        
        NSDictionary *userInfo = @{@"oldStatus": @(oldStatus),
                                   @"newStatus": @(newStatus)};
        JPPostNotification(JPReachabilityStatusDidChangeNotification, nil, userInfo);
    }];
}

#pragma mark 获取当前📶
- (JPSignalIntensityLevel)currentSignalIntensityLevel {
    if (@available(iOS 13.0, *)) {
        return JPSignalIntensity_Lose;
    }
    
    if (self.reachabilityStatus == JPReachabilityStatus_Unknown ||
        self.reachabilityStatus == JPReachabilityStatus_NotReachable) {
        return JPSignalIntensity_Lose;
    }
    
    BOOL isWiFi = self.reachabilityStatus == JPReachabilityStatus_ReachableViaWiFi;
    
    int signalIntensity = [JPDeviceTool getSignalIntensity:isWiFi];
    
    JPSignalIntensityLevel signalIntensityLevel;
    
    switch (signalIntensity) {
        case 1:
            signalIntensityLevel = JPSignalIntensity_Feeble;
            break;
        case 2:
            signalIntensityLevel = isWiFi ? JPSignalIntensity_Good : JPSignalIntensity_Medium;
            break;
        case 3:
            signalIntensityLevel = isWiFi ? JPSignalIntensity_Strongest : JPSignalIntensity_Good;
            break;
        case 4:
            signalIntensityLevel = JPSignalIntensity_Strongest;
            break;
        default:
            signalIntensityLevel = JPSignalIntensity_Lose;
            break;
    }
    
    return signalIntensityLevel;
}

#pragma mark 获取IP地址
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

#pragma mark - 基本数据请求

#pragma mark POST

- (NSURLSessionDataTask *)POST:(NSString *)URLStr
                     parameter:(NSDictionary *)parameter
                successHandler:(JPSessionSuccessHandler)successHandler
                failureHandler:(JPSessionFailureHandler)failureHandler {
    return [self POST:URLStr
            parameter:parameter
       isJSONResponse:YES
confirmParameterHandler:nil
       successHandler:successHandler
       failureHandler:failureHandler];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLStr
                     parameter:(NSDictionary *)parameter
                isJSONResponse:(BOOL)isJSONResponse
       confirmParameterHandler:(JPSessionConfirmParameterHandler)confirmParameterHandler
                successHandler:(JPSessionSuccessHandler)successHandler
                failureHandler:(JPSessionFailureHandler)failureHandler {
    NSMutableDictionary *parameterDic = parameter.mutableCopy;
    !confirmParameterHandler ? : confirmParameterHandler(parameterDic);
    
    return [self.basicManager POST:URLStr parameters:parameterDic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!successHandler) return;
        if (isJSONResponse) {
            NSDictionary *responseDic = [JPHTTPSessionTool JSONObjectWithData:responseObject error:nil];
            successHandler(task, responseDic);
        } else {
            successHandler(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!failureHandler) return;
        BOOL isCancelMyself = error != nil && error.code == NSURLErrorCancelled;
        dispatch_async(dispatch_get_main_queue(), ^{
            failureHandler(task, error, isCancelMyself);
        });
    }];
}

#pragma mark GET

- (NSURLSessionDataTask *)GET:(NSString *)URLStr
                    parameter:(NSDictionary *)parameter
               successHandler:(JPSessionSuccessHandler)successHandler
               failureHandler:(JPSessionFailureHandler)failureHandler {
    return [self GET:URLStr
           parameter:parameter
      isJSONResponse:YES
confirmParameterHandler:nil
      successHandler:successHandler
      failureHandler:failureHandler];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLStr
                    parameter:(NSDictionary *)parameter
               isJSONResponse:(BOOL)isJSONResponse
      confirmParameterHandler:(JPSessionConfirmParameterHandler)confirmParameterHandler
               successHandler:(JPSessionSuccessHandler)successHandler
               failureHandler:(JPSessionFailureHandler)failureHandler {
    
    NSMutableDictionary *parameterDic = parameter.mutableCopy;
    !confirmParameterHandler ? : confirmParameterHandler(parameterDic);
    
    return [self.basicManager GET:URLStr parameters:parameterDic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!successHandler) return;
        if (isJSONResponse) {
            NSDictionary *responseDic = [JPHTTPSessionTool JSONObjectWithData:responseObject error:nil];
            successHandler(task, responseDic);
        } else {
            successHandler(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!failureHandler) return;
        BOOL isCancelMyself = error != nil && error.code == NSURLErrorCancelled;
        dispatch_async(dispatch_get_main_queue(), ^{
            failureHandler(task, error, isCancelMyself);
        });
    }];
}

//#pragma mark - 上传请求
//
//- (void)uploadWoLiveImage:(UIImage *)image
//          uploadingStatus:(NSString *)uploadingStatus
//          progressHandler:(JPSessionProgressHandler)progressHandler
//           successHandler:(void(^)(NSString *imageURLStr))successHandler {
//    [JPProgressHUD showWithStatus:uploadingStatus];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        BOOL isPNG = NO;
//        NSData *imageData = [image jp_image2DataWithIsPNG:&isPNG maxPixelWidth:WLUploadImageMaxPixelWidth];
//        if (!imageData) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [JPProgressHUD showErrorWithStatus:@"图片格式错误，请重试" userInteractionEnabled:YES];
//            });
//            return;
//        }
//        [self uploadImageWithImageData:imageData isPNG:isPNG progressHandler:progressHandler successHandler:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
//            NSInteger status = [responseObject[@"status"] integerValue];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (status != 0) {
//                    NSString *message = responseObject[@"message"];
//                    if (!message.length) message = @"服务器异常，请重试";
//                    [JPProgressHUD showInfoWithStatus:message userInteractionEnabled:YES];
//                } else {
//                    NSString *imageURLStr = responseObject[@"userHeadLogo"];
//                    if (imageURLStr.length) {
//                        if (successHandler) {
//                            successHandler(imageURLStr);
//                        } else {
//                            [JPProgressHUD dismiss];
//                        }
//                    } else {
//                        [JPProgressHUD showInfoWithStatus:@"图片过大，请重新上传" userInteractionEnabled:YES];
//                    }
//                }
//            });
//        } failureHandler:^(NSURLSessionDataTask *task, NSError *error, BOOL isCancelMyself) {
//            if (!isCancelMyself) [JPProgressHUD showErrorWithStatus:@"网络错误，图片上传失败" userInteractionEnabled:YES];
//        }];
//    });
//}
//
//- (NSURLSessionDataTask *)uploadImageWithImageData:(NSData *)imageData
//                                             isPNG:(BOOL)isPNG
//                                   progressHandler:(JPSessionProgressHandler)progressHandler
//                                    successHandler:(JPSessionSuccessHandler)successHandler
//                                    failureHandler:(JPSessionFailureHandler)failureHandler {
//    return [self uploadWithFileData:imageData
//                               name:WLUploadImageName
//                           fileName:WLUploadImageFileName
//                           mimeType:(isPNG ? @"image/png" : @"image/jpeg")
//                    progressHandler:progressHandler
//                     successHandler:successHandler
//                     failureHandler:failureHandler];
//}
//
//- (NSURLSessionDataTask *)uploadWithFileData:(NSData *)fileData
//                                        name:(NSString *)name
//                                    fileName:(NSString *)fileName
//                                    mimeType:(NSString *)mimeType
//                             progressHandler:(JPSessionProgressHandler)progressHandler
//                              successHandler:(JPSessionSuccessHandler)successHandler
//                              failureHandler:(JPSessionFailureHandler)failureHandler {
//
//    void (^uploadProgressHandler)(NSProgress *uploadProgress) = nil;
//    if (progressHandler) {
//        uploadProgressHandler = ^(NSProgress *uploadProgress) {
//            float percent = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                progressHandler(percent);
//            });
//        };
//    }
//
//    return [self.uploadManager POST:WLUploadImageURLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
//    } progress:uploadProgressHandler success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (!successHandler) return;
//        NSDictionary *responseDic = [JPHTTPSessionTool JSONObjectWithData:responseObject error:nil];
//        successHandler(task, responseDic);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (!failureHandler) return;
//        BOOL isCancelMyself = error != nil && error.code == NSURLErrorCancelled;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            failureHandler(task, error, isCancelMyself);
//        });
//    }];
//}

#pragma mark - 请求app信息

- (NSURLSessionDataTask *)requestAppInfoWithAppID:(NSString *)appID
                                   successHandler:(JPSessionSuccessHandler)successHandler
                                   failureHandler:(JPSessionFailureHandler)failureHandler {
    return [self.basicManager GET:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@", appID] parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!successHandler) return;
        NSDictionary *responseDic = [JPHTTPSessionTool JSONObjectWithData:responseObject error:nil];
        successHandler(task, responseDic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!failureHandler) return;
        BOOL isCancelMyself = error != nil && error.code == NSURLErrorCancelled;
        dispatch_async(dispatch_get_main_queue(), ^{
            failureHandler(task, error, isCancelMyself);
        });
    }];
}

@end
