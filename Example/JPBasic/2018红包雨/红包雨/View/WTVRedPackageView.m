//
//  WTVRedPackageView.m
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageView.h"
#import "UIView+JPExtension.h"

@implementation WTVRedPackageView

- (instancetype)initWithModel:(WTVRedPackageModel *)model {
    if (self = [super init]) {
        self.model = model;
        self.jp_size = CGSizeMake(100, 100);
        self.image = [UIImage imageNamed:@"red_packets_icon_redpacket"];
    }
    return self;
}

- (void)bombAnimated {
    CGRect frame = self.layer.presentationLayer.frame;
    [self.layer removeAllAnimations];
    self.frame = frame;
    
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        self.image = [UIImage imageNamed:@"red_packets_icon_bomb"];
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }];
    }];
}

@end
