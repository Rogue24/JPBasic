//
//  JPScrollViewDelegateController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2021/4/13.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPScrollViewDelegateController.h"

@interface JPScrollViewDelegateController ()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@end


@implementation JPScrollViewDelegateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    UIImage *image = [UIImage imageWithContentsOfFile:JPMainBundleResourcePath(@"Joker", @"jpg")];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image];
    imageView1.jp_size = CGSizeMake(JPPortraitScreenWidth, JPPortraitScreenWidth * (image.size.height / image.size.width));
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image];
    imageView2.frame = CGRectMake(0, imageView1.jp_height, imageView1.jp_width, imageView1.jp_height);
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithImage:image];
    imageView3.frame = CGRectMake(0, imageView1.jp_height * 2, imageView1.jp_width, imageView1.jp_height);
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, JPPortraitScreenWidth, JPPortraitScreenHeight)];
    scrollView.backgroundColor = JPRandomColor;
    scrollView.contentInset = UIEdgeInsetsMake(JPStatusBarH, 0, JPDiffTabBarH, 0);
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    [scrollView addSubview:imageView1];
    [scrollView addSubview:imageView2];
    [scrollView addSubview:imageView3];
    scrollView.contentSize = CGSizeMake(0, imageView1.jp_height * 3);
    [self jp_contentInsetAdjustmentNever:scrollView];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIButton *btn1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.backgroundColor = JPRandomColor;
        [btn setTitle:@"非动画" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(feidonghua) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:btn1];
    
    UIButton *btn2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.backgroundColor = JPRandomColor;
        [btn setTitle:@"动画" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(donghua) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:btn2];
    
    UIButton *btn3 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.backgroundColor = JPRandomColor;
        [btn setTitle:@"系统动画" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(xitongdonghua) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:btn3];
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@150);
        make.left.equalTo(@10);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(btn1);
        make.left.equalTo(btn1.mas_right).offset(10);
        make.size.equalTo(btn1);
    }];
    
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(btn1);
        make.left.equalTo(btn2.mas_right).offset(10);
        make.size.equalTo(btn1);
    }];
}

- (void)feidonghua {
    //【会触发 scrollViewDidScroll 一次】
    // 不会触发 scrollViewDidEndScrollingAnimation
    self.scrollView.contentOffset = CGPointMake(0, 100);
//    [self.scrollView setContentOffset:CGPointMake(0, 100) animated:NO]; // 这种写法等同上面
}

- (void)donghua {
    //【会不断触发 scrollViewDidScroll 多次】
    // 会触发 scrollViewDidEndScrollingAnimation
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)xitongdonghua {
    // 这种不会触发 scrollViewDidEndScrollingAnimation
    //【只会触发 scrollViewDidScroll，并且只会触发一次】，偏移量为最终值
    [UIView animateWithDuration:3 animations:^{
//        self.scrollView.contentOffset = CGPointMake(0, 100);
        [self.scrollView setContentOffset:CGPointMake(0, 100) animated:NO];
    }];
    
    // 这种 [self.scrollView setContentOffset:CGPointMake(0, 100) animated:YES] 且 animated 要为YES才会触发 scrollViewDidEndScrollingAnimation
    // 即使包裹在系统动画内也不会影响默认的动画时长（0.25s左右）和动画曲线
    // 其实跟没有包裹在系统动画内的效果一样，也是【会不断触发 scrollViewDidScroll 多次】
//    [UIView animateWithDuration:3 animations:^{
//        [self.scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
//    }];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    JPLog(@"scrollViewWillBeginDragging %.02lf", scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    JPLog(@"scrollViewDidScroll %.02lf", scrollView.contentOffset.y);
    
    //【注意】：千万不要在scrollViewDidScroll中这样设置偏移量（递增/递减）！会不断递归直至崩溃！！！
//    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y + 1);
    // 可以在scrollViewDidScroll中设置一个固定的偏移量，这样只会再触发一次，因为再次设置相同的偏移量，没有差异值scrollView是不会触发滚动的（也就是协议方法都不会触发）。
//    self.scrollView.contentOffset = CGPointMake(0, 100);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    JPLog(@"scrollViewDidEndDragging %.02lf, willDecelerate %d", scrollView.contentOffset.y, decelerate);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    JPLog(@"scrollViewWillBeginDecelerating %.02lf", scrollView.contentOffset.y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    JPLog(@"scrollViewDidEndDecelerating %.02lf", scrollView.contentOffset.y);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    JPLog(@"scrollViewDidEndScrollingAnimation %.02lf", scrollView.contentOffset.y);
}

@end
