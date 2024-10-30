//
//  JPScrollViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/13.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//
//  结论：zoomRect是相对于scrollView的contentSize的范围内！<<宽高越小缩放越大>>

#import "JPScrollViewController.h"
#import "NSString+JPExtension.h"

@interface JPScrollViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UILabel *messageLabel;
@property (nonatomic, assign) CGRect zoomRect;
@property (nonatomic, strong) UIView *zoomView;
@property (nonatomic, weak) UISlider *slider;
@end

@implementation JPScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *image = [UIImage imageWithContentsOfFile:JPMainBundleResourcePath(@"Car", @"jpg")];
    self.imageView.clipsToBounds = NO;
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.jp_size = CGSizeMake(JPPortraitScreenWidth - 20, (JPPortraitScreenWidth - 20) * (image.size.height / image.size.width));
    
    self.zoomView = [[UIView alloc] init];
    self.zoomView.backgroundColor = JPRandomColor;
    self.zoomView.alpha = 0.7;
    [self.imageView addSubview:self.zoomView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:JPScreenBounds];
    scrollView.backgroundColor = JPRandomColor;
    scrollView.clipsToBounds = NO;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = MAXFLOAT;
    scrollView.contentInset = UIEdgeInsetsMake(JPHalfOfDiff(JPPortraitScreenHeight, self.imageView.jp_height), 10, JPHalfOfDiff(JPPortraitScreenHeight, self.imageView.jp_height), 10);
    scrollView.delegate = self;
    [scrollView addSubview:self.imageView];
    scrollView.contentSize = self.imageView.jp_size;
    [self jp_contentInsetAdjustmentNever:scrollView];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = @"只需要输入xyw，h按比例自动算，以空格相隔。如：10 20 300";
    textField.backgroundColor = JPRandomColor;
    [self.view addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.view).offset(JPNavTopMargin + 20);
        make.height.equalTo(@30);
    }];
    self.textField = textField;
    
    UIButton *btn1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.backgroundColor = JPRandomColor;
        [btn setTitle:@"变吧" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changZoom) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:btn1];
    
    UIButton *btn2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.backgroundColor = JPRandomColor;
        [btn setTitle:@"还原" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(recory) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:btn2];
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).offset(10);
        make.left.equalTo(@10);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(btn1);
        make.left.equalTo(btn1.mas_right).offset(10);
        make.size.equalTo(btn1);
    }];
    
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = -1;
    slider.maximumValue = 1;
    slider.value = 0;
    [slider addTarget:self action:@selector(rotation:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    self.slider = slider;
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btn1.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
    }];
    
    UILabel *messageLabel = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textColor = UIColor.blackColor;
        aLabel.backgroundColor = JPRGBAColor(255, 255, 255, 0.7);
        aLabel.numberOfLines = 0;
        aLabel;
    });
    [self.view addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-(JPDiffTabBarH));
        make.height.equalTo(@350);
    }];
    self.messageLabel = messageLabel;
    
    [scrollView addObserver:self forKeyPath:JPKeyPath(scrollView, zoomScale) options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:JPKeyPath(scrollView, contentOffset) options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:JPKeyPath(scrollView, contentInset) options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateMessage];
}

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:JPKeyPath(self.scrollView, zoomScale)];
    [self.scrollView removeObserver:self forKeyPath:JPKeyPath(self.scrollView, contentOffset)];
    [self.scrollView removeObserver:self forKeyPath:JPKeyPath(self.scrollView, contentInset)];
}

- (void)updateMessage {
    NSMutableString *message = [NSMutableString string];
    [message appendString:@" ImageView"];
    [message appendString:@"\n"];
    [message appendString:[NSString stringWithFormat:@" whScale = %.2lf", self.imageView.image.size.width / self.imageView.image.size.height]];
    [message appendString:@"\n"];
    [message appendString:[NSString stringWithFormat:@" scale = %.2lf, angle = %.2lf", self.imageView.jp_scaleX, self.imageView.jp_angle]];
    [message appendString:@"\n"];
    [message appendString:[NSString stringWithFormat:@" bounds: x = %.2lf, y = %.2lf, w = %.2lf, h = %.2lf", self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, self.imageView.bounds.size.width, self.imageView.bounds.size.height]];
    [message appendString:@"\n"];
    [message appendString:[NSString stringWithFormat:@" frame: x = %.2lf, y = %.2lf, w = %.2lf, h = %.2lf", self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height]];
    [message appendString:@"\n"];
    
    [message appendString:@"\n"];
    
    [message appendString:@" ScrollView"];
    [message appendString:@"\n"];
    [message appendString:[NSString stringWithFormat:@" zoomScale = %.2lf", self.scrollView.zoomScale]];
    [message appendString:@"\n"];
    [message appendString:[NSString stringWithFormat:@" contentSize: w = %.2lf, h = %.2lf", self.scrollView.contentSize.width, self.scrollView.contentSize.height]];
    [message appendString:@"\n"];
    [message appendString:[NSString stringWithFormat:@" contentOffset: x = %.2lf, y = %.2lf", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y]];
    [message appendString:@"\n"];
    [message appendString:[NSString stringWithFormat:@" contentInset: t = %.2lf, l = %.2lf, b = %.2lf, r = %.2lf", self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right]];
    [message appendString:@"\n"];
    
    [message appendString:@"\n"];
    
    [message appendString:[NSString stringWithFormat:@" zoomRect: x = %.2lf, y = %.2lf, w = %.2lf, h = %.2lf", self.zoomRect.origin.x, self.zoomRect.origin.y, self.zoomRect.size.width, self.zoomRect.size.height]];
    [message appendString:@"\n"];
    CGRect convertRect = [self.imageView convertRect:self.zoomRect fromView:self.scrollView];
    [message appendString:[NSString stringWithFormat:@" convertRect: x = %.2lf, y = %.2lf, w = %.2lf, h = %.2lf", convertRect.origin.x, convertRect.origin.y, convertRect.size.width, convertRect.size.height]];
    
    self.messageLabel.text = message;
}

- (void)changZoom {
    [self.view endEditing:YES];
    if (![self.textField.text jp_isNotEmpty]) {
        JPLog(@"去你的");
        return;
    }
    
    NSArray *array = [self.textField.text componentsSeparatedByString:@" "];
    if (array.count != 3) {
        JPLog(@"去你的");
        return;
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 0;
    for (NSInteger i = 0; i < 3; i++) {
        CGFloat v = [array[i] doubleValue];
        switch (i) {
            case 0:
                x = v;
                break;
            case 1:
                y = v;
                break;
            case 2:
                w = v;
                break;
            default:
                break;
        }
    }
    CGFloat h = w * (self.imageView.image.size.height / self.imageView.image.size.width);
    self.zoomRect = CGRectMake(x, y, w, h);
    self.zoomView.frame = self.zoomRect;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView zoomToRect:self.zoomRect animated:YES];
    });
}

- (void)recory {
    [self.view endEditing:YES];
    self.slider.value = 0;
    self.zoomRect = CGRectZero;
    self.zoomView.frame = self.zoomRect;
    self.imageView.transform = CGAffineTransformIdentity;
    [self.scrollView setZoomScale:1 animated:YES];
}

- (void)rotation:(UISlider *)slider {
    [self.view endEditing:YES];
    
    CGFloat value = slider.value;
    
    self.imageView.transform = CGAffineTransformMakeRotation(value * M_PI_4);
    [self updateMessage];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    JPLog(@"%@: %@", keyPath, change[NSKeyValueChangeNewKey]);
    [self updateMessage];
}

#pragma mark - <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    
}

@end
