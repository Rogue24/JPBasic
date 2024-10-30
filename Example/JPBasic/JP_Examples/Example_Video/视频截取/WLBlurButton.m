//
//  WLBlurButton.m
//  WoLive
//
//  Created by 周健平 on 2019/9/9.
//  Copyright © 2019 zhoujianping. All rights reserved.
//

#import "WLBlurButton.h"

@implementation WLBlurButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
        [self insertSubview:blurView atIndex:0];
        _blurView = blurView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.blurView) {
        [self insertSubview:self.blurView atIndex:0];
        self.blurView.frame = self.bounds;
    }
}

@end
