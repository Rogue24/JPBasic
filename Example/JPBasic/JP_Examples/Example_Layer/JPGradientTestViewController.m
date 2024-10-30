//
//  JPGradientTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/8/7.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPGradientTestViewController.h"

@interface JPGradientTestViewController ()
@property (nonatomic, weak) CAGradientLayer *gLayer1;
@property (nonatomic, weak) CAGradientLayer *gLayer2;
@property (nonatomic, weak) CAGradientLayer *gLayer3;
@end

@implementation JPGradientTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    
    
    CAGradientLayer *gLayer1 = [CAGradientLayer layer];
    gLayer1.type = kCAGradientLayerRadial;
    // 宽度和高度分别由（endPoint.x-startPoint.x）* 2 和（endPoint.y-startPoint.y）* 2 定义。
    gLayer1.startPoint = CGPointMake(0.5, 0.5);
    gLayer1.endPoint = CGPointMake(1.0, 1.0);
    gLayer1.frame = CGRectMake(100, 100, 100, 100);
    gLayer1.backgroundColor = UIColor.clearColor.CGColor;
    gLayer1.colors = @[(id)UIColor.redColor.CGColor, (id)UIColor.greenColor.CGColor, (id)UIColor.blueColor.CGColor];
    [self.view.layer addSublayer:gLayer1];
    self.gLayer1 = gLayer1;
    
    if (@available(iOS 12.0, *)) {
        CAGradientLayer *gLayer2 = [CAGradientLayer layer];
        gLayer2.type = kCAGradientLayerConic;
        gLayer2.startPoint = CGPointMake(0.5, 0.5);
        gLayer2.endPoint = CGPointMake(1.0, 1.0);
        gLayer2.frame = CGRectMake(100, 220, 100, 100);
        gLayer2.backgroundColor = UIColor.clearColor.CGColor;
        gLayer2.colors = @[(id)UIColor.redColor.CGColor, (id)UIColor.greenColor.CGColor, (id)UIColor.blueColor.CGColor];
        [self.view.layer addSublayer:gLayer2];
        self.gLayer2 = gLayer2;
    }
    
    CAGradientLayer *gLayer3 = [CAGradientLayer layer];
    gLayer3.type = kCAGradientLayerAxial;
    gLayer3.startPoint = CGPointMake(0.5, 0.5);
    gLayer3.endPoint = CGPointMake(1.0, 1.0);
    gLayer3.frame = CGRectMake(100, 340, 100, 100);
    gLayer3.backgroundColor = UIColor.clearColor.CGColor;
    gLayer3.colors = @[(id)UIColor.redColor.CGColor, (id)UIColor.greenColor.CGColor, (id)UIColor.blueColor.CGColor];
    [self.view.layer addSublayer:gLayer3];
    self.gLayer3 = gLayer3;
    
    UISlider *slider1 = [[UISlider alloc] init];
    slider1.jp_width = JPPortraitScreenWidth - 20;
    slider1.jp_x = 10;
    slider1.jp_y = 600;
    slider1.maximumValue = 1;
    slider1.value = 0.5;
    [slider1 addTarget:self action:@selector(updateStart:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider1];
    
    UISlider *slider2 = [[UISlider alloc] init];
    slider2.jp_width = JPPortraitScreenWidth - 20;
    slider2.jp_x = 10;
    slider2.jp_y = 650;
    slider2.maximumValue = 1;
    slider2.value = 1;
    [slider2 addTarget:self action:@selector(updateEnd:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider2];
}

- (void)updateStart:(UISlider *)slider {
    CGFloat value = slider.value;
    CGPoint startPoint = CGPointMake(value, value);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gLayer1.startPoint = startPoint;
    self.gLayer2.startPoint = startPoint;
    self.gLayer3.startPoint = startPoint;
    [CATransaction commit];
}

- (void)updateEnd:(UISlider *)slider {
    CGFloat value = slider.value;
    CGPoint endPoint = CGPointMake(value, value);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gLayer1.endPoint = endPoint;
    self.gLayer2.endPoint = endPoint;
    self.gLayer3.endPoint = endPoint;
    [CATransaction commit];
}

@end
