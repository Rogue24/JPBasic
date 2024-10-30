//
//  JPGPUImageSingleFilterViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/2/13.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPGPUImageSingleFilterViewController.h"
#import "JPPhotoTool.h"

#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif

@interface JPGPUImageSingleFilterViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *originImageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) GPUImagePicture *processImage;
@property (nonatomic, strong) GPUImageGaussianBlurFilter *gaussianBlurFilter;
@property (nonatomic, strong) GPUImageSwirlFilter *swirlFilter;
@property (nonatomic, strong) GPUImageEmbossFilter *embossFilter;
@property (nonatomic, strong) GPUImageGlassSphereFilter *glassSphereFilter;
@property (nonatomic, strong) GPUImageToonFilter *otherFilter;
@property (nonatomic, weak) GPUImageFilter *currentFilter;
@end

@implementation JPGPUImageSingleFilterViewController

- (GPUImageGaussianBlurFilter *)gaussianBlurFilter {
    if (!_gaussianBlurFilter) {
        _gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    }
//    filter.blurRadiusInPixels = 5;
//    filter.texelSpacingMultiplier = 5;
    return _gaussianBlurFilter;
}

- (GPUImageSwirlFilter *)swirlFilter {
    if (!_swirlFilter) {
        _swirlFilter = [[GPUImageSwirlFilter alloc] init];
    }
    return _swirlFilter;
}

- (GPUImageEmbossFilter *)embossFilter {
    if (!_embossFilter) {
        _embossFilter = [[GPUImageEmbossFilter alloc] init];
    }
    return _embossFilter;
}

- (GPUImageGlassSphereFilter *)glassSphereFilter {
    if (!_glassSphereFilter) {
        _glassSphereFilter = [[GPUImageGlassSphereFilter alloc] init];
    }
    return _glassSphereFilter;
}

- (GPUImageFilter *)otherFilter {
    if (!_otherFilter) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
//        _otherFilter = [[GPUImageToonFilter alloc] init];
        _otherFilter = [[GPUImagePixellateFilter alloc] init]; // 马赛克滤镜
//        _otherFilter = [[GPUImageRGBDilationFilter alloc] init];
#pragma clang diagnostic pop
    }
    return _otherFilter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *saveBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:@"保存至相册" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    self.image = [UIImage imageNamed:@"Car.jpg"];
//    self.image = [UIImage imageNamed:@"Lisa.png"];
    
    self.originImageView.image = self.image;
    self.processImage = [[GPUImagePicture alloc] initWithImage:self.image];
    
    self.imageView.hidden = YES;
    self.slider.userInteractionEnabled = NO;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)saveAction {
    if (!self.currentFilter) return;
    [JPProgressHUD showWithStatus:@"正在保存..."];
    // 使用imageFromCurrentFramebuffer获取处理后的图片
    //【前提】要先调用useNextFrameForImageCapture，再调用processImage
    [self.currentFilter useNextFrameForImageCapture];
    // processImage内部会开启子线程来进行图像处理（runAsynchronouslyOnVideoProcessingQueue）
    [self.processImage processImageWithCompletionHandler:^{
        // imageFromCurrentFramebuffer：会卡住当前线程等待GPU返回渲染好的图像，所以最好放到子线程里面调用
        UIImage *newImage = [self.currentFilter imageFromCurrentFramebuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPPhotoToolSI savePhotoToAppAlbumWithImage:newImage successHandle:^(NSString *assetID) {
                [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
            } failHandle:^(NSString *assetID, BOOL isGetAlbumFail, BOOL isSaveFail) {
                [JPProgressHUD showErrorWithStatus:@"保存失败" userInteractionEnabled:YES];
            }];
        });
    }];
}

- (IBAction)filterAction:(UIButton *)sender {
    GPUImageFilter *filter;
    CGFloat value = 0;
    switch (sender.tag) {
        case 1:
            value = (CGFloat)self.gaussianBlurFilter.blurRadiusInPixels / 10.0;
            filter = self.gaussianBlurFilter;
            break;
        case 2:
            value = self.swirlFilter.radius;
            filter = self.swirlFilter;
            break;
        case 3:
            value = self.embossFilter.intensity / 4.0;
            filter = self.embossFilter;
            break;
        case 4:
            value = self.glassSphereFilter.refractiveIndex;
            filter = self.glassSphereFilter;
            break;
        case 5:
//            value = self.otherFilter.threshold;
            value = [(GPUImagePixellateFilter *)self.otherFilter fractionalWidthOfAPixel] * 10.0;
//            value = 0;
            filter = self.otherFilter;
            break;
        default:
            break;
    }
    if (self.currentFilter == filter) return;
    
    if (self.currentFilter) {
        [self.currentFilter removeTarget:self.imageView];
        [self.processImage removeTarget:self.currentFilter];
    }
    self.currentFilter = filter;
    
    BOOL isFilter = filter != nil;
    if (isFilter) {
        [self.processImage addTarget:filter];
        [filter addTarget:self.imageView];
        if (self.imageView.hidden) {
            // processImage内部会开启子线程来进行图像处理（runAsynchronouslyOnVideoProcessingQueue）
            [self.processImage processImageWithCompletionHandler:^{
                // 这里还是在子线程，UI刷新的操作记得要回到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.currentFilter == filter) {
                        self.imageView.hidden = NO;
                        self.originImageView.hidden = YES;
                    }
                });
            }];
        } else {
            [self.processImage processImage];
        }
    } else {
        self.imageView.hidden = YES;
        self.originImageView.hidden = NO;
    }
    
    self.slider.userInteractionEnabled = isFilter;
    [self.slider setValue:value animated:YES];
}

- (IBAction)sliderValueDidChanged:(UISlider *)sender {
    if (!self.currentFilter) {
        return;
    }
    CGFloat value = sender.value;
    if (self.currentFilter == self.gaussianBlurFilter) {
        self.gaussianBlurFilter.blurRadiusInPixels = value * 10.0;
    } else if (self.currentFilter == self.swirlFilter) {
        self.swirlFilter.radius = value;
        self.swirlFilter.center = CGPointMake(value, value);
    } else if (self.currentFilter == self.embossFilter) {
        self.embossFilter.intensity = value * 4.0;
    } else if (self.currentFilter == self.glassSphereFilter) {
        self.glassSphereFilter.refractiveIndex = value;
    } else if (self.currentFilter == self.otherFilter) {
//        self.otherFilter.threshold = value;
        [(GPUImagePixellateFilter *)self.otherFilter setFractionalWidthOfAPixel:(value / 10.0)];
    }
    [self.processImage processImage]; // processImage内部会开启子线程来进行图像处理
}

#pragma mark - 基本使用：获取处理后的图片
/*
 *【文档说明】
 * 如果您尝试使用这些方法：
    -imageFromCurrentFramebuffer
    -imageFromCurrentFramebufferWithOrientation:
    -imageByFilteringImage:(UIImage *)imageToFilter
    -newCGImageByFilteringImage:
 * 请记住，在运行-processImage或运行video并调用这些方法之前，需要设置-useNextFrameForImageCapture，否则将得到一个nil图像
 * 使用例子：
     1. [filter useNextFrameForImageCapture];
     2. [processImage processImage];
     3. UIImage *newImage = [filter imageFromCurrentFramebuffer];
 *
 * 请注意，对于从filter中手动捕获图像，需要设置-useNextFrameForImageCapture，以便告诉filter以后需要从中捕获图像。
 * 默认情况下，GPUImage在filter中重用帧缓冲区以节省内存，因此，如果需要保留filter的帧缓冲区以进行手动图像捕获，则需要提前通知它。
 */
- (UIImage *)test:(UIButton *)sender {
    // 1.获取需要处理的图片
    UIImage *image = self.image;
    
    // 2.创建GPUImagePicture
    GPUImagePicture *processImage = [[GPUImagePicture alloc] initWithImage:image];
    
    // 3.添加对应的滤镜
    GPUImageFilter *filter;
    switch (sender.tag) {
        case 1:
            filter = [self gaussianBlurFilter];
            break;
        case 2:
            filter = [self swirlFilter];
            break;
        case 3:
            filter = [self embossFilter];
            break;
        case 4:
            filter = [self glassSphereFilter];
            break;
        case 5:
            filter = [self otherFilter];
            break;
        default:
            break;
    }
    
    // 4.将滤镜添加到processImage
    [processImage addTarget:filter];
    
    // 5.使用滤镜处理下一次显示的该图片
    [filter useNextFrameForImageCapture]; // 保留滤镜的帧缓冲区以进行手动图像捕获（使用下一帧进行图像捕获）
    [processImage processImage];
    
    // 6.获取最新的图片
    UIImage *newImage = [filter imageFromCurrentFramebuffer]; // 图像捕获（来自当前帧缓冲区的图像）
    return newImage;
}

@end
