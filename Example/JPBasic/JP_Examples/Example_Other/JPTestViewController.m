//
//  JPTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2019/12/12.
//  Copyright © 2019 zhoujianping24@hotmail.com. All rights reserved.
//
//  timer要添加到RunLoop中才会开始工作
//  timerWithTimeInterval创建的timer要手动添加到RunLoop中
//  scheduledTimerWithTimeInterval创建的timer默认就已经以Default模式添加到当前RunLoop中（想转模式就得重新手动添加到RunLoop中）
//  timerWithTimeInterval和scheduledTimerWithTimeInterval都不是马上开始执行，先过了间隔时间才开始第一次


#import "JPTestViewController.h"
#import "JPProxy.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

@interface JPTestViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UIView *subview;
@end

@implementation JPTestViewController

struct jp_method {
    SEL method_name;
    char *method_types;
    IMP method_imp;
};

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    JPLog(@"hello");
    
//    [self normalTimer];
//    [self scheduledTimer];
    
//    @"《暗黑破坏神III》是暴雪娱乐公司开发的一款魔幻类动作角色扮演游戏。玩家可以在七种不同的职业中进行选择，每种职业都有一套独特的魔法和技能。 玩家在冒险中可以挑战无以计数的恶魔、怪物和强大的BOSS，逐渐累积经验，增强能力，并且获得具有神奇力量的物品。"
//    JPLog(@"%.2lf", [@"《暗黑破坏神III》\n" boundingRectWithSize:CGSizeMake(JPPortraitScreenWidth, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: JPScaleFont(15)} context:nil].size.height);
//    JPLog(@"%.2lf", [@"《暗黑破坏神III》" boundingRectWithSize:CGSizeMake(JPPortraitScreenWidth, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: JPScaleFont(15)} context:nil].size.height);
//
//    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:@"《暗黑破坏神III》\n\naa\n" attributes:@{NSFontAttributeName: JPScaleFont(15)}];
//    NSArray *linesArray = [self twoStringLinesArrayWithAttStr:attStr rect:CGRectMake(0, 0, JPPortraitScreenWidth, JPScaleFont(15).lineHeight * 2)];
//    for (NSString *str in linesArray) {
//        JPLog(@"%@", str);
//        JPLog(@"----");
//    }
    
    
//    JPCacheFilePath(@"WLRecording") : JPDocumentFilePath(@"WLRecordDone");
//    }
//
//    + (NSString *)modelDotPath:(BOOL)isRecoding {
//        return [[self dotPath:isRecoding] stringByAppendingPathComponent:@"models"];
//    }
//    + (NSString *)modelPath:(BOOL)isRecoding {
//        return [[self dotPath:isRecoding] stringByAppendingPathComponent:(isRecoding ? @"WLRecordingModel.archive" : @"WLRecordDoneModels.archive")];
//    }
    
    NSLog(@"%@", JPDocumentPath);
    
    NSString *dotPath = JPDocumentFilePath(@"ABC");
    NSString *videoPath = [dotPath stringByAppendingPathComponent:@"videos"];
    NSString *imagePath = [dotPath stringByAppendingPathComponent:@"images"];
    [JPFileTool createDirectoryAtPath:videoPath];
    [JPFileTool createDirectoryAtPath:imagePath];
    
    
    UIButton *btn1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = JPScaleFont(20);
        [btn setTitle:@"存点东西" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(saveABC) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        btn.center = CGPointMake(100, 100);
        btn;
    });
    [self.view addSubview:btn1];
    
    UIButton *btn2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = JPScaleFont(20);
        [btn setTitle:@"删点东西" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deleteABC) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        btn.center = CGPointMake(100, 300);
        btn;
    });
    [self.view addSubview:btn2];
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)saveABC {
    NSString *dotPath = JPDocumentFilePath(@"ABC");
    NSString *videoPath = [[dotPath stringByAppendingPathComponent:@"videos"] stringByAppendingPathComponent:@"arr.plist"];
    NSString *imagePath = [[dotPath stringByAppendingPathComponent:@"images"] stringByAppendingPathComponent:@"arr.plist"];
    
    NSArray *arr1 = @[@"1", @"2", @"3"];
    [arr1 writeToURL:[NSURL fileURLWithPath:videoPath] atomically:YES];
    
    NSArray *arr2 = @[@"4", @"5", @"6"];
    [arr2 writeToURL:[NSURL fileURLWithPath:imagePath] atomically:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    JPLog(@"%@", NSStringFromCGRect(self.subview.frame));
}

- (void)deleteABC {
    JPLog(@"%s", __func__);
}

#pragma mark - 定时器相关
- (void)scheduledTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:JPTargetProxy(self) selector:@selector(timerHandle) userInfo:nil repeats:YES];
}

- (void)normalTimer {
    self.timer = [NSTimer timerWithTimeInterval:3 target:JPTargetProxy(self) selector:@selector(timerHandle) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timerHandle {
    JPLog(@"%s", __func__);
}

#pragma mark - 文本相关
// 参考：https://www.jianshu.com/p/33b93b39311a
// 获取前两行文字
- (NSArray *)twoStringLinesArrayWithAttStr:(NSAttributedString *)attStr rect:(CGRect)rect {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, 100000));
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attStr);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (NSArray *)CTFrameGetLines(frame);
    
    NSMutableArray *linesArray = [NSMutableArray array];
    NSInteger count = lines.count > 2 ? 2 : lines.count;
    for (NSInteger i = 0; i < count; i++) {
        CTLineRef lineRef = (__bridge CTLineRef)lines[i];
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [attStr.string substringWithRange:range];
        [linesArray addObject:lineString];
    }
    
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(frameSetter);
    return (NSArray *)linesArray;
}
@end

