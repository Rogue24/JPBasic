//
//  JPHTTPSessionManager.h
//  WoLive
//
//  Created by 周健平 on 2018/3/28.
//  Copyright © 2018年 沃直播. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPHTTPSessionTool.h"

#define JPSessionManager [JPHTTPSessionManager sharedInstance]

/**
 * Notification: 网络状态发生改变的通知
 * object: nil
 * userInfo: @{@"oldStatus": 原状态, @"newStatus": 新状态}
 */
UIKIT_EXTERN NSString *const JPReachabilityStatusDidChangeNotification;

typedef NS_ENUM(NSUInteger, JPReachabilityStatus) {
    JPReachabilityStatus_Unknown,            // 未知网络
    JPReachabilityStatus_NotReachable,       // 没有网络
    JPReachabilityStatus_ReachableViaWWAN,   // 蜂窝网络
    JPReachabilityStatus_ReachableViaWiFi    // WIFI
};

typedef NS_ENUM(NSUInteger, JPSignalIntensityLevel) {
    JPSignalIntensity_Lose,      // 没有信号（全红）
    JPSignalIntensity_Feeble,    // 信号弱（1格）
    JPSignalIntensity_Medium,    // 信号一般（2格）
    JPSignalIntensity_Good,      // 信号良好（3格）
    JPSignalIntensity_Strongest  // 信号最好（满格）
};

typedef void(^JPSessionConfirmParameterHandler)(NSMutableDictionary *mParameter);
typedef void(^JPSessionProgressHandler)(float percent);
typedef void(^JPSessionSuccessHandler)(NSURLSessionDataTask *task, id responseObject);
typedef void(^JPSessionFailureHandler)(NSURLSessionDataTask *task, NSError *error, BOOL isCancelMyself);

@interface JPHTTPSessionManager : NSObject
JPSingtonInterface

#pragma mark - API

#pragma mark 获取队列（并发）
- (dispatch_queue_t)basicQueue;
- (dispatch_queue_t)uploadQueue;
- (dispatch_queue_t)downloadQueue;

#pragma mark 获取网络状态
- (JPReachabilityStatus)reachabilityStatus;

#pragma mark 获取当前📶
- (JPSignalIntensityLevel)currentSignalIntensityLevel;

#pragma mark 获取IP地址
- (NSString *)getIPAddress;

#pragma mark - 基本数据请求
/** <<基本数据说明>>
 * prefixURLType：接口前缀类型（使用WLPrefixURLType枚举传入）
 * suffixURLStr：接口后缀（不需要再拼接再传入）
    - 完整url为：https://wotest.17wo.cn/前缀/后缀
 * parameter：接口参数，类型为NSDictionary（key：参数名 value：参数值）
 * isJSONResponse：响应数据是否以JSON格式返回（即成功回调的 responseObject 为 NSDictionary 类型，可把 id 修改为 NSDictionary *），否则就是原格式 --- NSData
 * confirmParameterHandler：用作参数的最后确认
    - mParameter：参数可变字典，可修改基本参数
 * successHandler：响应成功回调【在子线程回调！因为大部分情况拿到数据都要进行数据转换的操作，所以丢子线程里面，记得刷新界面时回到主线程操作】
    - task：请求的task
    - responseObject：响应数据
 * failureHandler：响应失败回调【在主线程回调】
    - task：请求的task
    - error：错误
    - isCancelMyself：是否手动取消请求
 */

#pragma mark POST

- (NSURLSessionDataTask *)POST:(NSString *)URLStr
                     parameter:(NSDictionary *)parameter
                successHandler:(JPSessionSuccessHandler)successHandler
                failureHandler:(JPSessionFailureHandler)failureHandler;

- (NSURLSessionDataTask *)POST:(NSString *)URLStr
                     parameter:(NSDictionary *)parameter
                isJSONResponse:(BOOL)isJSONResponse
       confirmParameterHandler:(JPSessionConfirmParameterHandler)confirmParameterHandler
                successHandler:(JPSessionSuccessHandler)successHandler
                failureHandler:(JPSessionFailureHandler)failureHandler;

#pragma mark GET

- (NSURLSessionDataTask *)GET:(NSString *)URLStr
                    parameter:(NSDictionary *)parameter
               successHandler:(JPSessionSuccessHandler)successHandler
               failureHandler:(JPSessionFailureHandler)failureHandler;

- (NSURLSessionDataTask *)GET:(NSString *)URLStr
                    parameter:(NSDictionary *)parameter
               isJSONResponse:(BOOL)isJSONResponse
      confirmParameterHandler:(JPSessionConfirmParameterHandler)confirmParameterHandler
               successHandler:(JPSessionSuccessHandler)successHandler
               failureHandler:(JPSessionFailureHandler)failureHandler;

#pragma mark - 上传请求
/** <<上传说明>>
 * prefixURLType：同上
 * suffixURLStr：同上
 * parameter：同上
 * successHandler：同上（json格式返回）
 * failureHandler：同上
 * imageData：打包好的图片data
    - 使用"UIImagePNGRepresentation"或"UIImageJPEGRepresentation"创建
 * isPNG：是否为png格式，否则就jpg
 * name：对应网站上处理文件的字段（貌似没啥用可以随便写，目前写死"userfile"）
 * fileName：要保存在服务器上的文件名（拼接方式为：app名称_格林尼治时间_用户id）
 * mimeType：上传的文件的类型（"image/png"或"image/jpeg"）
 * progressHandler：上传进度回调【回调是在主线程】
    - percent：上传的百分比（0~1）
 */

/**
 * 沃直播的上传图片方法，自带压缩图片、弹出上传中和失败的信息提醒
 */
//- (void)uploadWoLiveImage:(UIImage *)image
//          uploadingStatus:(NSString *)uploadingStatus
//          progressHandler:(JPSessionProgressHandler)progressHandler
//           successHandler:(void(^)(NSString *imageURLStr))successHandler;
//
///**
// * 上传图片（固定套路）
// */
//- (NSURLSessionDataTask *)uploadImageWithImageData:(NSData *)imageData
//                                             isPNG:(BOOL)isPNG
//                                   progressHandler:(JPSessionProgressHandler)progressHandler
//                                    successHandler:(JPSessionSuccessHandler)successHandler
//                                    failureHandler:(JPSessionFailureHandler)failureHandler;
///**
// * 完全自定义格式上传
// */
//- (NSURLSessionDataTask *)uploadWithFileData:(NSData *)fileData
//                                        name:(NSString *)name
//                                    fileName:(NSString *)fileName
//                                    mimeType:(NSString *)mimeType
//                             progressHandler:(JPSessionProgressHandler)progressHandler
//                              successHandler:(JPSessionSuccessHandler)successHandler
//                              failureHandler:(JPSessionFailureHandler)failureHandler;

#pragma mark - 请求app信息
/**
 * 请求app信息
 */
- (NSURLSessionDataTask *)requestAppInfoWithAppID:(NSString *)appID
                                   successHandler:(JPSessionSuccessHandler)successHandler
                                   failureHandler:(JPSessionFailureHandler)failureHandler;

@end
