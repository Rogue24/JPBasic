//
//  WTVRedPackageRainManager.m
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageRainManager.h"
#import <MJExtension/MJExtension.h>
#import "WTVRedPackageRewardViewController.h"
#import "WTVRedPacketPopView.h"

#define DateFormatter @"yyyy-MM-dd HH:mm:ss"

@interface WTVRedPackageRainManager ()

/** 定时器(这里不用带*，因为dispatch_source_t就是个类，内部已经包含了*) */
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, assign) BOOL isUploadingPrize;

@property (nonatomic, weak) WTVRedPacketPopView *popView;

@property (nonatomic, weak) UIViewController *superVC;
@property (nonatomic, copy) NSString *logoutPhone;
@end

@implementation WTVRedPackageRainManager

#pragma mark - setter

- (WTVRedPackageRainScreeningsModel *)currentScreeningsModel {
    return self.screeningsModels.firstObject;
}

- (void)setCanRedPackageRain:(BOOL)canRedPackageRain {
    _canRedPackageRain = canRedPackageRain;
    if (!canRedPackageRain) {
        [self.pendantView removeFromSuperview];
        self.pendantView = nil;
    }
}

#pragma mark - getter

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = DateFormatter;
    }
    return _dateFormatter;
}

- (NSMutableArray<WTVRedPackageRainScreeningsModel *> *)screeningsModels {
    if (!_screeningsModels) {
        _screeningsModels = [NSMutableArray array];
    }
    return _screeningsModels;
}

- (NSMutableArray<WTVRedPackageRainScreeningsModel *> *)finishScreeningsModels {
    if (!_finishScreeningsModels) {
        _finishScreeningsModels = [NSMutableArray array];
    }
    return _finishScreeningsModels;
}

- (NSTimeInterval)currentTimeInt {
    return [[NSDate date] timeIntervalSince1970];
}

- (NSURL *)bgMusicURL {
    if (!_bgMusicURL) {
        _bgMusicURL = [NSURL fileURLWithPath:JPMainBundleResourcePath(@"red_package_bg_music2", @"mp3")];
    }
    return _bgMusicURL;
}

- (NSURL *)boomMusicURL {
    if (!_boomMusicURL) {
        _boomMusicURL = [NSURL fileURLWithPath:JPMainBundleResourcePath(@"red_package_boom", @"mp3")];
    }
    return _boomMusicURL;
}

#pragma mark - Singleton

JPSingtonImplement(WTVRedPackageRainManager)

- (id)init {
    if (self = [super init]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goLoginHandle) name:WTVvertiLoginVCPresentNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessHandle) name:WTVvertiLoginSuccessNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noLoginOutHandle) name:WTVvertiNoLoginOutNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccessHandle) name:@"WTVvertiLogoutSuccessNotification" object:nil];
        self.currentPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNo"];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupPendantView {
    
    if (!self.canRedPackageRain) {
        [self.pendantView removeFromSuperview];
        self.pendantView = nil;
        return;
    }
    
    if (self.pendantView) {
        return;
    }
    
    self.pendantView = [[WTVRedPackagePendantView alloc] init];
    
    @jp_weakify(self);
    self.pendantView.tapBlock = ^{
        @jp_strongify(self);
        if (!self) return;
        
        if (self.isPhoneLogin) {
            [self presentRedPackageRainViewController];
        } else {
            NSLog(@"弹登录框");
            [self showLoginPopViewWithPresentedLoginVCBlock:nil];
        }
        
    };
    
    self.pendantView.showComplete = ^{
        @jp_strongify(self);
        if (!self) return;
        [self requestRedPackageRainScreenings];
    };
}

#pragma mark - 登录通知

- (void)goLoginHandle {
    [self.pendantView hideThorough];
    [self removeTimer];
}

- (void)loginSuccessHandle {
    self.verLoginVC = nil;
    self.currentPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNo"];
    
    if (self.activityTimeModel) {
        if (self.pendantView.isShowed) {
            [self.pendantView showOnLeft];
            [self requestRedPackageRainScreenings];
        } else {
            [self.pendantView show];
        }
    } else {
        if (self.superVC) {
            [self requestRedPackageRainActivityTimeWithSuperVC:self.superVC];
        }
    }
}

- (void)noLoginOutHandle {
    self.verLoginVC = nil;
    
    if (self.pendantView.isShowed) {
        [self.pendantView showOnLeft];
        [self redPackageRainVCClose];
    } else {
        [self.pendantView show];
    }
}

- (void)logoutSuccessHandle {
    [self.pendantView hideThorough];
    [self removeTimer];
    
    [self.screeningsModels removeAllObjects];
    [self.finishScreeningsModels removeAllObjects];
    
    self.logoutPhone = self.currentPhone;
    self.currentPhone = nil;
}

#pragma mark - 红包雨控制器

- (void)presentRedPackageRainViewController {
    
//    if (![MyTools portrait]) {
//        [self removeTimer];
//        return;
//    }
    
    void (^presentRprVCBlock)(void) = ^{
        
//        if (self.pendantView) {
//            if (self.pendantView.state != WTVRedPackagePendantHide) {
//                [self.pendantView hide]; // -> tapBlock -> 登录或presentRedPackageRainViewController
//                return;
//            }
//        } else {
//            if (!self.isPhoneLogin) {
//                NSLog(@"弹登录框");
//                [self showLoginPopViewWithPresentedLoginVCBlock:nil];
//                return;
//            }
//        }
        
        @jp_weakify(self);
        WTVRedPackageRainViewController *rprVC = [[WTVRedPackageRainViewController alloc] initWithTimeText:self.pendantView.timeLabel.text dismissHandle:^(WTVRedPackageRainScreeningsModel *finishScreeningsModel) {
            @jp_strongify(self);
            if (!self) return;
            [self.pendantView showOnLeft];
            [self redPackageRainVCClose];
            
            if (finishScreeningsModel) {
                // 上报奖品
                if (self.finishScreeningsModels.count) {
                    [self.finishScreeningsModels addObject:finishScreeningsModel];
                    [self uploadPrize];
                } else {
                    [self.finishScreeningsModels addObject:finishScreeningsModel];
                    CGFloat dealy = (CGFloat)(arc4random() % 6);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dealy * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self uploadPrize];
                    });
                }
            }
        }];
        
        UIViewController *topVC = [UIWindow jp_topViewControllerFromDelegateWindow];
        [topVC presentViewController:rprVC animated:NO completion:^{
            if (self.currentScreeningsModel.state == WTVScreeningsOnGoingState) {
                [rprVC showBackwardsAnimated];
            } else {
                [rprVC showTrailerAnimated];
            }
        }];
        
        self.redPackageRainVC = rprVC;
    };
    
    if (self.isVerScreen) {
        presentRprVCBlock();
    } else {
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RedPackageRainVCPresentNotification" object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
            presentRprVCBlock();
        });
    }
}

- (void)redPackageRainVCClose {
    if (self.screeningsModels.count) {
        if (self.currentScreeningsModel.state == WTVScreeningsOnGoingState ||
            self.currentScreeningsModel.state == WTVScreeningsFinishState) {
            [self.screeningsModels removeObjectAtIndex:0];
        }
    } else {
        self.pendantView.timeLabel.text = @"敬请期待";
    }
    [self setupTimer];
}

#pragma mark - 项目常量

- (BOOL)isVerScreen {
    return YES; // SCREENW < SCREENH;
}

#pragma mark - 公开方法

#pragma mark 检测是否手机登录
- (BOOL)isPhoneLogin {
    if (self.currentPhone.length) {
        NSLog(@"手机登录的");
        return YES;
    } else {
        NSLog(@"其他登录的");
        return NO;
    }
}

#pragma mark 登录弹窗

- (void)showLoginPopViewWithPresentedLoginVCBlock:(void(^)(void))presentedLoginVCBlock {
    if (self.popView) {
        return;
    }
    self.popView = [WTVRedPacketPopView loginPopViewWithSureHandler:^{
        JPLog(@"登录");
//        WTVvertiLoginVC *vc = [[WTVvertiLoginVC alloc] init];
//        vc.canCancel = YES;
//        [[UIView jp_getTopViewController] presentViewController:vc animated:YES completion:^{
//            !presentedLoginVCBlock ? : presentedLoginVCBlock();
//        }];
    } cancelHandle:^{
        [self noLoginOutHandle];
    }];
}

#pragma mark - 私有方法

#pragma mark 上传奖品

- (void)uploadPrize {}
//{
//    if (self.isUploadingPrize) {
//        return;
//    }
//
//    if (self.finishScreeningsModels.count == 0) {
//        self.isUploadingPrize = NO;
//        return;
//    }
//
//    self.isUploadingPrize = YES;
//
//    WTVRedPackageRainScreeningsModel *finishScreeningsModel = self.finishScreeningsModels.firstObject;
//
//    NSMutableArray *drawPresentArray = [NSMutableArray array];
//
//    NSInteger hanTianDogCount = 0;
//    NSInteger tongTianDogCount = 0;
//    NSInteger xuanTianDogCount = 0;
//    NSInteger feiTianDogCount = 0;
//    NSInteger huanTianDogCount = 0;
//    NSInteger xiaoTianDogCount = 0;
//    NSInteger provinceTrafficCount = 0;
//    NSInteger domesticTrafficCount = 0;
//
//    NSMutableDictionary *hanTianDogDic;
//    NSMutableDictionary *tongTianDogDic;
//    NSMutableDictionary *xuanTianDogDic;
//    NSMutableDictionary *feiTianDogDic;
//    NSMutableDictionary *huanTianDogDic;
//    NSMutableDictionary *xiaoTianDogDic;
//    NSMutableDictionary *provinceTrafficDic;
//    NSMutableDictionary *domesticTrafficDic;
//
//    NSInteger giftCount = finishScreeningsModel.gitfModels.count;
//    for (NSInteger i = 0; i < giftCount; i++) {
//        WTVRedPackageRainGiftModel *giftModel = finishScreeningsModel.gitfModels[i];
//        switch (giftModel.giftType) {
//            case WTVHanTianDogType:
//            {
//                hanTianDogCount += giftModel.actualCount;
//                if (!hanTianDogDic && hanTianDogCount > 0) {
//                    hanTianDogDic = [self giftDicWithGiftModel:giftModel];
//                }
//                break;
//            }
//            case WTVTongTianDogType:
//            {
//                tongTianDogCount += giftModel.actualCount;
//                if (!tongTianDogDic && tongTianDogCount > 0) {
//                    tongTianDogDic = [self giftDicWithGiftModel:giftModel];
//                }
//                break;
//            }
//            case WTVXuanTianDogType:
//            {
//                xuanTianDogCount += giftModel.actualCount;
//                if (!xuanTianDogDic && xuanTianDogCount > 0) {
//                    xuanTianDogDic = [self giftDicWithGiftModel:giftModel];
//                }
//                break;
//            }
//            case WTVFeiTianDogType:
//            {
//                feiTianDogCount += giftModel.actualCount;
//                if (!feiTianDogDic && feiTianDogCount > 0) {
//                    feiTianDogDic = [self giftDicWithGiftModel:giftModel];
//                }
//                break;
//            }
//            case WTVHuanTianDogType:
//            {
//                huanTianDogCount += giftModel.actualCount;
//                if (!huanTianDogDic && huanTianDogCount > 0) {
//                    huanTianDogDic = [self giftDicWithGiftModel:giftModel];
//                }
//                break;
//            }
//            case WTVXiaoTianDogType:
//            {
//                xiaoTianDogCount += giftModel.actualCount;
//                if (!xiaoTianDogDic && xiaoTianDogCount > 0) {
//                    xiaoTianDogDic = [self giftDicWithGiftModel:giftModel];
//                }
//                break;
//            }
//            case WTVProvinceTrafficType:
//            {
//                provinceTrafficCount += giftModel.actualCount;
//                if (!provinceTrafficDic && provinceTrafficCount > 0) {
//                    provinceTrafficDic = [self giftDicWithGiftModel:giftModel];
//                }
//                break;
//            }
//            case WTVDomesticTrafficType:
//            {
//                domesticTrafficCount += giftModel.actualCount;
//                if (!domesticTrafficDic && domesticTrafficCount > 0) {
//                    domesticTrafficDic = [self giftDicWithGiftModel:giftModel];
//                }
//                break;
//            }
//        }
//    }
//
//    if (hanTianDogDic) {
//        hanTianDogDic[@"count"] = [NSString stringWithFormat:@"%zd", hanTianDogCount];
//        [drawPresentArray addObject:hanTianDogDic];
//    }
//
//    if (tongTianDogDic) {
//        tongTianDogDic[@"count"] = [NSString stringWithFormat:@"%zd", tongTianDogCount];
//        [drawPresentArray addObject:tongTianDogDic];
//    }
//
//    if (xuanTianDogDic) {
//        xuanTianDogDic[@"count"] = [NSString stringWithFormat:@"%zd", xuanTianDogCount];
//        [drawPresentArray addObject:xuanTianDogDic];
//    }
//
//    if (feiTianDogDic) {
//        feiTianDogDic[@"count"] = [NSString stringWithFormat:@"%zd", feiTianDogCount];
//        [drawPresentArray addObject:feiTianDogDic];
//    }
//
//    if (huanTianDogDic) {
//        huanTianDogDic[@"count"] = [NSString stringWithFormat:@"%zd", huanTianDogCount];
//        [drawPresentArray addObject:huanTianDogDic];
//    }
//
//    if (xiaoTianDogDic) {
//        xiaoTianDogDic[@"count"] = [NSString stringWithFormat:@"%zd", xiaoTianDogCount];
//        [drawPresentArray addObject:xiaoTianDogDic];
//    }
//
//    if (provinceTrafficDic) {
//        provinceTrafficDic[@"count"] = [NSString stringWithFormat:@"%zd", provinceTrafficCount];
//        [drawPresentArray addObject:provinceTrafficDic];
//    }
//
//    if (domesticTrafficDic) {
//        domesticTrafficDic[@"count"] = [NSString stringWithFormat:@"%zd", domesticTrafficCount];
//        [drawPresentArray addObject:domesticTrafficDic];
//    }
//
//    NSString *drawPresentList = [self arrayToJSONString:drawPresentArray];
//
//    NSString *eventId = self.activityTimeModel.eventID;
//
//    NSString *promotionId = finishScreeningsModel.ID;
//
//    NSString *phone = self.currentPhone;
//
//    NSString *desParam = [NSString stringWithFormat:@"drawPresentList=%@;eventId=%@;promotionId=%@;phone=%@", drawPresentList, eventId, promotionId, phone];
//
//    NSString *param = [MyTools desParam:desParam newPort:YES needLogin:NO];
//    NSString *apiUrl = [NSString stringWithFormat:@"%@%@",wtvAPIURLhttps,@"/event/claimPresent"];
//
//    @jp_weakify(self);
//    [[NetWorkRequest shareNetWorkRequest] postNetworkApiUrl:apiUrl desParam:param requestType:WTVbackDataTypeDic callBack:^(NSDictionary *obj, NSString *code) {
//
//        @jp_strongify(self);
//        if (!self) return;
//
//        if ([code isEqualToString:@"200"]) {
//            NSLog(@"上传奖品成功!");
//            [self.finishScreeningsModels removeObjectAtIndex:0];
//        }
//
//        if (self.finishScreeningsModels.count) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                self.isUploadingPrize = NO;
//                [self uploadPrize];
//            });
//        } else {
//            self.isUploadingPrize = NO;
//        }
//
//    }];
//}

- (NSMutableDictionary *)giftDicWithGiftModel:(WTVRedPackageRainGiftModel *)giftModel {
    NSMutableDictionary *giftDic = [NSMutableDictionary dictionary];
    giftDic[@"id"] = giftModel.ID;
    return giftDic;
}

- (NSString *)arrayToJSONString:(NSArray *)array {
    NSError *error = nil;
    if (!array) {
        return @"";
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark 清空所有

- (void)clearAllData {
    [self removeTimer];
    
    self.superVC = nil;
    self.verLoginVC = nil;
    self.logoutPhone = nil;
    self.currentPhone = nil;
    self.activityTimeModel = nil;
    [self.screeningsModels removeAllObjects];
    [self.finishScreeningsModels removeAllObjects];
    
    if (self.pendantView) {
        [self.pendantView removeFromSuperview];
        self.pendantView = nil;
    }
    if (self.redPackageRainVC) {
        [self.redPackageRainVC dismissViewControllerAnimated:NO completion:nil];
        self.redPackageRainVC = nil;
    }
    if (self.popView) {
        [self.popView removeFromSuperview];
        self.popView = nil;
    }
}

#pragma mark 设置定时器

- (void)setupTimer {
    
    [self removeTimer];
    
//    if (![MyTools portrait]) {
//        return;
//    }
    
    if (self.screeningsModels.count == 0 ||
        self.currentScreeningsModel.state == WTVScreeningsOnGoingState) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
    // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
    // 何时开始执行第一个任务
    // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    // 设置回调
    dispatch_source_set_event_handler(self.timer, ^{
//        NSLog(@"------------%@", [NSThread currentThread]);
        
        NSMutableArray *deleteModels = [NSMutableArray array];
        NSTimeInterval currentTimeInt = self.currentTimeInt;
        
        for (WTVRedPackageRainScreeningsModel *model in self.screeningsModels) {
            if (model.endtimeInt <= currentTimeInt) {
                [deleteModels addObject:model];
            }
        }
        
        if (deleteModels.count) {
            for (WTVRedPackageRainScreeningsModel *model in deleteModels) {
                [self.screeningsModels removeObject:model];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkCurrentScreeningsModel];
        });
        
    });
    
    // 启动定时器
    dispatch_resume(self.timer);
}

- (void)removeTimer {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)checkCurrentScreeningsModel {
    
    WTVRedPackageRainScreeningsModel *currentScreeningsModel = self.currentScreeningsModel;
    
    if (!currentScreeningsModel) {
        self.pendantView.timeLabel.text = @"敬请期待";
        return;
    } else {
        self.pendantView.timeLabel.text = [currentScreeningsModel.starttime substringWithRange:NSMakeRange(currentScreeningsModel.starttime.length - 8, 5)];
    }
    
    NSTimeInterval currentTimeInt = self.currentTimeInt;
    
    if (currentScreeningsModel.starttimeInt <= currentTimeInt && currentScreeningsModel.endtimeInt > currentTimeInt) {
        
        currentScreeningsModel.state = WTVScreeningsOnGoingState;
        [self removeTimer];
        
        // 开始红包雨
        if (self.redPackageRainVC) {
            if (self.redPackageRainVC.isRedPackageRainFinish) {
                [self.redPackageRainVC dismissViewControllerAnimated:NO completion:nil];
                self.redPackageRainVC = nil;
                [self presentRedPackageRainViewController];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:RedPackageRainStartNotification object:nil];
            }
        } else {
            // 打开红包雨
            [self presentRedPackageRainViewController];
        }
        
    } else if (currentTimeInt > currentScreeningsModel.trailerTimeInt - 0.5 && currentTimeInt < currentScreeningsModel.trailerTimeInt + 0.5) {
        
        currentScreeningsModel.state = WTVScreeningsReadyBeginState;
        
        // 预告红包雨
        if (self.redPackageRainVC) {
            if (self.redPackageRainVC.isRedPackageRainFinish) {
                [self.redPackageRainVC dismissViewControllerAnimated:NO completion:nil];
                self.redPackageRainVC = nil;
                [self presentRedPackageRainViewController];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:RedPackageRainTrailerNotification object:nil];
            }
        } else {
            // 打开红包雨
            [self presentRedPackageRainViewController];
        }
        
    }
}

#pragma mark 获取红包雨活动时间
- (void)requestRedPackageRainActivityTimeWithSuperVC:(UIViewController *)superVC {}
//{
////    if (![MyTools portrait]) {
////        [self clearAllData];
////        return;
////    }
//
//    self.superVC = superVC;
//
//    if (self.activityTimeModel) {
//        [self setupPendantView];
//        self.pendantView.superVC = superVC;
//        [self.pendantView showOnLeft];
//        return;
//    }
//
//    NSString *text1 = @"EVENT_OPEN_TIME";
//    NSString *text2 = @"EVENT_CLOSE_TIME";
//    NSString *text3 = @"EVENT_ID";
//    NSString *text4 = @"EXCHANGE_CLOSE_TIME";
//    NSString *textNames = [NSString stringWithFormat:@"%@,%@,%@,%@", text1, text2, text3, text4];
//
//    NSString *param = [NSString stringWithFormat:@"textNames=%@",textNames];
//
//    @jp_weakify(self);
//    [MyToolsAboutRequest queryTextParam:param callBack:^(NSDictionary *obj) {
//        @jp_strongify(self);
//        if (!self) return;
//
//        if (obj.count == 0) {
//            [[UIView jp_getTopViewController].view showToastCenterWithTip:@"网络异常"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self requestRedPackageRainActivityTimeWithSuperVC:superVC];
//            });
//            return;
//        }
//
//        self.activityTimeModel = [[WTVRedPackageRainActivityTimeModel alloc] init];
//
//        NSArray *timeArr = obj[@"texts"];
//        for (NSDictionary *timeDic in timeArr) {
//            NSString *name = timeDic[@"name"];
//            NSString *text = timeDic[@"text"];
//            if ([name isEqualToString:@"EVENT_OPEN_TIME"]) {
//                self.activityTimeModel.eventOpenTime = text;
//            } else if ([name isEqualToString:@"EVENT_CLOSE_TIME"]) {
//                self.activityTimeModel.eventCloseTime = text;
//            } else if ([name isEqualToString:@"EVENT_ID"]) {
//                self.activityTimeModel.eventID = text;
//            } else if ([name isEqualToString:@"EXCHANGE_CLOSE_TIME"]) {
//                self.activityTimeModel.exchangeCloseTime = text;
//            }
//        }
//
//        //        NSTimeInterval eventOpenTimeInt  = self.activityTimeModel.eventOpenTimeInt;
//        //        NSTimeInterval eventCloseTimeInt = self.activityTimeModel.eventCloseTimeInt;
//        NSTimeInterval exchangeCloseTimeInt = self.activityTimeModel.exchangeCloseTimeInt;
//        NSTimeInterval currentTimeInt       = self.currentTimeInt;
//
//        //        self.canRedPackageRain = (currentTimeInt >= eventOpenTimeInt) &&
//        //                                 (currentTimeInt < eventCloseTimeInt);
//        self.canRedPackageRain = NO;
//
//        self.canExchangePrize = currentTimeInt < exchangeCloseTimeInt;
//
//        if (self.canRedPackageRain) {
//            [self.pendantView removeFromSuperview];
//            self.pendantView = nil;
//            [self setupPendantView];
//            self.pendantView.superVC = superVC;
//            [self.pendantView show];
//        }
//    }];
//}

- (void)requestRedPackageRainScreenings {}
//{
//    
////    if (![MyTools portrait]) {
////        [self clearAllData];
////        return;
////    }
//    
//    if (!self.canRedPackageRain) {
//        return;
//    }
//    
//    if (self.screeningsModels.count) {
//        return;
//    }
//    
//    NSString *desParam = [NSString stringWithFormat:@"eventId=%@",@"1"];
//    NSString *param    = [MyTools desParam:desParam newPort:YES needLogin:NO];
//    NSString *apiUrl = [NSString stringWithFormat:@"%@%@",wtvAPIURLhttps,@"/event/queryPromotions"];
//    
//    @jp_weakify(self);
//    [[NetWorkRequest shareNetWorkRequest] postNetworkApiUrl:apiUrl desParam:param requestType:WTVbackDataTypeDic callBack:^(NSDictionary *obj, NSString *code) {
//        
//        @jp_strongify(self);
//        if (!self) return;
//        
//        if (obj.count == 0) {
//            [[UIView jp_getTopViewController].view showToastCenterWithTip:@"网络异常"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self requestRedPackageRainScreenings];
//            });
//            return;
//        }
//        
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            
//            NSArray *promotions = obj[@"promotions"];
//            NSArray *screeningsModels = [WTVRedPackageRainScreeningsModel mj_objectArrayWithKeyValuesArray:promotions];
//            
//            NSArray *drawPresentList = obj[@"drawPresentList"];
//            NSMutableArray *giftModels = [WTVRedPackageRainGiftModel mj_objectArrayWithKeyValuesArray:drawPresentList];
//            
//            
//            NSInteger allScreeningsCount = screeningsModels.count;
//            NSMutableArray *screeningsGiftCountArray = [NSMutableArray array];
//            
//            if (giftModels.count) {
//                
//                for (WTVRedPackageRainGiftModel *giftModel in giftModels) {
//                    
//                    NSInteger giftCount = giftModel.count;
//                    NSString *giftTypeStr = [NSString stringWithFormat:@"%zd", giftModel.giftType];
//                    
//                    NSMutableArray *giftCountArray = [NSMutableArray array];
//                    for (NSInteger i = 0; i < allScreeningsCount; i++) {
//                        NSMutableDictionary *giftCountDic = [NSMutableDictionary dictionary];
//                        giftCountDic[giftTypeStr] = @0;
//                        [giftCountArray addObject:giftCountDic];
//                    }
//                    
//                    for (NSInteger i = 0; i < giftCount; i++) {
//                        if (allScreeningsCount>0) {
//                            NSInteger screeningsNum = arc4random() % allScreeningsCount;
//                            
//                            NSMutableDictionary *giftCountDic = giftCountArray[screeningsNum];
//                            NSNumber *giftCountNum = giftCountDic[giftTypeStr];
//                            giftCountNum = @(giftCountNum.integerValue + 1);
//                            giftCountDic[giftTypeStr] = giftCountNum;
//                        }
//                    }
//                    
//                    [screeningsGiftCountArray addObject:giftCountArray];
//                }
//                
//            }
//            
//            NSTimeInterval currentTimeInt = self.currentTimeInt;
//            
//            for (WTVRedPackageRainScreeningsModel *model in screeningsModels) {
//                if (model.starttimeInt > currentTimeInt) {
//                    [self.screeningsModels addObject:model];
//                } else if (model.starttimeInt <= currentTimeInt && model.endtimeInt > currentTimeInt) {
//                    [self.screeningsModels addObject:model];
//                }
//            }
//            
//            NSInteger screeningsCount = self.screeningsModels.count;
//            
//            if (screeningsGiftCountArray.count) {
//                
//                if (screeningsCount < allScreeningsCount) {
//                    for (NSInteger i = 0; i < screeningsGiftCountArray.count; i++) {
//                        NSMutableArray *gCountArray = screeningsGiftCountArray[i];
//                        gCountArray = [[gCountArray subarrayWithRange:NSMakeRange(allScreeningsCount - screeningsCount, screeningsCount)] mutableCopy];
//                        screeningsGiftCountArray[i] = gCountArray;
//                    }
//                }
//                
//                for (NSInteger i = 0; i < screeningsCount; i++) {
//                    WTVRedPackageRainScreeningsModel *screeningsModel = self.screeningsModels[i];
//                    
//                    for (NSMutableArray *giftCountArray in screeningsGiftCountArray) {
//                        NSMutableDictionary *giftCountDic = giftCountArray[i];
//                        [giftCountDic enumerateKeysAndObjectsUsingBlock:^(NSString *giftTypeStr, NSNumber *giftCountNum, BOOL * _Nonnull stop) {
//                            
//                            WTVRedPackageRainGiftType giftType = giftTypeStr.integerValue;
//                            NSInteger giftCount = giftCountNum.integerValue;
//                            
//                            WTVRedPackageRainGiftModel *giftModel = [self findGiftModelWithGiftModels:giftModels giftType:giftType];
//                            
//                            if (giftType == WTVProvinceTrafficType ||
//                                giftType == WTVDomesticTrafficType) {
//                                
//                                NSInteger splitCount = 0;
//                                if (giftCount <= 10) {
//                                    splitCount = 5;
//                                } else if (giftCount > 10 && giftCount <= 100) {
//                                    splitCount = 10;
//                                } else {
//                                    splitCount = giftCount / 5;
//                                }
//                                
//                                [self splitGiftWithGiftCount:giftCount splitCount:splitCount screeningsModel:screeningsModel giftModel:giftModel];
//                                
//                            } else {
//                                
//                                for (NSInteger i = 0; i < giftCount; i++) {
//                                    WTVRedPackageRainGiftModel *copyModel = [WTVRedPackageRainGiftModel copyWithGiftModel:giftModel];
//                                    copyModel.actualCount = 1;
//                                    [screeningsModel.gitfModels addObject:copyModel];
//                                }
//                                
//                            }
//                            
//                        }];
//                    }
//                }
//            }
//            
//            if (self.logoutPhone.length) {
//                if ([self.logoutPhone isEqualToString:self.currentPhone]) {
//                    WTVRedPackageRainScreeningsModel *currentScreeningsModel = self.currentScreeningsModel;
//                    if (currentScreeningsModel) {
//                        NSTimeInterval currentTimeInt = self.currentTimeInt;
//                        if (currentScreeningsModel.starttimeInt <= currentTimeInt && currentScreeningsModel.endtimeInt > currentTimeInt) {
//                            [self.screeningsModels removeObjectAtIndex:0];
//                        }
//                    }
//                }
//                self.logoutPhone = nil;
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (self.verLoginVC == nil) {
//                    [self checkCurrentScreeningsModel];
//                    [self setupTimer];
//                }
//            });
//        });
//        
//        
//    }];
//}

- (void)splitGiftWithGiftCount:(NSInteger)giftCount splitCount:(NSInteger)splitCount screeningsModel:(WTVRedPackageRainScreeningsModel *)screeningsModel giftModel:(WTVRedPackageRainGiftModel *)giftModel {
    
    NSInteger amongCount = 1 + arc4random() % splitCount;
    if (amongCount > giftCount) {
        amongCount = giftCount;
    }
    
    WTVRedPackageRainGiftModel *copyModel = [WTVRedPackageRainGiftModel copyWithGiftModel:giftModel];
    copyModel.actualCount = amongCount;
    [screeningsModel.gitfModels addObject:copyModel];
    
    NSLog(@"amongCount --- %zd", amongCount);
    
    giftCount -= amongCount;
    if (giftCount > 0) {
        [self splitGiftWithGiftCount:giftCount splitCount:splitCount screeningsModel:screeningsModel giftModel:giftModel];
    } else {
        NSLog(@"gitfModels --- %zd", screeningsModel.gitfModels.count);
    }
}

- (WTVRedPackageRainGiftModel *)findGiftModelWithGiftModels:(NSArray<WTVRedPackageRainGiftModel *> *)giftModels giftType:(WTVRedPackageRainGiftType)giftType {
    WTVRedPackageRainGiftModel *model;
    for (WTVRedPackageRainGiftModel *giftModel in giftModels) {
        if (giftModel.giftType == giftType) {
            model = giftModel;
            break;
        }
    }
    return model;
}

@end


@implementation WTVRedPackageRainActivityTimeModel

- (void)setEventOpenTime:(NSString *)eventOpenTime {
    _eventOpenTime = [eventOpenTime copy];
    NSDate *date = [RPManager.dateFormatter dateFromString:eventOpenTime];
    _eventOpenTimeInt = [date timeIntervalSince1970];
}

- (void)setEventCloseTime:(NSString *)eventCloseTime {
    _eventCloseTime = [eventCloseTime copy];
    NSDate *date = [RPManager.dateFormatter dateFromString:eventCloseTime];
    _eventCloseTimeInt = [date timeIntervalSince1970];
}

- (void)setExchangeCloseTime:(NSString *)exchangeCloseTime {
    _exchangeCloseTime = [exchangeCloseTime copy];
    NSDate *date = [RPManager.dateFormatter dateFromString:exchangeCloseTime];
    _exchangeCloseTimeInt = [date timeIntervalSince1970];
}

@end

@implementation WTVRedPackageRainScreeningsModel

- (instancetype)init {
    if (self = [super init]) {
        _state = WTVScreeningsNormalState;
    }
    return self;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID": @"id"};
}
- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.mj_keyValues];
}

- (void)setStarttime:(NSString *)starttime {
    _starttime = [starttime copy];
    NSDate *date = [RPManager.dateFormatter dateFromString:starttime];
    _starttimeInt = [date timeIntervalSince1970];
    _trailerTimeInt = _starttimeInt - 30 * 60;

}

- (void)setEndtime:(NSString *)endtime {
    _endtime = [endtime copy];
    NSDate *date = [RPManager.dateFormatter dateFromString:endtime];
    _endtimeInt = [date timeIntervalSince1970];
}

- (NSMutableArray<WTVRedPackageRainGiftModel *> *)gitfModels {
    if (!_gitfModels) {
        _gitfModels = [NSMutableArray array];
    }
    return _gitfModels;
}

- (void)setState:(WTVRedPackageRainScreeningsState)state {
    _state = state;
}

@end

@implementation WTVRedPackageRainGiftModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID": @"id"};
}

+ (instancetype)copyWithGiftModel:(WTVRedPackageRainGiftModel *)giftModel {
    WTVRedPackageRainGiftModel *model = [[self alloc] init];
    model.count = giftModel.count;
    model.ID = giftModel.ID;
    model.image = giftModel.image;
    model.image2 = giftModel.image2;
    model.name = giftModel.name;
    model.nick = giftModel.nick;
    model.type = giftModel.type;
    model.giftType = giftModel.giftType;
    return model;
}

- (void)setID:(NSString *)ID {
    _ID = [ID copy];
    
    NSInteger IDNum = ID.integerValue;
    
    switch (IDNum) {
            
        case 1:
            self.giftType = WTVProvinceTrafficType;
            break;
            
        case 2:
            self.giftType = WTVHanTianDogType;
            break;
            
        case 3:
            self.giftType = WTVTongTianDogType;
            break;
            
        case 4:
            self.giftType = WTVXuanTianDogType;
            break;
            
        case 5:
            self.giftType = WTVFeiTianDogType;
            break;
            
        case 6:
            self.giftType = WTVHuanTianDogType;
            break;
            
        case 7:
            self.giftType = WTVXiaoTianDogType;
            break;
            
        case 8:
            self.giftType = WTVDomesticTrafficType;
            break;
            
        default:
            break;
    }
}

@end



@implementation WTVRedPackageRainPrizeModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID": @"id"};
}
@end

@implementation WTVRedPackageRainDogModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID": @"id"};
}

- (void)setID:(NSString *)ID {
    _ID = [ID copy];
    
    NSInteger IDNum = ID.integerValue;
    
    switch (IDNum) {
            
        case 1:
            self.giftType = WTVProvinceTrafficType;
            break;
            
        case 2:
            self.giftType = WTVHanTianDogType;
            break;
            
        case 3:
            self.giftType = WTVTongTianDogType;
            break;
            
        case 4:
            self.giftType = WTVXuanTianDogType;
            break;
            
        case 5:
            self.giftType = WTVFeiTianDogType;
            break;
            
        case 6:
            self.giftType = WTVHuanTianDogType;
            break;
            
        case 7:
            self.giftType = WTVXiaoTianDogType;
            break;
            
        case 8:
            self.giftType = WTVDomesticTrafficType;
            break;
            
        default:
            break;
    }
}

+ (NSArray *)noPhoneLoginModels {
    WTVRedPackageRainGiftModel *model1 = [[self alloc] init];
    model1.image = @"me_dog_1";
    
    WTVRedPackageRainGiftModel *model2 = [[self alloc] init];
    model2.image = @"me_dog_2";
    
    WTVRedPackageRainGiftModel *model3 = [[self alloc] init];
    model3.image = @"me_dog_3";
    
    WTVRedPackageRainGiftModel *model4 = [[self alloc] init];
    model4.image = @"me_dog_4";
    
    WTVRedPackageRainGiftModel *model5 = [[self alloc] init];
    model5.image = @"me_dog_5";
    
    WTVRedPackageRainGiftModel *model6 = [[self alloc] init];
    model6.image = @"me_dog_6";
    
    return @[model1, model2, model3, model4, model5, model6];
}
@end
