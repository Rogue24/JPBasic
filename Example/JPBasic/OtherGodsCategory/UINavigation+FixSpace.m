//
//  UINavigation+FixSpace.m
//  Infinitee2.0
//
//  Created by 周健平 on 2017/10/13.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "UINavigation+FixSpace.h"
#import "NSObject+SXRuntime.h"

#define defaultMargin 20.0

@implementation UINavigationBar (FixSpace)

//+ (void)load {
//    if (!IOS11_OR_LATER) return;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
////        [self swizzleInstanceMethodWithOriginSel:@selector(layoutSubviews)
////                                     swizzledSel:@selector(jp_layoutSubviews)];
//    });
//}

- (void)jp_layoutSubviews {
    [self jp_layoutSubviews];
    
//    self.layoutMargins = UIEdgeInsetsZero;
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass(subview.class) containsString:@"ContentView"]) {
            subview.layoutMargins = UIEdgeInsetsMake(0, 15, 0, 15);
//            subview.layoutMargins = UIEdgeInsetsZero;
//            subview.x = jp_leftFixSpace;
//            subview.width = SCREEN_WIDTH - jp_leftFixSpace - jp_rightFixSpace;
//            subview.backgroundColor = [UIColor greenColor];
//            [self layoutIfNeeded];
            
//            JPLog(@"11 %@", NSStringFromUIEdgeInsets(subview.layoutMargins));
            
            break;
        }
    }
    
//    JPLog(@"22 %@", NSStringFromUIEdgeInsets(self.layoutMargins));
    
}

@end

@implementation UINavigationItem (FixSpace)

+ (void)load {
    if (@available(iOS 11.0, *)) {
        static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
        //        [self swizzleInstanceMethodWithOriginSel:@selector(setLeftBarButtonItem:)
        //                                     swizzledSel:@selector(jp_setLeftBarButtonItem:)];
                
        //        [self swizzleInstanceMethodWithOriginSel:@selector(setRightBarButtonItem:)
        //                                     swizzledSel:@selector(jp_setRightBarButtonItem:)];
                
                [self swizzleInstanceMethodWithOriginSel:@selector(setLeftBarButtonItems:)
                                             swizzledSel:@selector(jp_setLeftBarButtonItems:)];
                [self swizzleInstanceMethodWithOriginSel:@selector(setRightBarButtonItems:)
                                             swizzledSel:@selector(jp_setRightBarButtonItems:)];
            });
    }
    
}


//- (void)jp_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
//    jp_leftFixSpace = defaultMargin;
//    [self jp_setLeftBarButtonItem:leftBarButtonItem];
//}
//
//- (void)jp_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
//    jp_rightFixSpace = defaultMargin;
//    [self jp_setRightBarButtonItem:rightBarButtonItem];
//}

- (void)jp_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    NSMutableArray *barButtonItems = [NSMutableArray array];
    for (UIBarButtonItem *item in leftBarButtonItems) {
        if (!item.customView) {
            UIBarButtonSystemItem systemItem = [[item valueForKey:@"systemItem"] integerValue];
            if (systemItem == UIBarButtonSystemItemFixedSpace) {
                continue;
            }
        }
        [barButtonItems addObject:item];
    }
    [self jp_setLeftBarButtonItems:barButtonItems];
}

- (void)jp_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems{
    NSMutableArray *barButtonItems = [NSMutableArray array];
    for (UIBarButtonItem *item in rightBarButtonItems) {
        if (!item.customView) {
            UIBarButtonSystemItem systemItem = [[item valueForKey:@"systemItem"] integerValue];
            if (systemItem == UIBarButtonSystemItemFixedSpace) {
                continue;
            }
        }
        [barButtonItems addObject:item];
    }
    [self jp_setRightBarButtonItems:rightBarButtonItems];
}

@end
