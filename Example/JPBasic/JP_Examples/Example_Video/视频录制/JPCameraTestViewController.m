//
//  JPCameraTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/2/12.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPCameraTestViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface JPCameraTestViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation JPCameraTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self photograph];
}

- (void)photograph {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController相关逻辑

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    JPLog(@"%@", info);
}

@end
