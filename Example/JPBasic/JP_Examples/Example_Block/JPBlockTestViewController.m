//
//  JPBlockTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/7/7.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPBlockTestViewController.h"
#import "JPBBBViewController.h"

@interface JPBlockTestViewController ()

@end

@implementation JPBlockTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    JPBBBViewController *vc = [[JPBBBViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
