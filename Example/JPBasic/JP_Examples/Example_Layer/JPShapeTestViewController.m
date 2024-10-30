//
//  JPShapeTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/8/7.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPShapeTestViewController.h"

@interface JPShapeTestViewController ()

@end

@implementation JPShapeTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    JPLog(@"1");
    dispatch_async(dispatch_get_main_queue(), ^{
        JPLog(@"2");
    });
    JPLog(@"3");
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = JPRandomColor.CGColor;
    shapeLayer.path = [self kkkkPath].CGPath;
    [self.view.layer addSublayer:shapeLayer];
}

- (UIBezierPath *)kkkkPath {
    CGFloat radio = 100;
    CGFloat angle = M_PI_2;
    CGPoint center = CGPointMake(200, 400);
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
//    CGFloat line = cos(angle)*radio;
    [path moveToPoint:CGPointMake(center.x, center.y)];
//    [path addQuadCurveToPoint:CGPointMake(center.x + line, line + center.y) controlPoint:CGPointMake(center.x, center.y)];
    [path addArcWithCenter:center radius:radio startAngle:angle endAngle:2*M_PI clockwise:YES];
    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(200, 200, 200, 200)];
    
    return path;
}

@end
