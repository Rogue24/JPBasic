//
//  JPWatermarkElement.h
//  JPBasic
//
//  Created by aa on 2022/4/22.
//  Copyright © 2022 zhoujianping24@hotmail.com. All rights reserved.
//
//  基于`GPUImageUIElement`，修复<<单次刷新静态水印导致崩溃>>的问题。

#import "GPUImageOutput.h"

@interface JPWatermarkElement : GPUImageOutput

// Initialization and teardown
- (id)initWithView:(UIView *)inputView;
- (id)initWithLayer:(CALayer *)inputLayer;

// Layer management
- (CGSize)layerSizeInPixels;
- (void)update;
- (void)updateUsingCurrentTime;
- (void)updateWithTimestamp:(CMTime)frameTime;

@end
