//
//  JPRedPackageRainViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/9.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPRedPackageRainViewController.h"
#import "WTVRedPackageRainManager.h"

@interface JPRedPackageRainViewController ()

@end

@implementation JPRedPackageRainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [RPManager presentRedPackageRainViewController];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JPPostNotification(RedPackageRainStartNotification, nil, nil);
    });
}

@end
