//
//  WTVRedPackageRewardViewController.m
//  WoTV
//
//  Created by 周健平 on 2018/1/24.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageRewardViewController.h"

#import "WTVRedPackageRainManager.h"

#import "WTVRedPackageTrafficPrizesView.h"
#import "WTVRedPackageDogPrizesView.h"
#import "WTVRedPackageDogView.h"

#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "WTVRedPacketPopView.h"

@interface WTVRedPackageRewardViewController ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) WTVRedPackageTrafficPrizesView *tpView;
@property (nonatomic, weak) WTVRedPackageDogPrizesView *dpView;
@property (nonatomic, weak) WTVRedPackageDogView *dogView;
@property (nonatomic, weak) UIImageView *dogPrizesTitleView;

@property (nonatomic, assign) BOOL isLogin;

// 其他奖品数组
@property (nonatomic, strong) NSMutableArray<WTVRedPackageRainPrizeModel *> *otPrizeModels;
// 流量奖品数组
@property (nonatomic, strong) NSMutableArray<WTVRedPackageRainPrizeModel *> *tPrizeModels;

// 神犬数组
@property (nonatomic, strong) NSMutableArray<WTVRedPackageRainDogModel *> *dogModels;
// 还剩余省内流量
@property (nonatomic, strong) WTVRedPackageRainDogModel *surplusPtPrizeModel;
// 还剩余国内流量
@property (nonatomic, strong) WTVRedPackageRainDogModel *surplusDtPrizeModel;

// 已兑换神犬奖品
@property (nonatomic, strong) WTVRedPackageRainPrizeModel *exchangedDogPrizeModel;
// 已兑换省内流量
@property (nonatomic, strong) WTVRedPackageRainPrizeModel *exchangedPtPrizeModel;
// 已兑换国内流量
@property (nonatomic, strong) WTVRedPackageRainPrizeModel *exchangedDtPrizeModel;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, assign) BOOL requestTListPListSuccess;
@property (nonatomic, assign) BOOL requestTrafficAndDogSuccess;

@property (nonatomic, assign) NSInteger collectPtCount;
@property (nonatomic, assign) NSInteger collectDtCount;
@property (nonatomic, assign) NSInteger exchangedPtCount;
@property (nonatomic, assign) NSInteger exchangedDtCount;
@property (nonatomic, assign) NSInteger surplusPtCount;
@property (nonatomic, assign) NSInteger surplusDtCount;
@property (nonatomic, assign) NSInteger dogTypeCount;

@property (nonatomic, assign) NSInteger ptRemainCount;
@property (nonatomic, assign) NSInteger dtRemainCount;
@property (nonatomic, assign) NSInteger dogRemainCount;

@property (nonatomic, weak) WTVRedPacketPopView *popView;
@property (nonatomic, copy) RedPackageRainShareHandle shareHandle;
@end

@implementation WTVRedPackageRewardViewController
{
    BOOL _isPhoneLogin;
    BOOL _isNotFirstUpdateSubviews;
}

#pragma mark - const

#pragma mark - setter

- (void)setRequestTListPListSuccess:(BOOL)requestTListPListSuccess {
    if (_requestTListPListSuccess == requestTListPListSuccess) {
        return;
    }
    _requestTListPListSuccess = requestTListPListSuccess;
    [self updateSubviews];
}

- (void)setRequestTrafficAndDogSuccess:(BOOL)requestTrafficAndDogSuccess {
    if (_requestTrafficAndDogSuccess == requestTrafficAndDogSuccess) {
        return;
    }
    _requestTrafficAndDogSuccess = requestTrafficAndDogSuccess;
    [self updateSubviews];
}

#pragma mark - getter

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

// 其他奖品数组
- (NSMutableArray<WTVRedPackageRainPrizeModel *> *)otPrizeModels {
    if (!_otPrizeModels) {
        _otPrizeModels = [NSMutableArray array];
    }
    return _otPrizeModels;
}

// 流量奖品数组
- (NSMutableArray<WTVRedPackageRainPrizeModel *> *)tPrizeModels {
    if (!_tPrizeModels) {
        _tPrizeModels = [NSMutableArray array];
    }
    return _tPrizeModels;
}

// 共获得神犬数组
- (NSMutableArray<WTVRedPackageRainDogModel *> *)dogModels {
    if (!_dogModels) {
        _dogModels = [NSMutableArray array];
    }
    return _dogModels;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupScrollView];
    [self setupTrafficPrizesView];
    [self setupDogPrizesView];
    [self setupNavigationBar];
    [self setupFinal];
    
    if (RPManager.isPhoneLogin) {
        [self showHUDWithEnabled:NO];
        [self requestTrafficListAndPrizeListData];
        [self requestTrafficAndDogData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
#pragma clang diagnostic pop
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [self hideHUD];
    NSLog(@"我的奖品死了");
}

#pragma mark - setup subviews

- (void)setupBase {
    self.title = @"我的奖品";
    
    CAGradientLayer *gLayer = [CAGradientLayer layer];
    gLayer.startPoint = CGPointMake(0.5, 0);
    gLayer.endPoint = CGPointMake(0.5, 1);
    gLayer.frame = [UIScreen mainScreen].bounds;
    gLayer.locations = @[@0, @1];
    gLayer.colors = @[(id)JPRGBColor(254, 133, 125).CGColor,
                      (id)JPRGBColor(254, 67, 93).CGColor];
    [self.view.layer addSublayer:gLayer];
    
    _isPhoneLogin = RPManager.isPhoneLogin;
}

- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
   
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
//    scrollView.mj_header = [MyTools initGifHeaderWithSel:@selector(refreshHandle) target:self];
//    scrollView.mj_header.ignoredScrollViewContentInsetTop = -kNavigationBarHeight;
}

- (void)setupTrafficPrizesView {
    WTVRedPackageTrafficPrizesView *tpView = [WTVRedPackageTrafficPrizesView trafficPrizesView];
    CGFloat x = 5;
    CGFloat y = JPNavTopMargin + 10;
    tpView.jp_origin = CGPointMake(x, y);
    [self.scrollView addSubview:tpView];
    self.tpView = tpView;
    
    @jp_weakify(self);
    tpView.btnDidClick = ^(WTVRedPackageRainPrizeModel *selectedModel) {
        @jp_strongify(self);
        if (!self) return;
        
        if (!RPManager.isPhoneLogin) {
            [RPManager showLoginPopViewWithPresentedLoginVCBlock:^{
                [self.navigationController popViewControllerAnimated:NO];
            }];
            return;
        }
        
        if (self.ptRemainCount == 0 && selectedModel.type == WTVProvinceTrafficPrizeType) {
            [JPProgressHUD showInfoWithStatus:@"您的省内流量兑换次数已达上限" userInteractionEnabled:YES];
            return;
        }
        
        if (self.dtRemainCount == 0 && selectedModel.type == WTVDomesticTrafficPrizeType) {
            [JPProgressHUD showInfoWithStatus:@"您的全国流量兑换次数已达上限" userInteractionEnabled:YES];
            return;
        }
        
        if (!selectedModel) {
            [JPProgressHUD showInfoWithStatus:@"请选择兑换流量" userInteractionEnabled:YES];
            return;
        }
        
        [self showConversionPopViewWithModel:selectedModel isDogPrizes:NO];
    };
    
    tpView.lookRuleBlock = ^{
        @jp_strongify(self);
        if (!self) return;
        [self goLookRule];
    };
}

- (void)setupDogPrizesView {
    
    CGFloat scale = JPScale;
    CGFloat w = 153.0 * scale;
    CGFloat h = 36.0 * scale;
    CGFloat x = (self.scrollView.jp_width - w) * 0.5;
    CGFloat y = self.tpView.jp_maxY + 26 * scale;;
    UIImageView *dogPrizesTitleView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    dogPrizesTitleView.image = [UIImage imageNamed:@"me_webcopy_dog_prize"];
    [self.scrollView addSubview:dogPrizesTitleView];
    self.dogPrizesTitleView = dogPrizesTitleView;
    
    x = 10;
    if (_isPhoneLogin) {
        WTVRedPackageDogPrizesView *dpView = [WTVRedPackageDogPrizesView dogPrizesView];
        y = dogPrizesTitleView.jp_maxY + 5;
        dpView.jp_origin = CGPointMake(x, y);
        [self.scrollView addSubview:dpView];
        self.dpView = dpView;
        
        @jp_weakify(self);
        dpView.btnDidClick = ^(WTVRedPackageRainPrizeModel *selectedModel) {
            
            @jp_strongify(self);
            if (!self) return;
            
            if (self.dogRemainCount == 0) {
                [JPProgressHUD showInfoWithStatus:@"您的萌犬奖品兑换次数已达上限" userInteractionEnabled:YES];
                return;
            }
            
            if (!selectedModel) {
                [JPProgressHUD showInfoWithStatus:@"请选择兑换奖品" userInteractionEnabled:YES];
                return;
            }
            
            [self showConversionPopViewWithModel:selectedModel isDogPrizes:YES];
            
        };
        
        dpView.lookRuleBlock = ^{
            @jp_strongify(self);
            if (!self) return;
            [self goLookRule];
        };
        
        y = dpView.jp_maxY + 25 * scale;
    } else {
        y = dogPrizesTitleView.jp_maxY + 25 * scale;
    }
    
    WTVRedPackageDogView *dogView = [WTVRedPackageDogView dogView];
    dogView.jp_origin = CGPointMake(x, y);
    [self.scrollView addSubview:dogView];
    self.dogView = dogView;
    
    @jp_weakify(self);
    dogView.giveBtnDidClick = ^(WTVRedPackageRainDogModel *selectedModel) {
        @jp_strongify(self);
        if (!self) return;
        if (selectedModel.count > 0) {
            [self showSharePopViewWithModel:selectedModel isGive:YES];
        } else {
            [JPProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"您还没拥有%@", [selectedModel.name componentsSeparatedByString:@"（"].firstObject] userInteractionEnabled:YES];
        }
    };
    
    dogView.getBtnDidClick = ^(WTVRedPackageRainDogModel *selectedModel) {
        @jp_strongify(self);
        if (!self) return;
        [self showSharePopViewWithModel:selectedModel isGive:NO];
    };
}

- (void)setupNavigationBar {
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:KBlackColor,NSForegroundColorAttributeName,nil];
//    [WTVNavigationBar setDefaultTitleAttributes:attributes];
//    WTVNavigationBar *navigationBar = [[WTVNavigationBar alloc]init];
//    navigationBar.backgroundColor = [UIColor whiteColor];
//    navigationBar.backImage = [UIImage imageNamed:@"ver_icon_back"];
//    [navigationBar.backButton addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
//    navigationBar.titleLabel.text = @"我的奖品";
//    [self.view addSubview:navigationBar];
//    [navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(0);
//        make.height.equalTo(kNavigationBarHeight);
//    }];
}

- (void)setupFinal {
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(JPNavTopMargin, 0, 0, 0);
    self.scrollView.contentSize = CGSizeMake(0, self.dogView.jp_maxY + 35 * JPScale + JPDiffTabBarH);
}

- (void)popVC {
    if (self.navigationController.childViewControllers.count) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 网络请求

- (void)requestTrafficListAndPrizeListData {
//    NSString *desParam = [NSString stringWithFormat:@"eventId=%@", RPManager.activityTimeModel.eventID];
//
//    NSString *param    = [MyTools desParam:desParam newPort:YES needLogin:NO];
//    NSString *apiUrl = [NSString stringWithFormat:@"%@%@",wtvAPIURLhttps,@"/event/queryPrizes"];
//
//    @jp_weakify(self);
//    [[NetWorkRequest shareNetWorkRequest] postNetworkApiUrl:apiUrl desParam:param requestType:WTVbackDataTypeDic callBack:^(NSDictionary *obj, NSString *code) {
//
//        // type1 手机
//        // type2 省内流量
//        // type3 国内流量
//        @jp_strongify(self);
//        if (!self) return;
//
//        if (![code isEqualToString:@"200"]) {
//            [JPProgressHUD showErrorWithStatus:@"网络异常" userInteractionEnabled:YES];
//            @jp_weakify(self);
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                @jp_strongify(self);
//                if (!self) return;
//                [self requestTrafficListAndPrizeListData];
//            });
//            return;
//        }
//
//        NSArray *prizes = obj[@"prizes"];
//        NSArray *prizeModels = [WTVRedPackageRainPrizeModel mj_objectArrayWithKeyValuesArray:prizes];
//
//        for (WTVRedPackageRainPrizeModel *prizeModel in prizeModels) {
//            switch (prizeModel.type) {
//                case WTVDogPrizeType:
//                    [self.otPrizeModels addObject:prizeModel];
//                    break;
//
//                case WTVProvinceTrafficPrizeType:
//                case WTVDomesticTrafficPrizeType:
//                    [self.tPrizeModels addObject:prizeModel];
//                    break;
//
//                default:
//                    break;
//            }
//        }
//
//        if (_isNotFirstUpdateSubviews) {
//            self.requestTListPListSuccess = YES;
//            return;
//        }
//
//        @jp_weakify(self);
//        __block BOOL tpViewDone = NO;
//        __block BOOL dpViewDone = NO;
//        void (^allDone)(void) = ^{
//            @jp_strongify(self);
//            if (!self) return;
//            if (tpViewDone && dpViewDone) {
//                self.requestTListPListSuccess = YES;
//            }
//        };
//
//        [self.tpView.trafficView setupModels:self.tPrizeModels animateBlock:^(CGFloat diffH, void (^viewChangBlock)(void)) {
//            @jp_strongify(self);
//            if (!self) return;
//
//            __weak typeof(UIView *) weakView1 = self.dpView;
//            __weak typeof(UIView *) weakView2 = self.dogView;
//            __weak typeof(UIView *) weakView3 = self.dogPrizesTitleView;
//
//            [self subviewHeightDidChangeAnimateWithDiffH:diffH changeYviews:@[weakView1, weakView2, weakView3] animateBlock:viewChangBlock completion:^{
//                tpViewDone = YES;
//                allDone();
//            }];
//        }];
//
//        [self.dpView setupModels:self.otPrizeModels animateBlock:^(CGFloat diffH, void (^viewChangBlock)(void)) {
//            @jp_strongify(self);
//            if (!self) return;
//
//            if (!viewChangBlock) {
//                dpViewDone = YES;
//                allDone();
//                return;
//            }
//
//            __weak typeof(UIView *) weakView1 = self.dogView;
//            __weak typeof(UIView *) weakView2 = self.dogPrizesTitleView;
//
//            [self subviewHeightDidChangeAnimateWithDiffH:diffH changeYviews:@[weakView1, weakView2] animateBlock:viewChangBlock completion:^{
//                dpViewDone = YES;
//                allDone();
//            }];
//        }];
//
//    }];
}

- (void)requestTrafficAndDogData {
//    NSString *desParam = @"";
//
//    NSString *param    = [MyTools desParam:desParam newPort:YES needLogin:NO];
//    NSString *apiUrl = [NSString stringWithFormat:@"%@%@",wtvAPIURLhttps,@"/event/queryPresents"];
//
//    @jp_weakify(self);
//    [[NetWorkRequest shareNetWorkRequest] postNetworkApiUrl:apiUrl desParam:param requestType:WTVbackDataTypeDic callBack:^(NSDictionary *obj, NSString *code) {
//        @jp_strongify(self);
//        if (!self) return;
//
//        if (![code isEqualToString:@"200"]) {
//            [JPProgressHUD showErrorWithStatus:@"网络异常" userInteractionEnabled:YES]
//            @jp_weakify(self);
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                @jp_strongify(self);
//                if (!self) return;
//                [self requestTrafficAndDogData];
//            });
//            return;
//        }
//
//        NSArray *userPresentList = obj[@"userPresentList"];
//        NSArray *models = [WTVRedPackageRainDogModel mj_objectArrayWithKeyValuesArray:userPresentList];
//
//        for (WTVRedPackageRainDogModel *model in models) {
//            switch (model.giftType) {
//                case WTVHanTianDogType:
//                case WTVTongTianDogType:
//                case WTVXuanTianDogType:
//                case WTVFeiTianDogType:
//                case WTVHuanTianDogType:
//                case WTVXiaoTianDogType:
//                {
//                    [self.dogModels addObject:model];
//                    break;
//                }
//                case WTVProvinceTrafficType:
//                {
//                    self.surplusPtPrizeModel = model;
//                    break;
//                }
//                case WTVDomesticTrafficType:
//                {
//                    self.surplusDtPrizeModel = model;
//                    break;
//                }
//                default:
//                    break;
//            }
//        }
//
//        NSArray *userPrizeList = obj[@"userPrizeList"];
//        NSArray *pModels = [WTVRedPackageRainPrizeModel mj_objectArrayWithKeyValuesArray:userPrizeList];
//
//        for (WTVRedPackageRainPrizeModel *pModel in pModels) {
//            switch (pModel.type) {
//                case WTVDogPrizeType:
//                {
//                    self.exchangedDogPrizeModel = pModel;
//                    break;
//                }
//                case WTVProvinceTrafficPrizeType:
//                {
//                    self.exchangedPtPrizeModel = pModel;
//                    break;
//                }
//                case WTVDomesticTrafficPrizeType:
//                {
//                    self.exchangedDtPrizeModel = pModel;
//                    break;
//                }
//                default:
//                    break;
//            }
//        }
//
//        NSArray *remainExchangeCountArray = obj[@"remainExchangeCount"];
//        for (NSDictionary *remainExchangeCountDic in remainExchangeCountArray) {
//            WTVRedPackageRainPrizeType type = [remainExchangeCountDic[@"type"] integerValue];
//            NSInteger remainCount = [remainExchangeCountDic[@"remain"] integerValue];
//            switch (type) {
//                case WTVDogPrizeType:
//                    self.dogRemainCount = remainCount;
//                    break;
//                case WTVProvinceTrafficPrizeType:
//                    self.ptRemainCount = remainCount;
//                    break;
//                case WTVDomesticTrafficPrizeType:
//                    self.dtRemainCount = remainCount;
//                    break;
//                default:
//                    break;
//            }
//        }
//
//        if (_isNotFirstUpdateSubviews) {
//            self.requestTrafficAndDogSuccess = YES;
//            return;
//        }
//
//        self.dogTypeCount = [self.dogView setupModels:self.dogModels animateBlock:^(CGFloat diffH, void (^viewChangBlock)(void)) {
//            @jp_strongify(self);
//            if (!self) return;
//            if (!viewChangBlock) {
//                self.requestTrafficAndDogSuccess = YES;
//                return;
//            }
//            [self subviewHeightDidChangeAnimateWithDiffH:diffH changeYviews:nil animateBlock:viewChangBlock completion:^{
//                self.requestTrafficAndDogSuccess = YES;
//            }];
//        }];
//
//    }];
}

- (void)convertPrizeWithID:(NSString *)ID complete:(void(^)(BOOL isSuccess))complete {
    
//    [self showHUDWithEnabled:NO];
//
//    NSString *phone = RPManager.currentPhone;
//
//    NSString *desParam = [NSString stringWithFormat:@"prizeId=%@;phone=%@", ID, phone];
//
//    NSString *param = [MyTools desParam:desParam newPort:YES needLogin:NO];
//    NSString *apiUrl = [NSString stringWithFormat:@"%@%@",wtvAPIURLhttps,@"/event/exchangePrize"];
//
//    @jp_weakify(self);
//    [[NetWorkRequest shareNetWorkRequest] postNetworkApiUrl:apiUrl desParam:param requestType:WTVbackDataTypeDic callBack:^(NSDictionary *obj, NSString *code) {
//        @jp_strongify(self);
//        if (!self) return;
//
//        NSLog(@"%@", obj);
//        NSLog(@"%@", code);
//
//        if (![code isEqualToString:@"200"]) {
//            [JPProgressHUD showErrorWithStatus:@"网络异常" userInteractionEnabled:YES];
//            [self hideHUD];
//            !complete ? : complete(NO);
//            return;
//        }
//
//        !complete ? : complete(YES);
//
//        self.requestTListPListSuccess = NO;
//        self.requestTrafficAndDogSuccess = NO;
//
//        [self requestTrafficListAndPrizeListData];
//        [self requestTrafficAndDogData];
//
//    }];
}

#pragma mark - 页面更新

- (void)updateSubviews {
    if (!self.requestTrafficAndDogSuccess || !self.requestTListPListSuccess) {
        return;
    }
    
    NSLog(@"都请求完了");
    [self.scrollView.mj_header endRefreshing];
    [self hideHUD];
    
    // 还剩余数
    self.surplusPtCount = self.surplusPtPrizeModel.count;
    self.surplusDtCount = self.surplusDtPrizeModel.count;
    
    // 已兑换数
    self.exchangedPtCount = self.exchangedPtPrizeModel.presentNeed;
    self.exchangedDtCount = self.exchangedDtPrizeModel.presentNeed;
    
    // 共获得数
    self.collectPtCount = self.surplusPtCount + self.exchangedPtCount;
    self.collectDtCount = self.surplusDtCount + self.exchangedDtCount;
    
    self.tpView.getCell.countryTrafficLabel.text = [NSString stringWithFormat:@"%zdM", self.collectDtCount];
    self.tpView.getCell.provinceTrafficLabel.text = [NSString stringWithFormat:@"%zdM", self.collectPtCount];
    
    self.tpView.exchangedCell.countryTrafficLabel.text = [NSString stringWithFormat:@"%zdM", self.exchangedDtCount];
    self.tpView.exchangedCell.provinceTrafficLabel.text = [NSString stringWithFormat:@"%zdM", self.exchangedPtCount];
    
    self.tpView.surplusCell.countryTrafficLabel.text = [NSString stringWithFormat:@"%zdM", self.surplusDtCount];
    self.tpView.surplusCell.provinceTrafficLabel.text = [NSString stringWithFormat:@"%zdM", self.surplusPtCount];
    
    if (_isNotFirstUpdateSubviews) {
        [self.tpView.trafficView updateModels:self.tPrizeModels];
        [self.dpView updateModels:self.otPrizeModels];
        self.dogTypeCount = [self.dogView updateModels:self.dogModels];
    }
    
    [self.tpView.trafficView updateSurplusPtCount:self.surplusPtCount surplusDtCount:self.surplusDtCount];
    [self.dpView updateConforming:self.dogTypeCount];
    
    self.dpView.exchangedDogPrizeModel = self.exchangedDogPrizeModel;
    
    _isNotFirstUpdateSubviews = YES;
}

#pragma mark - 子视图高度修改

- (void)subviewHeightDidChangeAnimateWithDiffH:(CGFloat)diffH changeYviews:(NSArray *)changeYviews animateBlock:(void(^)(void))animateBlock completion:(void(^)(void))completion {
    if (!animateBlock) {
        !completion ? : completion();
        return;
    }
    @jp_weakify(self);
    [self.queue addOperationWithBlock:^{
        @jp_strongify(self);
        if (!self) return;
        self.queue.suspended = YES;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CGFloat contentH = self.scrollView.contentSize.height + diffH;
            // 0.35
            [UIView animateWithDuration:0.35 animations:^{
                !animateBlock ? : animateBlock();
                if (changeYviews) {
                    for (UIView *view in changeYviews) {
                        view.jp_y += diffH;
                    }
                }
                self.scrollView.contentSize = CGSizeMake(0, contentH);
            } completion:^(BOOL finished) {
                self.queue.suspended = NO;
                !completion ? : completion();
            }];
        }];
    }];
    
}

#pragma mark - private method

- (void)refreshHandle {
    self.requestTListPListSuccess = NO;
    self.requestTrafficAndDogSuccess = NO;
    [self requestTrafficListAndPrizeListData];
    [self requestTrafficAndDogData];
    
    self.tpView.userInteractionEnabled = NO;
    self.dpView.userInteractionEnabled = NO;
    self.dogView.userInteractionEnabled = NO;
}

- (void)goLookRule {
    
//    WTVActivityCenterVC *vc = [[WTVActivityCenterVC alloc] init];
//    vc.url = RuleURLStr;
//    vc.naviTitle = @"活动规则";
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showConversionPopViewWithModel:(WTVRedPackageRainPrizeModel *)model isDogPrizes:(BOOL)isDogPrizes {
    
    NSString *promptString = isDogPrizes ? @"您只能参与一次神犬奖品的兑换哦！" : @"";
    
    @jp_weakify(self);
    self.popView = [WTVRedPacketPopView conversionPopViewWithConversionString:model.name promptString:promptString sureHandler:^{
        
        @jp_strongify(self);
        if (!self) return;
        
        [self.popView setIsRequesting:YES];
        
        [self convertPrizeWithID:model.ID complete:^(BOOL isSuccess) {
            
            [self.popView setIsRequesting:NO];
            
            if (isSuccess) {
                NSLog(@"兑换成功");
                [self.popView conversionSuccess];
            } else {
                NSLog(@"兑换失败");
                [self.popView conversionFail];
            }
            
        }];
        
    } cancelHandle:^{
        
    }];
}

- (void)showSharePopViewWithModel:(WTVRedPackageRainDogModel *)model isGive:(BOOL)isGive {
    if (!model) {
        [JPProgressHUD showInfoWithStatus:@"请选择神犬" userInteractionEnabled:YES];
        return;
    }
    
    NSString *title = isGive ? @"分享好友送狗" : @"向好友讨神犬";
    
    @jp_weakify(self);
    
    self.popView = [WTVRedPacketPopView sharePopViewWithTitle:title dataRequestHandle:^(NSInteger shareType, RedPackageRainShareHandle shareHandle) {
        
        @jp_strongify(self);
        if (!self) return;
        
        self.shareHandle = shareHandle;
        
        [self showHUDWithEnabled:NO];
        
//        NSInteger method = isGive? 2 : 3;
        
//        [NetWorkRequest shareMessageWithTVCid:nil videoType:nil method:method callback:^(WTVShareModel *shareModel) {
//            [self hideHUD];
//
//            if (!shareModel) {
//                [self.popView closeAction];
//                [JPProgressHUD showErrorWithStatus:@"分享失败" userInteractionEnabled:YES];
//                return;
//            }
//
//            NSString *param1 = [NSString stringWithFormat:@"%d", isGive ? 2 : 1];
//            NSString *param2 = [UserModel getoutAccount].uid;
//            NSString *param3 = RPManager.currentPhone;
//            NSString *param4 = model.ID;
//            NSString *param = [TripleDES encryptUseDES:[NSString stringWithFormat:@"%@;%@;%@;%@", param1, param2, param3, param4] key:DESKEY];
//
//            shareModel.urlStr = ShareDogURLAppend(param);
//            shareModel.shareType = shareType;
//
//            !self.shareHandle ? : self.shareHandle(shareModel);
//        }];
        
    } responseHandler:^(BOOL shareSuccess) {
        @jp_strongify(self);
        if (!self) return;
        
        if (shareSuccess) {
            [self.popView shareSuccess:isGive];
        }else{
            [self.popView closeAction];
            [JPProgressHUD showErrorWithStatus:@"分享失败" userInteractionEnabled:YES];
        }
    }];
    
}

- (NSInteger)dogCountWithGiftType:(WTVRedPackageRainGiftType)giftType {
    if (self.dogModels.count == 0) {
        return 0;
    }
    for (WTVRedPackageRainDogModel *model in self.dogModels) {
        if (model.giftType == giftType) {
            return model.count;
        }
    }
    return 0;
}

- (void)showHUDWithEnabled:(BOOL)enabled {
    [JPProgressHUD showWithStatus:nil userInteractionEnabled:enabled];
    self.tpView.userInteractionEnabled = NO;
    self.dpView.userInteractionEnabled = NO;
    self.dogView.userInteractionEnabled = NO;
}

- (void)hideHUD {
    [JPProgressHUD dismiss];
    self.tpView.userInteractionEnabled = YES;
    self.dpView.userInteractionEnabled = YES;
    self.dogView.userInteractionEnabled = YES;
}

#pragma mark - public method

@end
