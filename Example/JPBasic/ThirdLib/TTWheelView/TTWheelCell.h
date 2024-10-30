//
//  TTWheelCell.h
//  wheelView
//
//  Created by simp on 2018/2/28.
//  Copyright © 2018年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,TTWheelCellDirection) {
    TTWheelCellDirectionCenter,
    TTWheelCellDirectionVerticle,
};

@class TTWheelCell;
@protocol TTWheelInnerProtocol <NSObject>

- (void)wheelCellDisAppeared:(TTWheelCell *)cell;

- (void)wheelCellVisibleChanged:(TTWheelCell *)cell;

- (BOOL)wheelCellVisible:(TTWheelCell *)cell;

/**获取父亲的当前角度*/
- (CGFloat)currentAngel;

- (BOOL)isStoppingRotate;

- (void)cellClicked:(TTWheelCell *)cell;

@end

@interface TTWheelCell : UIView

@property (nonatomic, weak) id <TTWheelInnerProtocol> inderDelegate;

@property (nonatomic, copy, readonly) NSString * identifre;

@property (nonatomic, assign, readonly) BOOL visible;

/**当前所处的角度*/
@property (nonatomic, assign) CGFloat currentAngel;

/**当前所处的半径*/
@property (nonatomic, assign) CGFloat radiu;

/**当前的data对应的位置*/
@property (nonatomic, assign) NSInteger dataIndex;

/**当前的cell 属于第几个圆弧分区*/
@property (nonatomic, assign) NSInteger partIndex;

@property (nonatomic, assign) TTWheelCellDirection direction;

- (instancetype)init __unavailable;

- (instancetype)initWithReuserIdentifire:(NSString *)identiFire;


- (void)resetAngel;

@end
