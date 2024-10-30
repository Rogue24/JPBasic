//
//  WTVRedPackageRainRuleView.m
//  WoTV
//
//  Created by 周健平 on 2018/2/11.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import "WTVRedPackageRainRuleView.h"
#import <WebKit/WebKit.h>
#import "WTVRedPackageRainManager.h"
#import "UIView+JPExtension.h"

@interface WTVRedPackageRainRuleView () <WKNavigationDelegate>
@property (nonatomic ,strong) WKWebView *webView;
@property (nonatomic, weak) UIActivityIndicatorView *jvhua;
@end

@implementation WTVRedPackageRainRuleView

+ (void)showRuleViewOnView:(UIView *)onView {
    WTVRedPackageRainRuleView *ruleView = [[self alloc] init];
    [onView addSubview:ruleView];
    
    ruleView.transform = CGAffineTransformMakeScale(0.85, 0.85);
    
    ruleView.layer.jp_positionY = JPPortraitScreenHeight + JPPortraitScreenHeight * 0.5;
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.springSpeed = 10;
    anim.springBounciness = 5;
    anim.toValue = @(JPPortraitScreenHeight * 0.5);
    [ruleView.layer pop_addAnimation:anim forKey:@"PositionY"];
    
//    CGRect frame = ruleView.frame;
//    frame.origin.y = (SCREENH - ruleView.jp_height) * 0.5;
//
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//    anim.springSpeed = 10;
//    anim.springBounciness = 5;
//    anim.toValue = @(frame);
//    [ruleView pop_addAnimation:anim forKey:@"Frame"];
}

- (void)dealloc {
    NSLog(@"死了没");
}

- (instancetype)init {
    if (self = [super init]) {
        
        CGFloat btnH = 44;
        CGFloat cornerRadius = 20;
        
//        CGFloat w = SCREENW * 0.7;
//        CGFloat h = SCREENH * 0.7 + btnH;
//        CGFloat x = (SCREENW - w) * 0.5;
//        CGFloat y = SCREENH;
//        self.frame = CGRectMake(x, y, w, h);
        
        self.frame = [UIScreen mainScreen].bounds;
        
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius].CGPath;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.3;
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.layer.cornerRadius = cornerRadius;
        contentView.layer.masksToBounds = YES;
        [self addSubview:contentView];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        // 设置是否将网页内容全部加载到内存后再渲染
        configuration.suppressesIncrementalRendering = NO;
        // 设置HTML5视频是否允许网页播放 设置为NO则会使用本地播放器
        configuration.allowsInlineMediaPlayback = NO;
        if (@available(iOS 9.0, *)) {
            // 设置是否允许ariPlay播放
            configuration.allowsAirPlayForMediaPlayback = YES;
            // 设置视频是否需要用户手动播放  设置为NO则会允许自动播放
            configuration.requiresUserActionForMediaPlayback = NO;
            // 设置是否允许画中画技术 在特定设备上有效
            configuration.allowsPictureInPictureMediaPlayback = YES;
        }
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, contentView.jp_width, contentView.jp_height - btnH) configuration:configuration];
        webView.navigationDelegate = self;
        [contentView addSubview:webView];
        self.webView = webView;
        
        NSURL *url = [NSURL URLWithString:RuleURLStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        
        UIActivityIndicatorView *jvhua = [[UIActivityIndicatorView alloc] init];
        jvhua.jp_centerX = contentView.jp_width * 0.5;
        jvhua.jp_centerY = contentView.jp_height * 0.5;
        jvhua.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        jvhua.hidesWhenStopped = YES;
        [contentView addSubview:jvhua];
        self.jvhua = jvhua;
        
        UIButton *closeBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitle:@"知道了" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(0, webView.jp_height, contentView.jp_width, btnH);
            CALayer *line = [CALayer layer];
            line.frame = CGRectMake(0, 0, btn.jp_width, 0.5);
            line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
            [btn.layer addSublayer:line];
            btn;
        });
        [contentView addSubview:closeBtn];
        
        
    }
    return self;
}

- (void)close {
    
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
//    anim.springSpeed = 10;
//    anim.springBounciness = 5;
//    anim.toValue = @(SCREENH * 0.5);
//    [ruleView pop_addAnimation:anim forKey:@"PositionY"];
    [self.layer jp_addPOPBasicAnimationWithPropertyNamed:kPOPLayerPositionY toValue:@(JPPortraitScreenHeight * 1.5) duration:0.2 completionBlock:^(POPAnimation *anim, BOOL finished) {
        [self removeFromSuperview];
    }];
    
//    CGRect frame = self.frame;
//    frame.origin.y = SCREENH;
//    [self jp_addPOPBasicAnimationWithPpropertyNamed:kPOPViewFrame beginTime:0 duration:0.2 toValue:@(frame) key:@"Frame" completionBlock:^(POPAnimation *anim, BOOL finished) {
//        [self removeFromSuperview];
//    }];
}

#pragma mark - WKNavigationDelegate

// 页面加载启动时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.jvhua startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.jvhua stopAnimating];
}

@end
