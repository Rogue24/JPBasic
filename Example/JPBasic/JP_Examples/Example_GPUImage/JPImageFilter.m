//
//  JPImageFilter.m
//  04-GPUImage
//
//  Created by 周健平 on 2019/4/13.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPImageFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation JPImageFilter
{
    GPUImagePicture *lookupImageSource;
}

- (id)initWithLookupTableImage:(UIImage *)lookupTableImage;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
//#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
//    UIImage *image = [UIImage imageNamed:@"lookup_amatorka.png"];
//#else
//    NSImage *image = [NSImage imageNamed:@"lookup_amatorka.png"];
//#endif
    
//    NSString *filterPath = [[[NSBundle mainBundle] pathForResource:@"FilterResource" ofType:@"bundle"] stringByAppendingPathComponent:@"chunzhen.png"];
//#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
//    UIImage *image = [UIImage imageWithContentsOfFile:filterPath];
//#else
//    NSImage *image = [NSImage imageWithContentsOfFile:filterPath];
//#endif
//
//    NSAssert(image, @"To use GPUImageAmatorkaFilter you need to add lookup_amatorka.png from GPUImage/framework/Resources to your application bundle.");
    
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:lookupTableImage];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

@end
