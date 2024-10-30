//
//  WLVideoInterceptionThumbnail.h
//  WoLive
//
//  Created by 周健平 on 2020/4/2.
//  Copyright © 2020 周恩慧. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface WLVideoInterceptionThumbnail : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CMTime time;
@property (nonatomic, strong) id imageRef;
@end

