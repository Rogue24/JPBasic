//
//  TTWheelCell.m
//  wheelView
//
//  Created by simp on 2018/2/28.
//  Copyright © 2018年 yiyou. All rights reserved.
//

#import "TTWheelCell.h"
#import "TTWheelView.h"
#import <Masonry/Masonry.h>

@interface TTWheelCell ()

@property (nonatomic, copy) NSString * identifre;

@property (nonatomic, strong) UIControl * contentView;

@end

@implementation TTWheelCell

- (instancetype)initWithReuserIdentifire:(NSString *)identiFire {
    if (self = [super init]) {
        self.identifre = identiFire;
        _direction = TTWheelCellDirectionVerticle;
        [self initialWheelCellUI];
    }
    return self;
}

- (void)initialWheelCellUI {
//    [self addTarget:self action:@selector(selfSelected) forControlEvents:UIControlEventTouchUpInside];
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfSelected)];
//    tap.delaysTouchesBegan = YES;
//    [self addGestureRecognizer:tap];
    
    self.contentView = [[UIControl alloc] init];
    [self addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self.contentView addTarget:self action:@selector(selfSelected) forControlEvents:UIControlEventTouchUpInside];
}

- (void)selfSelected {
    [self.inderDelegate cellClicked:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)visible {
    return [self.inderDelegate wheelCellVisible:self];
}

- (void)setCurrentAngel:(CGFloat)currentAngel {
    
    _currentAngel = currentAngel;
    [self resetAngel];
}

- (void)resetAngel {
    if (_direction == TTWheelCellDirectionCenter) {
        self.transform = CGAffineTransformMakeRotation(_currentAngel);
    }else if (_direction == TTWheelCellDirectionVerticle) {
        CGFloat sAnger = [self.inderDelegate currentAngel];
        self.transform = CGAffineTransformMakeRotation(-sAnger);
    }
    if (self.hidden ) {
        if (![self.inderDelegate isStoppingRotate]) {
            self.hidden = NO;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.inderDelegate scrollToDataIndex:self.dataIndex];
//    [self.inderDelegate scrollToCell:self];
}

@end
