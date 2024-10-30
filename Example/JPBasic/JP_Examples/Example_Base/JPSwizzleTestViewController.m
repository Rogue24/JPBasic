//
//  JPSwizzleTestViewController.m
//  JPBasic_Example
//
//  Created by aa on 2023/1/17.
//  Copyright © 2023 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPSwizzleTestViewController.h"
#import "JPSwizzleTestView.h"
//#import "UIView+JPhHitTest.h"

@interface JPSwizzleTestViewController ()
@property (nonatomic, weak) JPSwizzleTestView *v1;
@property (nonatomic, weak) JPSwizzleTestView *v2;
@property (nonatomic, weak) JPSwizzleTestView2 *v3;
@end

@implementation JPSwizzleTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    self.view.tag = 233;
    
    JPSwizzleTestView *v1 = [[JPSwizzleTestView alloc] initWithFrame:CGRectMake(50, 200, 300, 300)];
    v1.tag = 44;
//    v1.jp_isHook = YES;
    v1.backgroundColor = JPRandomColor;
    [self.view addSubview:v1];
    self.v1 = v1;
    
    JPSwizzleTestView *v2 = [[JPSwizzleTestView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    v2.tag = 66;
    v2.backgroundColor = JPRandomColor;
    [v1 addSubview:v2];
    self.v2 = v2;
    
    JPSwizzleTestView2 *v3 = [[JPSwizzleTestView2 alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    v3.tag = 88;
    v3.backgroundColor = JPRandomColor;
    [v1 addSubview:v3];
    self.v3 = v3;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.v1 my_log];
    JPLog(@"------------");
    [self.v2 my_log];
    JPLog(@"------------");
    [self.v3 my_log];
}

@end
