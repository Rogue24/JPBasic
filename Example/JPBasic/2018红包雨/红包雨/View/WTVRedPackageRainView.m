//
//  WTVRedPackageRainView.m
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageRainView.h"

#define kClockSecond 0.1
#define kDandaoCount 5 // 弹道个数

@interface WTVRedPackageRainView ()

@property (nonatomic, weak) NSTimer *clock;

// 所有弹道的等待时间数组
@property (nonatomic, strong) NSMutableArray *laneWaitTimes;

// 每个弹道中正在行走中的最前面的那个弹幕要走完的剩余时间（例如总共要6秒跑完，现在跑到一半，那么就剩下3秒，那么这个时间就是3秒）
@property (nonatomic, strong) NSMutableArray *laneLeftTimes;

// 正在显示中的弹幕（已经发射出去的弹幕）
@property (nonatomic, strong) NSMutableArray *redPackageViews;
@property (nonatomic, strong) NSMutableArray *redPackageCacheViews;
@end

@implementation WTVRedPackageRainView
{
    BOOL _isPause;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)click:(UITapGestureRecognizer *)tap {
    
    CGPoint point = [tap locationInView:tap.view];
    
    for (WTVRedPackageView *redPackageView in self.redPackageViews) {
        CGRect frame = redPackageView.layer.presentationLayer.frame;
        BOOL isContanins = CGRectContainsPoint(frame, point);
        if (isContanins) {
            if ([self.delegate respondsToSelector:@selector(redPackageViewDidClick:atPoint:)]) {
                [self.delegate redPackageViewDidClick:redPackageView atPoint:point];
            }
            break;
        }
    }
    
}

#pragma mark - Getter

- (NSMutableArray *)models {
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}

- (NSTimer *)clock {
    if (!_clock) {
        NSTimer *clock = [NSTimer timerWithTimeInterval:kClockSecond target:self selector:@selector(checkAndBiu) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:clock forMode:NSRunLoopCommonModes];
        _clock = clock;
    }
    return _clock;
}

- (NSMutableArray *)laneWaitTimes {
    if (!_laneWaitTimes) {
        _laneWaitTimes = [NSMutableArray arrayWithCapacity:kDandaoCount];
        for (NSInteger i = 0; i < kDandaoCount; i++) {
            _laneWaitTimes[i] = @0.0;
        }
    }
    return _laneWaitTimes;
}

- (NSMutableArray *)laneLeftTimes {
    if (!_laneLeftTimes) {
        _laneLeftTimes = [NSMutableArray arrayWithCapacity:kDandaoCount];
        for (NSInteger i = 0; i < kDandaoCount; i++) {
            _laneLeftTimes[i] = @0.0;
        }
    }
    return _laneLeftTimes;
}

- (NSMutableArray *)redPackageViews {
    if (!_redPackageViews) {
        _redPackageViews = [NSMutableArray array];
    }
    return _redPackageViews;
}

- (NSMutableArray *)redPackageCacheViews {
    if (!_redPackageCacheViews) {
        _redPackageCacheViews = [NSMutableArray array];
    }
    return _redPackageCacheViews;
}

#pragma mark - 生命周期方法

// 当view被添加到父视图时会调用这个方法
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    // 启动时钟
    [self clock];
}

- (void)dealloc {
    [self.clock invalidate];
    self.clock = nil;
}

#pragma mark - 公有方法

- (void)pause {
    // 标识已经暂停
    _isPause = YES;
    
    // 对所有正在显示的弹幕暂停
    [[self.redPackageViews valueForKeyPath:@"layer"] makeObjectsPerformSelector:@selector(pauseAnimate)];
    
    // 销毁计时器
    [self.clock invalidate];
    self.clock = nil;
}
-(void)pauseAnimate{}
- (void)resume {
    // 标识没有暂停
    _isPause = NO;
    
    // 对所有正在显示的弹幕继续
    [[self.redPackageViews valueForKeyPath:@"layer"] makeObjectsPerformSelector:@selector(resumeAnimate)];
    
    // 启动计时器
    [self clock];
}

-(void)resumeAnimate{}

#pragma mark - 私有方法

// 检测模型数组里面所有的模型，是否可以发射，如果可以就直接发射
- (void)checkAndBiu {
    
    // 如果暂停了，计时器有可能没有被销毁，所以定义“_isPause”这个成员变量来防止这种情况的出现
    if (_isPause) return;
    
    // 实时更新弹道记录的时间信息
    for (NSInteger i = 0; i < kDandaoCount; i++) {
        
        double waitTime = [self.laneWaitTimes[i] doubleValue] - kClockSecond;
        if (waitTime < 0.0) {
            waitTime = 0.0;
        }
        self.laneWaitTimes[i] = @(waitTime);
        
        double leftTime = [self.laneLeftTimes[i] doubleValue] - kClockSecond;
        if (leftTime < 0.0) {
            leftTime = 0.0;
        }
        self.laneLeftTimes[i] = @(leftTime);
        
    }
    
    // 对模型数组进行排序，根据beginTime从小到大排列
    [self.models sortUsingComparator:^NSComparisonResult(WTVRedPackageModel *obj1, WTVRedPackageModel *obj2) {
        
        if (obj1.beginTime < obj2.beginTime) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
        
    }];
    
    NSMutableArray *deleteModels = [NSMutableArray array];
    for (WTVRedPackageModel *model in self.models) {
        
        // 1.检测开始时间是否到达
        NSTimeInterval beginTime = model.beginTime;
        
        // 获取当前时间（这个时间是当前视频\音频的当前进度时间）
        NSTimeInterval currentTime = self.delegate.currentTime;
        
        // 如果开始时间超过当前时间，就是还没到【可以发射的时间】，而且数组也经过了排序，后面的开始时间只会更大，所以结束循环
        if (beginTime > currentTime) {
            break;
        }
        
        // 能来这里，证明当前时间已经到达或者已经超过了开始时间，也就是说到了【可以发射的时间】了
        
        // 2.检测碰撞，如果可以发射出去，就把发射的模型从数组中移除
        if ([self checkBoomAndBiuWith:model]) {
            // 把发射模型放到移除数组中
            [deleteModels addObject:model];
        }
    }
    
    // 移除已经发射的模型
    [self.models removeObjectsInArray:deleteModels];
}

// 遍历所有的弹道，在每个弹道里面进行检测，让每个弹幕都不会发送碰撞（检测开始碰撞，再检测结束碰撞）
// 没有碰撞就发射，发射就返回YES
- (BOOL)checkBoomAndBiuWith:(WTVRedPackageModel *)model {
    
    // 获取每个弹道的高度
    CGFloat danDaoH = self.bounds.size.height / kDandaoCount;
    
    for (NSInteger i = 0; i < kDandaoCount; i++) {
        
        // 1.获取该弹道的绝对等待时间
        NSTimeInterval waitTime = [self.laneWaitTimes[i] doubleValue];
        
        // 如果有这个等待时间，那么这个弹幕就不能先发射，因为这时候上一个弹幕还没完全出现，也就是只冒出一部分的情况，跳过这个弹幕视图
        if (waitTime > 0.0) {
            continue;
        }
        
        // 2.绝对等待时间没有，说明上一个弹幕已经完全出来了，就可以发射现在这个弹幕了
        
        // 如果发射了，后面会不会与前面的一个弹幕视图产生碰撞？
        
        // 拿到现在想要发射的弹幕视图
        WTVRedPackageView *redPackageView;
        if (self.redPackageCacheViews.count) {
            redPackageView = self.redPackageCacheViews.firstObject;
            redPackageView.model = model;
            [self.redPackageCacheViews removeObjectAtIndex:0];
        } else {
            redPackageView = [[WTVRedPackageView alloc] initWithModel:model];
        }
//        UIView *redPackageView = [self.delegate redPackageViewWithModel:model];
        
        // 拿到当前弹道的剩余时间（这个弹道正在行走中的最前面的那个弹幕要走完的剩余时间）
        NSTimeInterval leftTime = [self.laneLeftTimes[i] doubleValue];
        
        // 求出这个弹幕视图的行走速度
        double speed = (redPackageView.bounds.size.width + self.bounds.size.width) / model.liveTime;
        
        // 根据剩余时间和速度，计算出这个弹幕视图在这个剩余时间段之内将行走的距离
        double distance = leftTime * speed;
        
        // 当剩余时间为0时，上一个弹幕刚好跑完，maxX等于0，刚刚从视图中消失
        // 如果这个距离小于总视图的宽度，到那时候这个弹幕的x大于0，还在总视图区域内
        // 如果这个距离等于总视图的宽度，到那时候这个弹幕的x等于0，刚好到达总视图的左边界
        // 如果这个距离大于总视图的宽度，到那时候这个弹幕的x小于0，左边部分超出了总视图的范围，也就是说与上一个弹幕发送了碰撞
        
        // 到那时候碰撞了，就continue去判断下一个弹幕，这个弹幕就不发射了
        if (distance > self.bounds.size.width) {
            continue;
        }
        
        // 添加到正在显示的弹幕数组中
        [self.redPackageViews addObject:redPackageView];
        
        // 重置数据
        // 当前等待时间就是现在发射的弹幕从开始到滑出弹幕视图的宽度（完全出现）的时间
        self.laneWaitTimes[i] = @(redPackageView.frame.size.width / speed);
        // 当前剩余时间就是现在发射的弹幕的运行时间
        self.laneLeftTimes[i] = @(model.liveTime);
        
        // 3.来到这里，代表这个弹幕不会跟上一个弹幕发送碰撞，可以发射了
        
        // 3.1 先把弹幕视图加到总视图里面
        
        CGFloat scale = (CGFloat)(7 + arc4random() % 4) / 10.0;
        CGFloat w = 100 * scale;
        CGFloat h = 100 * scale;
        CGFloat x = self.bounds.size.width;
        CGFloat y = i * danDaoH + (100 - h) * 0.5 + (CGFloat)(arc4random() % 2 == 0 ? -1 : 1) * (CGFloat)(arc4random() % 30);
//        NSLog(@"y ==== %.2lf", y);
        
        redPackageView.frame = CGRectMake(x, y, w, h);
        
        [self addSubview:redPackageView];
        
        [UIView animateWithDuration:model.liveTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect frame = redPackageView.frame;
            frame.origin.x = -redPackageView.frame.size.width;
            redPackageView.frame = frame;
        } completion:^(BOOL finished) {
//            [redPackageView removeFromSuperview];
            if (finished) {
                [self.redPackageCacheViews addObject:redPackageView];
            }
            [self.redPackageViews removeObject:redPackageView];
        }];
        
        return YES;
        
    }
    
    return NO;
}

@end
