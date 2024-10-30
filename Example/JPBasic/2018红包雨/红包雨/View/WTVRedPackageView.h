//
//  WTVRedPackageView.h
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTVRedPackageModel.h"

@interface WTVRedPackageView : UIImageView

- (instancetype)initWithModel:(WTVRedPackageModel *)model;

- (void)bombAnimated;

@property (nonatomic, strong) WTVRedPackageModel *model;

@end
