//
//  WTVRedPackageRainManager.h
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTVRedPackagePendantView.h"

@class WTVRedPackageRainActivityTimeModel;
@class WTVRedPackageRainScreeningsModel;
@class WTVRedPackageRainGiftModel;

@class WTVvertiLoginVC;

#define RPManager [WTVRedPackageRainManager sharedInstance]

#define RedPackageRainTrailerNotification @"RedPackageRainTrailerNotification"
#define RedPackageRainStartNotification @"RedPackageRainStartNotification"
#define RedPackageRainFinishNotification @"RedPackageRainFinishNotification"

// 测试
//#define RuleURLStr @"https://wotest.17wo.cn/wovideo/promotioncenter/festivalPage/description.html"
//#define ShareDogURLAppend(codeStr) [NSString stringWithFormat:@"https://wotest.17wo.cn/wovideo/celestail/dog/share?code=%@", codeStr]

// 正式
#define RuleURLStr @"https://wodog.17wo.cn/wovideo/promotioncenter/festivalPage/description.html"
#define ShareDogURLAppend(codeStr) [NSString stringWithFormat:@"https://wodog.17wo.cn/wovideo/celestail/dog/share?code=%@", codeStr]

typedef NS_ENUM(NSUInteger, WTVRedPackageRainScreeningsState) {
    WTVScreeningsNormalState,
    WTVScreeningsReadyBeginState,
    WTVScreeningsOnGoingState,
    WTVScreeningsFinishState
};

typedef NS_ENUM(NSUInteger, WTVRedPackageRainGiftType) {
    WTVHanTianDogType,
    WTVTongTianDogType,
    WTVXuanTianDogType,
    WTVFeiTianDogType,
    WTVHuanTianDogType,
    WTVXiaoTianDogType,
    WTVProvinceTrafficType,
    WTVDomesticTrafficType
};

typedef NS_ENUM(NSUInteger, WTVRedPackageRainPrizeType) {
    WTVDogPrizeType = 1,
    WTVProvinceTrafficPrizeType = 2,
    WTVDomesticTrafficPrizeType = 3
};

@interface WTVRedPackageRainManager : NSObject

JPSingtonInterface

- (void)presentRedPackageRainViewController;

- (void)requestRedPackageRainActivityTimeWithSuperVC:(UIViewController *)superVC;

- (void)showLoginPopViewWithPresentedLoginVCBlock:(void(^)(void))presentedLoginVCBlock;

// BOOL
@property (nonatomic, assign) BOOL canRedPackageRain;
@property (nonatomic, assign) BOOL canExchangePrize;

// Foundation
@property (nonatomic, copy) NSString *currentPhone;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSURL *bgMusicURL;
@property (nonatomic, strong) NSURL *boomMusicURL;

// UIKit
@property (nonatomic, strong) WTVRedPackagePendantView *pendantView;
@property (nonatomic, weak) WTVRedPackageRainViewController *redPackageRainVC;
@property (nonatomic, weak) WTVvertiLoginVC *verLoginVC;

// Model
@property (nonatomic, strong) WTVRedPackageRainActivityTimeModel *activityTimeModel;
@property (nonatomic, strong) NSMutableArray<WTVRedPackageRainScreeningsModel *> *screeningsModels;
@property (nonatomic, strong) NSMutableArray<WTVRedPackageRainScreeningsModel *> *finishScreeningsModels;

@property (nonatomic) BOOL isVerScreen;
@property (nonatomic) BOOL isPhoneLogin;
@property (nonatomic) NSTimeInterval currentTimeInt;
@property (nonatomic) WTVRedPackageRainScreeningsModel *currentScreeningsModel;

@end

@interface WTVRedPackageRainActivityTimeModel : NSObject
@property (nonatomic, copy) NSString *eventID;
@property (nonatomic, copy) NSString *eventOpenTime;
@property (nonatomic, copy) NSString *eventCloseTime;
@property (nonatomic, copy) NSString *exchangeCloseTime;

@property (nonatomic, assign) NSTimeInterval eventOpenTimeInt;
@property (nonatomic, assign) NSTimeInterval eventCloseTimeInt;
@property (nonatomic, assign) NSTimeInterval exchangeCloseTimeInt;
@end

@interface WTVRedPackageRainScreeningsModel : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *starttime;
@property (nonatomic, copy) NSString *endtime;

@property (nonatomic, assign) NSTimeInterval trailerTimeInt;
@property (nonatomic, assign) NSTimeInterval starttimeInt;
@property (nonatomic, assign) NSTimeInterval endtimeInt;

@property (nonatomic, assign) WTVRedPackageRainScreeningsState state;
@property (nonatomic, strong) NSMutableArray<WTVRedPackageRainGiftModel *> *gitfModels;
@end

@interface WTVRedPackageRainGiftModel : NSObject
@property (nonatomic, assign) NSInteger actualCount;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *image2;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) WTVRedPackageRainGiftType giftType;
+ (instancetype)copyWithGiftModel:(WTVRedPackageRainGiftModel *)giftModel;
@end

@interface WTVRedPackageRainPrizeModel : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) WTVRedPackageRainPrizeType type;
@property (nonatomic, assign) NSInteger presentNeed;
@property (nonatomic, assign) NSInteger remain;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image;
@end

@interface WTVRedPackageRainDogModel : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) WTVRedPackageRainGiftType giftType;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *image2;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nick;
+ (NSArray *)noPhoneLoginModels;
@end
