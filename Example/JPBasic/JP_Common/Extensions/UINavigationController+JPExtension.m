//
//  UINavigationController+JPExtension.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/21.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "UINavigationController+JPExtension.h"
#import "NSObject+JPExtension.h"
#import "NSObject+SXRuntime.h"

@implementation UINavigationController (JPExtension)

//+ (void)load {
////    [self jp_lookMethods];
////    [self jp_lookIvars];
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        SEL originalSelector1 = NSSelectorFromString(@"_updateInteractiveTransition:");
//        [self swizzleInstanceMethodWithOriginSel:originalSelector1
//                                     swizzledSel:@selector(jp_updateInteractiveTransition:)];
//        
//        SEL originalSelector2 = NSSelectorFromString(@"_finishInteractiveTransition:transitionContext:");
//        [self swizzleInstanceMethodWithOriginSel:originalSelector2
//                                     swizzledSel:@selector(jp_finishInteractiveTransition:transitionContext:)];
//        
//        SEL originalSelector3 = NSSelectorFromString(@"_cancelInteractiveTransition:transitionContext:");
//        [self swizzleInstanceMethodWithOriginSel:originalSelector3
//                                     swizzledSel:@selector(jp_cancelInteractiveTransition:transitionContext:)];
//        
//        SEL originalSelector4 = @selector(popViewControllerAnimated:);
//        [self swizzleInstanceMethodWithOriginSel:originalSelector4
//                                     swizzledSel:@selector(jp_popViewControllerAnimated:)];
//    });
//}

//+ (void)initialize {
//
//}

static UIViewController *jp_popVC_ = nil;
- (UIViewController *)jp_popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = [self jp_popViewControllerAnimated:animated];
    
    if (self.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan) {
         jp_popVC_ = vc;
    } else {
        UIView *snapshotView = [vc.view snapshotViewAfterScreenUpdates:NO];
        [self.view insertSubview:snapshotView belowSubview:self.navigationBar];

        vc.view.hidden = YES;

        [UIView animateWithDuration:1.0 delay:0 options:kNilOptions animations:^{
           snapshotView.transform = CGAffineTransformMakeScale(0.5, 0.5);
           snapshotView.alpha = 0;
        } completion:^(BOOL finished) {
           [snapshotView removeFromSuperview];
        }];
    }
    
    
    return vc;
}

- (void)jp_updateInteractiveTransition:(CGFloat)percent {
    [self jp_updateInteractiveTransition:percent];
//    JPLog(@"update percent = %.2lf", percent);
    
    UIView *superView = jp_popVC_.view.superview.superview;
    // <UIView: 0x10b603110; frame = (414 0; 414 896); animations = { position=<CABasicAnimation: 0x2838c59c0>; }; layer = <CALayer: 0x2838c0080>>
    
    JPLog(@"update percent = %.2lf %@", percent, superView.layer.animationKeys);
    
}

- (void)jp_finishInteractiveTransition:(CGFloat)percent transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    [self jp_finishInteractiveTransition:percent transitionContext:transitionContext];
    JPLog(@"finis percent = %.2lf", percent);
    
    UIView *containerView = [transitionContext containerView];
    JPLog(@"%@", containerView.subviews);
    
    UIView *superVview = jp_popVC_.view.superview.superview;
    CGPoint position = superVview.layer.presentationLayer.position;
    
//    [superVview removeFromSuperview];
//    [superVview.layer removeAllAnimations];
//    superVview.layer.position = position;
//
//    [JPKeyWindow addSubview:superVview];
//
//    [UIView animateWithDuration:1.0 delay:3.0 options:kNilOptions animations:^{
//        superVview.transform = CGAffineTransformMakeScale(0.5, 0.5);
//        superVview.alpha = 0;
//    } completion:^(BOOL finished) {
//        [superVview removeFromSuperview];
//    }];
    
//    [jp_popVC_.view removeFromSuperview];
//    jp_popVC_.view.layer.position = position;
//    [JPKeyWindow addSubview:jp_popVC_.view];
    
    UIView *snapshotView = [jp_popVC_.view snapshotViewAfterScreenUpdates:NO];
    snapshotView.layer.position = position;
    [self.view insertSubview:snapshotView belowSubview:self.navigationBar];

    jp_popVC_.view.hidden = YES;

    [UIView animateWithDuration:1.0 delay:0 options:kNilOptions animations:^{
        snapshotView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        snapshotView.alpha = 0;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
    }];
}

- (void)jp_cancelInteractiveTransition:(CGFloat)percent transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    [self jp_cancelInteractiveTransition:percent transitionContext:transitionContext];
    JPLog(@"cancel percent = %.2lf", percent);
}

@end
