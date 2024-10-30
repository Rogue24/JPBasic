//
//  TTWheelView.h
//  wheelView
//
//  Created by simp on 2018/2/28.
//  Copyright © 2018年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTWheelCell.h"
@class TTWheelView;

@protocol TTWheelViewDelegate <NSObject>

- (void)wheel:(TTWheelView *)wheel cellClicked:(TTWheelCell *)cell;

/**轮盘停止转动*/
- (void)wheelDidStopScroll:(TTWheelView *)wheel;

/**轮盘滚动了*/
- (void)wheelDidScroll:(TTWheelView *)wheel;

- (void)wheelDidLayouted:(TTWheelView *)wheel;

@end

@protocol TTWheelDataSource <NSObject>


/**
 当前cell的大小

 @param index cell的Index
 @return TTWheelCell
 */
- (CGSize)wheel:(TTWheelView *)wheel sizeForItemAtIndex:(NSInteger)index;


/**
 当前cell所处的半径

 @param index index
 @return haf
 */
- (CGFloat)wheel:(TTWheelView *)wheel radiuForIndex:(NSInteger)index;

/** each cell at index*/
@required

- (TTWheelCell *)cellAtIndex:(NSInteger)index forWheel:(TTWheelView *)wheel;

- (NSUInteger)dataCountForWheel:(TTWheelView *)wheel;




@end

@interface TTWheelView : UIView

- (instancetype)init __unavailable;

@property (nonatomic, weak) id<TTWheelDataSource> dataSource;

@property (nonatomic, weak) id<TTWheelViewDelegate> delegate;

/**当前旋转的角度*/
@property (nonatomic, assign, readonly) CGFloat currentAngel;

/**翻页的弧度 0 表示不翻页*/
@property (nonatomic, assign) CGFloat pageArc;

/**是否停止在某个cell上*/
@property (nonatomic, assign) BOOL stopInCell;

/**轮盘半径*/
@property (nonatomic, assign, readonly) CGFloat radiu;

/**是否裁剪成一个圆*/
@property (nonatomic, assign) BOOL maskOutCircle;

/**
 初始化方法
 
 @param radiu 半径
 @param divitionCount 轮盘被分为几个部分
 @return 轮盘
 */
- (instancetype)initWithradiu:(CGFloat)radiu divitionCount:(NSUInteger)divitionCount;

/**根据宽度 和最大高度线来生成轮子*/
+ (instancetype)wheelWithCrossWidth:(CGFloat)width widthCrossHeight:(CGFloat)height withPartNumber:(NSInteger)number;

- (TTWheelCell *)dequeenCellForIdentifire:(NSString *)identifire;

/**计算子视图的中心点位置*/
- (CGPoint)pointForAngel:(CGFloat)angel andSubRadiu:(CGFloat)radiu;

- (void)scrollToDataIndex:(NSInteger)dataIndex;

- (void)scrollToCell:(TTWheelCell *)cell;

- (void)maskWithInnderRadiu:(CGFloat)inner;

/**当前处于中心位置的cell*/
- (TTWheelCell *)centerCell;

- (void)reload;

- (void)stopScrool;
@end
