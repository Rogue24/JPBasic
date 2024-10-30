//
//  JPImageFilter.h
//  04-GPUImage
//
//  Created by 周健平 on 2019/4/13.
//  Copyright © 2019 周健平. All rights reserved.
//

#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface JPImageFilter : GPUImageFilterGroup
- (instancetype)initWithLookupTableImage:(UIImage *)lookupTableImage;
@end

NS_ASSUME_NONNULL_END
