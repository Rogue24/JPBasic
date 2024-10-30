//
//  WLVideoInterceptionThumbnail.m
//  WoLive
//
//  Created by 周健平 on 2020/4/2.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import "WLVideoInterceptionThumbnail.h"

@implementation WLVideoInterceptionThumbnail

- (void)dealloc {
    if (self.imageRef) {
        JPLog(@"释放CGImageRef！");
        CGImageRef imageRef = (__bridge CGImageRef)self.imageRef;
        CGImageRelease(imageRef);
        self.imageRef = nil;
    }
}

@end
