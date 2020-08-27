//
//  ViewController.m
//  JPBasic
//
//  Created by zhoujianping24@hotmail.com on 03/18/2020.
//  Copyright (c) 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "ViewController.h"
#import "JPStartPauseButton.h"

@interface ViewController ()
@property (nonatomic, weak) UILabel *label1;
@property (nonatomic, weak) UILabel *label2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
}

- (void)abc {
    JPStartPauseButton *spBtn = [JPStartPauseButton startPauseButton];
    spBtn.center = CGPointMake(JPPortraitScreenWidth * 0.5, JPPortraitScreenHeight * 0.5);
    [self.view addSubview:spBtn];
    
    UILabel *label1 = ({
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        aLabel.textAlignment = NSTextAlignmentLeft;
        aLabel.backgroundColor = JPRandomColor;
        aLabel.numberOfLines = 2;
        aLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        aLabel;
    });
    [self.view addSubview:label1];
    self.label1 = label1;
    
    UILabel *label2 = ({
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 220, 100, 100)];
        aLabel.textAlignment = NSTextAlignmentLeft;
        aLabel.backgroundColor = JPRandomColor;
        aLabel.numberOfLines = 2;
        aLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        aLabel;
    });
    [self.view addSubview:label2];
    self.label2 = label2;
    
    NSString *text = @"周健平帅气 周健平帅可敌国帅可敌国帅可敌国";
    
    NSMutableParagraphStyle *parag1 = [[NSMutableParagraphStyle alloc] init];
    parag1.firstLineHeadIndent = 0;
    parag1.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attDic1 = @{NSFontAttributeName: [UIFont systemFontOfSize:15],
                             NSForegroundColorAttributeName: JPRandomColor,
                             NSParagraphStyleAttributeName: parag1};
    
    NSAttributedString *attStr1 = [[NSAttributedString alloc] initWithString:text attributes:attDic1];
    
    NSMutableParagraphStyle *parag2 = [[NSMutableParagraphStyle alloc] init];
    parag2.firstLineHeadIndent = 30;
    parag2.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attDic2 = @{NSFontAttributeName: [UIFont systemFontOfSize:15],
                             NSForegroundColorAttributeName: JPRandomColor,
                             NSParagraphStyleAttributeName: parag2};
    
    NSAttributedString *attStr2 = [[NSAttributedString alloc] initWithString:text attributes:attDic2];
    
//    CGRect rect = [attStr boundingRectWithSize:label.jp_size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    JPLog(@"rect0 %@", NSStringFromCGRect(rect));
//
//    BOOL isOneLine = YES;
//    rect =  [JPSolveTool attTextFrameWithText:attStr maxSize:label.jp_size isOneLine:&isOneLine];
//    JPLog(@"rect1 %@ %d", NSStringFromCGRect(rect), isOneLine);
//
//    JPLog(@"-----");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.label1.attributedText = attStr1;
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.label2.attributedText = attStr2;
    });
}


@end
