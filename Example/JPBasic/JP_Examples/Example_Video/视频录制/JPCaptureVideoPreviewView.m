//
//  JPCaptureVideoPreviewView.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/2/12.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPCaptureVideoPreviewView.h"

@implementation JPCaptureVideoPreviewView

+ (Class)layerClass {
    return AVCaptureVideoPreviewLayer.class;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

@end
