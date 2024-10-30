//
//  WTVRedPacketPopView.h
//  WoTV
//
//  Created by 周恩慧 on 2018/2/6.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RedPackageRainShareHandle)(id model);
typedef void(^RedPackageRainShareResponseHandler)(BOOL shareSuccess);
typedef void(^RedPackageRainShareDataRequestHandler)(NSInteger shareType, RedPackageRainShareHandle shareHandle);

typedef NS_ENUM(NSUInteger, WTVRedPacketPopViewType) {
    /** 兑换失败*/
    WTVRedPacketPopViewConversionFail,
    /** 分享*/
    WTVRedPacketPopViewShare,
    /** 分享成功*/
    WTVRedPacketPopViewShareSuccess,
    /** 已经受理*/
    WTVRedPacketPopViewConversionSuccess,
    /** 兑换某样东西*/
    WTVRedPacketPopViewConversionSomething,
    
    WTVRedPacketPopViewNeedLogin,
};
@interface WTVRedPacketPopView : UIView

@property (nonatomic, assign)WTVRedPacketPopViewType popViewType;

/** 要兑换的东西*/
@property (nonatomic, copy) NSString *conversionString;

@property (nonatomic, copy) void (^sureHandler)(void);
@property (nonatomic, copy) void (^cancelHandle)(void);

+ (WTVRedPacketPopView *)sharePopViewWithTitle:(NSString *)title dataRequestHandle:(RedPackageRainShareDataRequestHandler)dataRequestHandle responseHandler:(RedPackageRainShareResponseHandler)responseHandler;

+ (WTVRedPacketPopView *)loginPopViewWithSureHandler:(void(^)(void))sureHandler cancelHandle:(void(^)(void))cancelHandle;

+ (WTVRedPacketPopView *)conversionPopViewWithConversionString:(NSString *)conversionString promptString:(NSString *)promptString sureHandler:(void(^)(void))sureHandler cancelHandle:(void(^)(void))cancelHandle;

- (void)conversionSuccess;
- (void)conversionFail;
- (void)shareSuccess:(BOOL)isGive;

- (void)closeAction;

- (void)setIsRequesting:(BOOL)isRequest;

@end
