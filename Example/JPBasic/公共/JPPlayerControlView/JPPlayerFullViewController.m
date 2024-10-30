//
//  JPPlayerFullViewController.m
//
//  Created by ios app on 16/6/15.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "JPPlayerFullViewController.h"

@interface JPPlayerFullViewController ()

@end

@implementation JPPlayerFullViewController

- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

@end
