//
//  JPImageViewTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/15.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPImageViewTestViewController.h"
#import "JPTextView.h"
#import <malloc/malloc.h>

@interface JPImageViewTestViewController ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) JPTextView *textView;
@end

@implementation JPImageViewTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    UIImageView *imageView = ({
        UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, JPNavTopMargin + 20, JPPortraitScreenWidth, JPPortraitScreenWidth)];
        aImgView.contentMode = UIViewContentModeScaleAspectFit;
        aImgView.backgroundColor = UIColor.blackColor;
        aImgView;
    });
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    UIButton *sizeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"原图" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        btn.backgroundColor = JPRandomColor;
        [btn addTarget:self action:@selector(lookSize:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(20, imageView.jp_maxY + 30, 80, 40);
        btn.tag = 1;
        btn;
    });
    [self.view addSubview:sizeBtn];
    
    UIButton *cgResizeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"CG压缩" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        btn.backgroundColor = JPRandomColor;
        [btn addTarget:self action:@selector(lookSize:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(sizeBtn.jp_maxX + 20, imageView.jp_maxY + 30, 80, 40);
        btn.tag = 2;
        btn;
    });
    [self.view addSubview:cgResizeBtn];
    
    UIButton *ioResizeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"IO压缩" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        btn.backgroundColor = JPRandomColor;
        [btn addTarget:self action:@selector(lookSize:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(cgResizeBtn.jp_maxX + 20, imageView.jp_maxY + 30, 80, 40);
        btn.tag = 3;
        btn;
    });
    [self.view addSubview:ioResizeBtn];
    
    UIButton *uiResizeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"UI压缩" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        btn.backgroundColor = JPRandomColor;
        [btn addTarget:self action:@selector(lookSize:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(ioResizeBtn.jp_maxX + 20, imageView.jp_maxY + 30, 80, 40);
        btn.tag = 4;
        btn;
    });
    [self.view addSubview:uiResizeBtn];
    
    JPTextView *textView = [[JPTextView alloc] initWithFrame:CGRectMake(20, uiResizeBtn.jp_maxY + 20, JPPortraitScreenWidth - 40, 200)];
    textView.textColor = JPRandomColor;
    textView.backgroundColor = JPRandomColor;
    textView.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:textView];
    self.textView = textView;
}

/*
 * https://www.jianshu.com/p/cd8f2692e064
 * 原文地址：http://blog.leichunfeng.com/blog/2017/02/20/talking-about-the-decompression-of-the-image-in-ios/
 * 上面原文地址貌似没了，这是转载的：https://www.jianshu.com/p/4add78dbe4df
 
 * 解压缩后的图片大小(单位Byte，占多少字节) = 图片的像素宽 * 图片的像素高 * 每个像素所占的字节数；
 * totalByte = pw * ph * 4;
 
 * 位图就是一个像素数组，数组中的每个像素就代表着图片中的一个点。经常用到的 JPEG 和 PNG 图片就是位图。
 * 不管是 JPEG 还是 PNG 图片，都是一种压缩的位图图形格式。只不过 PNG 图片是无损压缩，并且支持 alpha 通道，而 JPEG 图片则是有损压缩，可以指定 0-100% 的压缩比。
 * 图片解压缩的过程其实就是将图片的二进制数据转换成像素数据的过程。
 
 从磁盘中加载一张图片，并将它显示到屏幕上，中间的主要工作流如下：
    1.假设我们使用 +imageWithContentsOfFile: 方法从磁盘中加载一张图片，这个时候的图片并没有解压缩；
    2.然后将生成的 UIImage 赋值给 UIImageView ；
    3.接着一个隐式的 CATransaction 捕获到了 UIImageView 图层树的变化；
    4.在主线程的下一个 run loop 到来时，Core Animation 提交了这个隐式的 transaction ，这个过程可能会对图片进行 copy 操作，而受图片是否字节对齐等因素的影响，这个 copy 操作可能会涉及以下部分或全部步骤：
        4.1 分配内存缓冲区用于管理文件 IO 和解压缩操作；
        4.2 将文件数据从磁盘读到内存中；
        4.3 将压缩的图片数据解码成未压缩的位图形式，这是一个非常耗时的 CPU 操作；
        4.4 最后 Core Animation 使用未压缩的位图数据渲染 UIImageView 的图层。
 
 将从磁盘加载一张图片到最终渲染到屏幕上的过程划分为三个阶段：
    - 初始化阶段：从磁盘初始化图片，生成一个未解压缩的 UIImage 对象；
    - 解压缩阶段：分别使用 YYKit 、SDWebImage 和 FLAnimatedImage 对第 1 步中得到的 UIImage 对象进行解压缩，得到一个新的解压缩后的 UIImage 对象；
    - 绘制阶段：将第 2 步中得到的 UIImage 对象绘制到屏幕上。
 
 * YYKit的解码：
 
 // 颜色空间
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 
 // alpha 的信息
 CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
 
 // 是否包含 alpha
 BOOL hasAlpha = NO;
 if (alphaInfo == kCGImageAlphaPremultipliedLast ||
     alphaInfo == kCGImageAlphaPremultipliedFirst ||
     alphaInfo == kCGImageAlphaLast ||
     alphaInfo == kCGImageAlphaFirst) {
     hasAlpha = YES;
 }
 
 // 位图的布局信息
 CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
 bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
 // 官方文档：当图片不包含 alpha 的时候使用 kCGImageAlphaNoneSkipFirst ，否则使用 kCGImageAlphaPremultipliedFirst
 // 另外，文档也提到了字节顺序应该使用 32 位的主机字节顺序 kCGBitmapByteOrder32Host
 
 # define kCGBitmapByteOrder32Host kCGBitmapByteOrder32Little：采用小端模式，数据以32位为单位。
 - 字节顺序的值应该使用的是 32 位的主机字节顺序 kCGBitmapByteOrder32Host，这样的话不管当前设备采用的是小端模式还是大端模式，字节顺序始终与其保持一致。
 - 在 32 位像素格式下，每个颜色分量使用 8 位。
 
 解压缩后的图片大小(单位Byte，占多少字节) = 图片的像素宽 * 图片的像素高 * 每个像素所占的字节数；
 每个像素所占的字节数是 4 个字节，ARGB 共 4 个颜色通道每个颜色通道占 8 位，即各占一个字节，共 4 字节。
 
 CGBitmapContextCreate(void * __nullable data, -------------- NULL
                       size_t width, ------------------------ pixelWidth
                       size_t height, ----------------------- pixelHeight
                       size_t bitsPerComponent, ------------- 8
                       size_t bytesPerRow, ------------------ 0
                       CGColorSpaceRef cg_nullable space, --- colorSpace
                       uint32_t bitmapInfo) ----------------- bitmapInfo
 
 - data ：如果不为 NULL ，那么它应该指向一块大小至少为 bytesPerRow * height 字节的内存；如果 为 NULL ，那么系统就会为我们自动分配和释放所需的内存，所以一般指定 NULL 即可；
 - width 和 height ：位图的宽度和高度，分别赋值为图片的像素宽度和像素高度即可；
 - bitsPerComponent ：像素的每个颜色分量使用的 bit 数，在 RGB 颜色空间下指定 8 即可；（ARGB，数据以32位为单位 32 = 4 * 8）
 - bytesPerRow ：位图的每一行使用的字节数，大小至少为 width * bytes per pixel 字节。有意思的是，当我们指定 0 时，系统不仅会为我们自动计算，而且还会进行 cache line alignment 的优化；
 - space ：颜色空间，一般使用 RGB 即可；
 - bitmapInfo ：位图的布局信息。
 
 * Bits per component ：一个像素中每个独立的颜色分量使用的 bit 数；---- 每个颜色分量使用 8 位
 * Bits per pixel ：一个像素使用的总 bit 数；---- ARGB为4个字节，32位
 * Bytes per row ：位图中的每一行使用的字节数。---- width * Bits per pixel，宽度 x 32
 
 */

- (void)lookSize:(UIButton *)sender {
    [JPProgressHUD show];
    
    NSString *title = [sender titleForState:UIControlStateNormal];
    CGFloat logicWidth = self.imageView.jp_width * JPScreenScale;
    NSInteger tag = sender.tag;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *imagePath = JPMainBundleResourcePath(@"Car", @"jpg");
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        
        NSInteger pngLength = UIImagePNGRepresentation(image).length;
        NSInteger jpgLength = UIImageJPEGRepresentation(image, 1.0).length;
        JPLog(@"%@ 解码前 转成png格式的大小 %zd(%@)", title, pngLength, JPFileSizeString(pngLength));
        JPLog(@"%@ 解码前 转成jpg格式的大小 %zd(%@)", title, jpgLength, JPFileSizeString(jpgLength));
        
        long long fileSize = [JPFileTool fileSize:imagePath];
        
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        NSUInteger dataLength = data.length;
        
        long long imageSize = image.size.width * image.size.height * 4;
        
        NSString *text = [NSString stringWithFormat:@"%@\n\n原图像素：%.0lf * %.0lf\n原文件大小(在磁盘中)：%lld(%@)\n原data的大小(在磁盘中)：%zd(%@)\n原图在内存中的大小(自己算的)：%lld(%@)",
                title,
                image.size.width, image.size.height,
                fileSize, JPFileSizeString(fileSize),
                dataLength, JPFileSizeString(dataLength),
                imageSize, JPFileSizeString(imageSize)];
        
        switch (tag) {
            case 2:
            {
                image = [image jp_cgResizeImageWithLogicWidth:logicWidth];
                break;
            }
            case 3:
            {
//                image = [image jp_ioResizeImageWithLogicWidth:logicWidth isPNGType:NO];
                image = [self ioResizeImageWithImageData:data imageSize:logicWidth];
                break;
            }
            case 4:
            {
                image = [image jp_uiResizeImageWithLogicWidth:logicWidth];
                break;
            }
            default:
                break;
        }
        
        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [JPProgressHUD dismiss];
                self.imageView.image = image;
                self.textView.text = @"解压缩失败！";
            });
            return;
        }
        
        @autoreleasepool {
            CGImageRef imageRef = image.CGImage;
            
            // 获取图片的原始像素数据，也就是图片解压缩后的数据
            CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
            CFDataRef rawData = CGDataProviderCopyData(dataProvider);
            NSUInteger rawDataLength = CFDataGetLength(rawData); // 获取解压缩后的大小
//            CGDataProviderRelease(dataProvider);
            CFRelease(rawData);
            
            // 自己算的大小
            CGFloat width = CGImageGetWidth(imageRef);
            CGFloat height = CGImageGetHeight(imageRef);
            // 解压缩后的图片大小(单位Byte，占多少字节) = 图片的像素宽 * 图片的像素高 * 每个像素所占的字节数
            // 每个像素所占的字节数是 4 个字节，ARGB，4个颜色通道每个颜色通道占8位，8位一个字节，共4字节
            imageSize = width * height * 4;
            
            text = [NSString stringWithFormat:@"%@\n\n解码后的像素：%.0lf * %.0lf\n解码后data的大小(在内存中)：%zd(%@)\n解码后在内存中的大小(自己算的)：%lld(%@)",
                    text,
                    width, height,
                    rawDataLength, JPFileSizeString(rawDataLength),
                    imageSize, JPFileSizeString(imageSize)];
            
            pngLength = UIImagePNGRepresentation(image).length;
            jpgLength = UIImageJPEGRepresentation(image, 1.0).length;
            JPLog(@"%@ 解码后 转成png格式的大小 %zd(%@)", title, pngLength, JPFileSizeString(pngLength));
            JPLog(@"%@ 解码后 转成jpg格式的大小 %zd(%@)", title, jpgLength, JPFileSizeString(jpgLength));
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [JPProgressHUD dismiss];
                self.imageView.image = image;
                self.textView.text = text;
            });
        }
    });
    
}

- (UIImage *)ioResizeImageWithImageData:(NSData *)imageData imageSize:(int)imageSize {
    CFStringRef optionKeys[1];
    CFTypeRef optionValues[4];
    optionKeys[0] = kCGImageSourceShouldCache;
    optionValues[0] = (CFTypeRef)kCFBooleanFalse;
    CFDictionaryRef sourceOption = CFDictionaryCreate(kCFAllocatorDefault, (const void **)optionKeys, (const void **)optionValues, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, sourceOption);
    CFRelease(sourceOption);
    if (!imageSource) {
        NSLog(@"imageSource is Null!");
        return nil;
    }
    
    CFStringRef keys[5];
    CFTypeRef values[5];
    // 设置缩略图的宽高尺寸 需要设置为CFNumber值
    // 创建缩略图等比缩放大小，会根据长宽值比较大的作为imageSize进行缩放
    keys[0] = kCGImageSourceThumbnailMaxPixelSize;
    CFNumberRef thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    values[0] = (CFTypeRef)thumbnailSize;
    // 设置是否创建缩略图，无论原图像有没有包含缩略图，默认kCFBooleanFalse
    keys[1] = kCGImageSourceCreateThumbnailFromImageAlways;
    values[1] = (CFTypeRef)kCFBooleanTrue;
    // 设置缩略图是否进行Transfrom变换
    keys[2] = kCGImageSourceCreateThumbnailWithTransform;
    values[2] = (CFTypeRef)kCFBooleanTrue;
    // 设置如果不存在缩略图则创建一个缩略图，缩略图的尺寸受开发者设置影响
    // 如果不设置尺寸极限，则为图片本身大小，默认为kCFBooleanFalse
    keys[3] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    values[3] = (CFTypeRef)kCFBooleanTrue;
    // 设置是否以解码的方式读取图片数据 默认为kCFBooleanTrue
    // 如果设置为true，在读取数据时就进行解码，如果为false，则在渲染时才进行解码
    keys[4] = kCGImageSourceShouldCacheImmediately;
    values[4] = (CFTypeRef)kCFBooleanTrue;
    /*
     * 还有另外这两个：
     * kCGImageSourceTypeIdentifierHint
        - 设置一个预期的图片文件格式，需要设置为字符串类型的值
     * kCGImageSourceShouldAllowFloa
        - 返回CGImage对象时是否允许使用浮点值，默认为kCFBooleanFalse
     */
    
    CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageRef thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    UIImage *resultImg = [UIImage imageWithCGImage:thumbnailImage];

    CFRelease(thumbnailSize);
    CFRelease(options);
    CFRelease(imageSource);
    if (thumbnailImage) CFRelease(thumbnailImage);

    return resultImg;
}

@end
