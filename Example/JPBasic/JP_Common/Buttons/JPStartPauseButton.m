//
//  JPStartPauseButton.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/5/7.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPStartPauseButton.h"

@implementation JPStartPauseButton

+ (instancetype)startPauseButton {
    return [[self alloc] initWithFrame:CGRectMake(0, 0, JPScaleValue(25 + 20), JPScaleValue(25 + 8) + JPScaleFont(10).lineHeight)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = JPRandomColor;
        
    }
    return self;
}

@end
