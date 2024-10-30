//
//  TTWheelView.m
//  wheelView
//
//  Created by simp on 2018/2/28.
//  Copyright © 2018年 yiyou. All rights reserved.
//

#import "TTWheelView.h"
#import "TTWheelCell.h"
#import <Masonry/Masonry.h>

@interface TTWheelView()<TTWheelInnerProtocol,UIScrollViewDelegate>

/**轮盘的滚动控制*/
@property (nonatomic, strong) UIScrollView * scrollView;

/**轮盘试图*/
@property (nonatomic, strong) UIView * wheel;

/**轮盘半径*/
@property (nonatomic, assign) CGFloat radiu;

/**轮盘被分为啦多少个部分*/
@property (nonatomic, assign) NSUInteger divitionCount;

/**每个cell 所占用的弧度*/
@property (nonatomic, assign) CGFloat angelPerCell;

/**cell的缓存-重用机制*/
@property (nonatomic, strong) NSDictionary * cellCache;

/**当前的索引位置*/
@property (nonatomic, assign) NSInteger indexFlas;

/** 周长*/
@property (nonatomic, assign) CGFloat perimeter;

@property (nonatomic, strong) TTWheelCell * cell;

/**是否可以从缓存拿数据*/
@property (nonatomic, assign) BOOL isCanDequeen;

@property (nonatomic, strong) NSMutableArray * allCells;

@property (nonatomic, assign) CGPoint lastOffset;;

@property (nonatomic, assign) BOOL isStoppingRotate;

@property (nonatomic, strong) CAShapeLayer * maskLayer;

@property (nonatomic, assign) CGFloat innerMaskRadiu;

/**是否已经布局了*/
@property (nonatomic, assign) BOOL layouted;

@property (nonatomic, assign) BOOL stoped;

/**上次的速度*/
@property (nonatomic, assign) CGFloat lastVelocy;

/**当前一共滚动的距离 有正负之分*/
@property (nonatomic, assign) CGFloat totoalScrolled;
@end

@implementation TTWheelView

- (instancetype)initWithradiu:(CGFloat)radiu divitionCount:(NSUInteger)divitionCount {
    if (self = [super init]) {
        self.radiu = radiu;
        self.divitionCount = divitionCount;
        self.angelPerCell = M_PI * 2 / divitionCount;
        _pageArc = 0;
        self.isStoppingRotate = NO;
        self.stoped = NO;
        self.totoalScrolled = 0;
        [self initialData];
        [self initialUI];
    }
    return self;
}


+ (instancetype)wheelWithCrossWidth:(CGFloat)width widthCrossHeight:(CGFloat)height withPartNumber:(NSInteger)number {
    CGFloat a = height;
    CGFloat b = width/2;
    CGFloat radiu = (a * a + b * b)/(2*a);
    CGFloat sinAlfa = b /radiu;
    CGFloat angel = asin(sinAlfa) * 2;
    NSInteger totoalNumber = number * 2 *M_PI / angel;
    TTWheelView *wheel = [[TTWheelView alloc] initWithradiu:radiu divitionCount:totoalNumber+1];
    return wheel;
    
}

- (void)initialData {
    self.perimeter =  M_PI * self.radiu * 2;
    self.cellCache = [NSMutableDictionary dictionary];
    self.allCells = [NSMutableArray array];
    _innerMaskRadiu = 0;
}

- (void)initialUI {
    [self initialWheelView];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.radiu * 2);
        make.height.mas_equalTo(self.radiu * 2);
    }];
    self.backgroundColor = [UIColor clearColor];
}

- (void)initialScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    [self insertSubview:self.scrollView atIndex:0];
//    [self addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self addGestureRecognizer:self.scrollView.panGestureRecognizer];
    self.scrollView.panGestureRecognizer.delaysTouchesBegan = YES;
    self.scrollView.contentSize = CGSizeMake(self.perimeter * 3, self.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.perimeter, self.frame.size.height);
    self.scrollView.delegate = self;
    
    self.scrollView.showsHorizontalScrollIndicator = YES;
    
}

- (void)initialWheelView {
    self.wheel = [[UIView alloc] init];
    [self addSubview:self.wheel];
    
    [self.wheel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];    
}


/**初始化 各个Cell*/
- (void)cacluteCenterPointerForCellsAt:(NSUInteger)dataStart {
    NSInteger i = 0;
    NSInteger startDivtin = dataStart % self.divitionCount;
    NSUInteger count = [self.dataSource dataCountForWheel:self];
    i = 0;
    for (; i < self.divitionCount && i < count; i ++) {
        TTWheelCell * cell =  [self.dataSource cellAtIndex:i+dataStart forWheel:self];
        [self addCell:cell forDataIndex:i+dataStart andPartIndex:i];
        if (![self.allCells containsObject:cell]) {
            [self.allCells addObject:cell];
        }
        i %= self.divitionCount;
        if (!cell.visible) {
            break;
        }
    }
    
    if (i < self.divitionCount -1) {
        
       NSInteger j = self.divitionCount-1;
        for (; j != i; j--) {
            NSInteger dataindex = (startDivtin-(self.divitionCount - 1 - j) +count-1) % count;
            TTWheelCell * cell =  [self.dataSource cellAtIndex:dataindex forWheel:self];
            [self addCell:cell forDataIndex:dataindex andPartIndex:j];
            [self.allCells insertObject:cell atIndex:0];
            
            if (!cell.visible) {
                break;
            }
            self.cell = cell;
        }
    }
    self.isCanDequeen = YES;
}

- (void)addCell:(TTWheelCell *)cell forDataIndex:(NSInteger)dataIndex andPartIndex:(NSInteger)partIndex{
    cell.partIndex = partIndex;
    cell.dataIndex = dataIndex;
    cell.inderDelegate = self;
    CGSize size = [self.dataSource wheel:self sizeForItemAtIndex:dataIndex];
    CGFloat cellRaiud = [self.dataSource wheel:self radiuForIndex:dataIndex];
    
    CGFloat angel = self.angelPerCell * partIndex;
    CGPoint center = [self pointForAngel:angel andSubRadiu:cellRaiud];
    cell.radiu = cellRaiud;
    cell.currentAngel = angel;
    
    CGFloat centerX = sin(angel) * cellRaiud;
    CGFloat centerY = cos(angel) * cellRaiud;
    

    if (!cell.superview) {
        [self.wheel addSubview:cell];
        [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.wheel.mas_centerX).offset(centerX);
            make.centerY.equalTo(self.wheel.mas_centerY).offset(-centerY);
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(size.height);
        }];
    }else {
        [cell mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.wheel.mas_centerX).offset(centerX);
            make.centerY.equalTo(self.wheel.mas_centerY).offset(-centerY);
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(size.height);
        }];
    }
    
//    if (@available(iOS 11.0, *)) {
//        cell.bounds = CGRectMake(0, 0, size.width, size.height);
//        cell.center = center;
//    }else {//自动布局会减慢速度 能不用就尽量不用 11以下的系统布局会错乱所以只能用自动布局
//        [cell mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.wheel.mas_centerX).offset(centerX);
//            make.centerY.equalTo(self.wheel.mas_centerY).offset(-centerY);
//            make.width.mas_equalTo(size.width);
//            make.height.mas_equalTo(size.height);
//        }];
//    }

}

- (CGPoint)pointForAngel:(CGFloat)angel andSubRadiu:(CGFloat)radiu {
    CGFloat centerX = self.radiu + sin(angel) * radiu;
    CGFloat centerY = self.radiu - cos(angel) * radiu;
    CGPoint center = CGPointMake(centerX, centerY);
    return center;
}


- (void)setDataSource:(id<TTWheelDataSource>)dataSource {
    _dataSource = dataSource;
}


#pragma mark - cell 重用

/**不可见视图 入缓存*/
- (void)wheelCellDisAppeared:(TTWheelCell *)cell {
    [self enqueenCell:cell];
}

- (TTWheelCell *)dequeenCellForIdentifire:(NSString *)identifire {
    if (!_isCanDequeen) {
        return nil;
    }
    NSMutableArray *cells = [self.cellCache objectForKey:identifire];
    if (cells.count > 0) {

        TTWheelCell *cell = [cells objectAtIndex:0];
        [cells removeObject:cell];
        if (cell) {
        }
        return cell;
    }
    return nil;
}

- (void)enqueenCell:(TTWheelCell *)cell {
    NSMutableArray *cells = [self.cellCache objectForKey:cell.identifre];
    if (!cells) {
        cells = [NSMutableArray array];
    }
    cell.hidden = YES;
    [cells addObject:cell];
    [self.cellCache setValue:cells forKey:cell.identifre];
}

- (void)removeCellFromQueue:(TTWheelCell *)cell {
    NSMutableArray *cells = [self.cellCache objectForKey:cell.identifre];
    if ([cells containsObject:cell]) {
        [cells removeObject:cell];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.stoped) {
        return;
    }

    CGPoint offset = scrollView.contentOffset;
    CGFloat velocy = offset.x - self.lastOffset.x;
      self.lastVelocy = velocy;
    self.totoalScrolled += velocy;
    
    CGFloat x = offset.x;
    if (x > self.perimeter * 1.5) {
        x -=self.perimeter;
    }
    if (x < self.perimeter) {
        x += self.perimeter;
    }
    scrollView.contentOffset = CGPointMake(x, 0);
    [self scrollWheelWithLength:x-self.perimeter andClockWise:velocy<0];
    self.lastOffset = scrollView.contentOffset;
    
    
    if ((fabs(velocy)<=2) && (velocy != 0) && scrollView.isDecelerating && self.isStoppingRotate) {
        [self stopForScrollView:scrollView widthVelocy:velocy];
    }
  
    if (!self.layouted) {
        BOOL isFirst = (int)velocy == (int)self.perimeter?YES:NO;
        self.layouted = YES;
        if ([self.delegate respondsToSelector:@selector(wheelDidLayouted:)] && isFirst) {
            [self.delegate wheelDidLayouted:self];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(wheelDidScroll:)]) {
            [self.delegate wheelDidScroll:self];
        }
    }
}

- (void)stopForScrollView:(UIScrollView *)scrollView widthVelocy:(CGFloat)velocy{
    if (self.stopInCell) {
        CGFloat widthPerCell = self.perimeter /self.divitionCount;
        CGPoint offSet = scrollView.contentOffset;
        NSInteger muti = offSet.x/widthPerCell;
        CGFloat rest = offSet.x - muti * widthPerCell;
        
        CGFloat x;
        if (velocy<0) {//四舍五入
            x = muti * widthPerCell;
        }else {
            rest = widthPerCell - rest;
            x = (muti + 1) * widthPerCell;
        }
        
        CGFloat shouldTime = 1;
        CGFloat time = shouldTime*fabs((rest/widthPerCell));
        
        self.isStoppingRotate = YES;
//        [UIView animateWithDuration:time animations:^{
            [scrollView setContentOffset:CGPointMake(x, offSet.y) animated:YES];
//        } completion:^(BOOL finished) {
//            self.isStoppingRotate = NO;
//        }];
    
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self isAllUnVisible]) {
        NSLog(@"所有的都不可见了1");
        [self recoverWhenALlNotVisible];
    }
    if (!self.isStoppingRotate) {
        [self stopForScrollView:scrollView widthVelocy:self.lastVelocy];
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {//如果结束后直接停止了
        CGFloat widthPerCell = self.perimeter /self.divitionCount;
        CGPoint offSet = scrollView.contentOffset;
        NSInteger muti = offSet.x/widthPerCell;
        CGFloat rest = offSet.x - muti * widthPerCell;
        
        CGFloat x;
        if (rest<widthPerCell/2) {//四舍五入
            x = muti * widthPerCell;
        }else {
            rest = widthPerCell - rest;
            x = (muti + 1) * widthPerCell;
        }
        
        CGFloat shouldTime = 1;
        CGFloat time = shouldTime*fabs((rest/widthPerCell));
        [scrollView setContentOffset:CGPointMake(x, offSet.y) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self isAllUnVisible]) {
        NSLog(@"所有的都不可见了");
        [self recoverWhenALlNotVisible];
    }
    self.isStoppingRotate = NO;
    if ([self.delegate respondsToSelector:@selector(wheelDidStopScroll:)]) {
        [self.delegate wheelDidStopScroll:self];
    }
}

/**当所有的*/
- (void)recoverWhenALlNotVisible {
    
  
    if (self.lastVelocy < 0 && self.allCells.count > 0) {
          TTWheelCell *cell = self.allCells.lastObject;
         [self scrollToCell:cell];
    }else {
        TTWheelCell *cell = self.allCells.firstObject;
        [self scrollToCell:cell];
    }
   
    return;
    
    NSArray * all = [NSArray arrayWithArray:self.allCells];
    [self.allCells removeAllObjects];
    for (TTWheelCell *cell in all) {
        [self enqueenCell:cell];
    }
    
    NSUInteger dataCount = [self.dataSource dataCountForWheel:self];
    CGFloat a = self.perimeter / self.divitionCount;//每隔分区多少大 可以计算当前count 和正在哪个分区
    NSInteger countdiv = self.totoalScrolled / a;//一共滚过了多少分区
    
    NSInteger currentDataindex = 0;//当前所处的数据索引位置
    NSInteger cuurentDiv = countdiv % self.divitionCount;
    if (cuurentDiv < 0) {
        cuurentDiv = self.divitionCount - countdiv;
        currentDataindex = dataCount - (countdiv%dataCount);
    }else {
        currentDataindex = countdiv % dataCount;
    }
    
    NSLog(@"当前的分区是 %ld",cuurentDiv);
    
    
    NSInteger i =  cuurentDiv;
    NSInteger b = 0;
    for (; ; i ++) {
        NSUInteger dataIndex = (currentDataindex + i)%dataCount;
         NSLog(@"恢复了 %d 和 data %d _ 跟去 %ld",b++,dataIndex,i);
        TTWheelCell * cell =  [self.dataSource cellAtIndex:dataIndex forWheel:self];
       
        cell.hidden = NO;
        [self addCell:cell forDataIndex:i+currentDataindex andPartIndex:i];
        if (![self.allCells containsObject:cell]) {
            [self.allCells addObject:cell];
        }
        i %= self.divitionCount;
        if (!cell.visible) {
            break;
        }
        if (i == cuurentDiv) {
            break;
        }
    }
    
    if (i < self.divitionCount -1) {
        
        NSInteger j = i;
        for (; ; j--) {
            NSInteger dataindex = currentDataindex - i + j;
             NSLog(@"----恢复了 %d 和 data %d 跟去 %ld",b++,dataindex,j);
            TTWheelCell * cell =  [self.dataSource cellAtIndex:dataindex forWheel:self];
            
            cell.hidden = NO;
            [self addCell:cell forDataIndex:dataindex andPartIndex:j];
            [self.allCells insertObject:cell atIndex:0];
            
            if (!cell.visible) {
                break;
            }
            self.cell = cell;
            j = (self.divitionCount + j)%self.divitionCount;
            if (j == i) {
                break;
            }
        }
    }

    
    
    
}

/**  角度计算方式以轮盘周长来做计算 -个周长转一圈 */
- (void)scrollWheelWithLength:(CGFloat)len andClockWise:(BOOL)clockWise{
    if (!self.isCanDequeen) {
        return;
    }
    NSInteger round =  (int)(len /self.perimeter);
    len = len - self.perimeter * round;
    CGFloat angel = -(len/self.perimeter)* M_PI *2;
    self.wheel.transform = CGAffineTransformMakeRotation(angel);
    _currentAngel = angel;
    if (!clockWise) {//逆时针
        [self anticlockwiseDeal];
    }else {
        [self clockwiseDeal];
    }
    
    for (TTWheelCell *cell in self.allCells) {
        [cell resetAngel];
    }
}

/**逆时针的重用处理*/
- (void)anticlockwiseDeal {
  
    [self anticlockwiseDealVisibleCell];
//    [self anticlockwiseDealUNVisibleCell];
    
}

/**一次可能不只一个cell 变得不可见了*/
- (void)anticlockwiseDealVisibleCell {
    if (self.allCells.count <2) {
        return;
    }
    TTWheelCell * firstObject = [self.allCells objectAtIndex:1];
    if (firstObject && !firstObject.visible) { //不可见 添加到不可见数组
        TTWheelCell *fist = [self.allCells firstObject];
        [self enqueenCell:fist];
        [self.allCells removeObject:fist];
        [self anticlockwiseDealVisibleCell];
    }
}

- (void)anticlockwiseDealUNVisibleCell {
    NSUInteger count = [self.dataSource dataCountForWheel:self];
    TTWheelCell * tailUnvisibleCell = [self.allCells lastObject];
    if (tailUnvisibleCell && tailUnvisibleCell.visible) {
        NSInteger index = (tailUnvisibleCell.dataIndex + 1)%count;
        NSInteger partIndex = (tailUnvisibleCell.partIndex + 1)%self.divitionCount;
        TTWheelCell * cell =  [self.dataSource cellAtIndex:index forWheel:self];
        tailUnvisibleCell.hidden = NO;
        [self addCell:cell forDataIndex:index andPartIndex:partIndex];
        if (![self.allCells containsObject:cell]) {
            [self.allCells addObject:cell];
        }
        [self anticlockwiseDealUNVisibleCell];
    }
}

/**处理顺时针的重用*/
- (void)clockwiseDeal {

    //找到尾巴的地方的可见cell 的最后一个 并实时判断它是否可见
    [self ClockwiseDealVisibleCell];
    
    //找到左边第一个不可见的cell - 检查是否可见
//    [self ClockwiseDealUnVisibleCell];
}

/**一次可能不只一个cell 变得不可见了*/
- (void)ClockwiseDealVisibleCell {
    if (self.allCells.count <2) {
        return;
    }
    TTWheelCell * tailVisibleCell = [self.allCells objectAtIndex:self.allCells.count-2];
    if (tailVisibleCell && !tailVisibleCell.visible) { //不可见 添加到不可见数组
        TTWheelCell *last = [self.allCells lastObject];
        [self enqueenCell:last];
        
        [self.allCells removeLastObject];
        [self ClockwiseDealVisibleCell];
    }
    
}
/**一次可能不只一个cell 变得可见了*/
- (void)ClockwiseDealUnVisibleCell {
  
    NSUInteger count = [self.dataSource dataCountForWheel:self];
    TTWheelCell * headeUnvisibleCell = [self.allCells firstObject];
    if (headeUnvisibleCell && headeUnvisibleCell.visible) {
        NSInteger index = (headeUnvisibleCell.dataIndex-1 + count)%count;
        NSInteger partIndex = (headeUnvisibleCell.partIndex -1+self.divitionCount)%self.divitionCount;
        TTWheelCell * cell =  [self.dataSource cellAtIndex:index forWheel:self];
        [self addCell:cell forDataIndex:index andPartIndex:partIndex];
        headeUnvisibleCell.hidden = NO;
        if ([self.allCells containsObject:cell]) {        }
        [self.allCells insertObject:cell atIndex:0];
        [self ClockwiseDealUnVisibleCell];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!self.scrollView) {
        [self initialScrollView];
        [self cacluteCenterPointerForCellsAt:0];
        self.pageArc = self.pageArc;
    }
    if (!self.maskLayer) {
        [self maskWithInnderRadiu:0];
    }
}

#pragma mark - Cell是否可见

- (BOOL)wheelCellVisible:(TTWheelCell *)cell {
    CGFloat angel = cell.currentAngel + self.currentAngel;
    //旋转的frame 是不会计算的 这里我们需要计算相对frame
    CGPoint newCenter = [self pointForAngel:angel andSubRadiu:cell.radiu];
    CGRect newFrame = CGRectMake(newCenter.x - CGRectGetWidth(cell.bounds)/2, newCenter.y - CGRectGetWidth(cell.bounds)/2, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds));
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *superView = self.superview;
    CGRect cellFrame = [self convertRect:newFrame toView:superView];
    CGRect selfFrame = [self convertRect:self.bounds toView:superView];
    BOOL screenVisible = CGRectIntersectsRect(cellFrame, superView.bounds);
    BOOL superVisible = CGRectIntersectsRect(cellFrame, selfFrame);
    return screenVisible && superVisible;
    
}

/**设置翻页*/
- (void)setPageArc:(CGFloat)pageArc {
    //一页不能超过M_PI
    _pageArc = pageArc <= 0?0:pageArc;
    _pageArc = pageArc >= M_PI?M_PI:pageArc;
    
    CGFloat rate = pageArc/(M_PI*2);

    self.scrollView.pagingEnabled = _pageArc > 0;
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.height.equalTo(self.mas_height);
        make.width.mas_equalTo(self.perimeter*rate);
    }];
}

- (void)scrollToDataIndex:(NSInteger)dataIndex {

    NSArray *cells = [NSArray arrayWithArray:self.allCells];
    [self.allCells removeAllObjects];
    for (TTWheelCell *cell in cells) {
        [self enqueenCell:cell];
    }
    self.scrollView.contentOffset = CGPointMake(self.perimeter, 0);
    self.wheel.transform = CGAffineTransformMakeRotation(0);
    [self cacluteCenterPointerForCellsAt:dataIndex];

}

- (void)scrollToCell:(TTWheelCell *)cell {
    

    CGFloat angel =cell.currentAngel + self.currentAngel +  M_PI * 2;
    angel = fmodl(angel, M_PI*2);
    
    if (angel < M_PI*2 && angel >= M_PI) {
        angel =  angel - M_PI * 2;
    }
    CGFloat len = self.perimeter * (angel / (M_PI *2));
    CGPoint off = self.scrollView.contentOffset;
    self.lastOffset = off;
    CGFloat x = off.x + len;
    
//    self.scrollView.contentOffset = CGPointMake(x, 0);
    self.isStoppingRotate = YES;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
//    [self scrollViewDidScroll:self.scrollView];
    
}


- (void)maskWithInnderRadiu:(CGFloat)inner {
    if (!self.maskLayer) {
        self.maskLayer = [CAShapeLayer layer];
        [self.maskLayer setFillRule:kCAFillRuleEvenOdd];
    }
    _innerMaskRadiu = inner;
    
    UIBezierPath *path = _maskOutCircle?[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.radiu*2, self.radiu*2)]:[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.radiu*2, self.radiu*2)];

//    UIBezierPath *innerPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.radiu, self.radiu) radius:self.radiu startAngle:0 endAngle:M_PI*2 clockwise:YES];
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.radiu-inner, self.radiu-inner, inner*2, inner*2)];
    
    [path appendPath:innerPath];
    self.maskLayer.path = path.CGPath;
    
    self.layer.mask = self.maskLayer;
        
}

- (void)setMaskOutCircle:(BOOL)maskOutCircle {
    _maskOutCircle = maskOutCircle;
    if (maskOutCircle) {
        [self maskWithInnderRadiu:_innerMaskRadiu];
    }
}

- (void)cellClicked:(TTWheelCell *)cell {
    if ([self.delegate respondsToSelector:@selector(wheel:cellClicked:)]) {
        [self.delegate wheel:self cellClicked:cell];
    }
}

- (TTWheelCell *)centerCell {

    for (TTWheelCell *cell in self.allCells) {
        CGFloat angel =cell.currentAngel + self.currentAngel +  M_PI * 2;
        angel = fmodl(angel, M_PI*2);
        
        if (angel < M_PI*2 && angel >= M_PI) {
            angel =  angel - M_PI * 2;
        }
        angel = fabs(angel);
        if (angel < M_PI /self.divitionCount) {
            return cell;
        }
    }
    return nil;
}

- (void)reload {
    for (TTWheelCell *cell in self.allCells) {
        [self enqueenCell:cell];
    }
    [self.allCells removeAllObjects];
     NSUInteger count = [self.dataSource dataCountForWheel:self];
    if (count >0) {
        [self scrollToDataIndex:0];
    }
}

/*
 
 计算出每个cell 各自所在的角度
 
 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)isAllUnVisible {
    for (TTWheelCell *cell in self.allCells) {
        if (cell.visible) {
            return  NO;
        }
    }
    return YES;
}

- (void)stopScrool {
    self.scrollView.scrollEnabled = NO;
    self.stoped = YES;
}

@end
