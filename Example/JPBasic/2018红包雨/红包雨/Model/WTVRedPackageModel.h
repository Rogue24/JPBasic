//
//  WTVRedPackageModel.h
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTVRedPackageRainManager.h"

@interface WTVRedPackageModel : NSObject

@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, assign) NSTimeInterval liveTime;

@property (nonatomic, strong) WTVRedPackageRainGiftModel *giftModel;

@end
