//
//  JPMasonryTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2019/12/10.
//  Copyright © 2019 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPMasonryTestViewController.h"

@interface JPMasonryTestViewController ()
@property (nonatomic, weak) UIView *view1;
@property (nonatomic, weak) UILabel *label1;
@property (nonatomic, weak) UILabel *label2;
@property (nonatomic, weak) UIView *view2;
@property (nonatomic, weak) UILabel *label3;
@property (nonatomic, weak) UILabel *label4;

@property (nonatomic, weak) UIView *view3;
@property (nonatomic, weak) UILabel *label5;
@property (nonatomic, weak) UILabel *label6;
@property (nonatomic, strong) MASConstraint *label5Constraint1;
@property (nonatomic, strong) MASConstraint *label5Constraint2;
@property (nonatomic, strong) MASConstraint *label6Constraint;

@property (nonatomic, weak) UIView *view4;
@end

@implementation JPMasonryTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    UISwitch *uiSwitch = [[UISwitch alloc] init];
    uiSwitch.on = YES;
    [uiSwitch addTarget:self action:@selector(switchDidChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:uiSwitch];
    [uiSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.top.equalTo(@100);
    }];
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = JPRandomColor;
    [self.view addSubview:view1];
    self.view1 = view1;
    
    UILabel *label1 = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.backgroundColor = JPRandomColor;
        aLabel.textColor = JPRandomColor;
        aLabel.text = @"周健平好特么帅气";
        aLabel;
    });
    [view1 addSubview:label1];
    
    UILabel *label2 = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.backgroundColor = JPRandomColor;
        aLabel.textColor = JPRandomColor;
        aLabel.text = @"周健平简直帅到天崩地裂";
        aLabel;
    });
    [view1 addSubview:label2];
    
    // setContentCompressionResistancePriority：优先级越高，越不会被压缩
    [label1 setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [label2 setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(view1);
    }];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view1);
        make.left.equalTo(label1.mas_right).offset(10);
    }];
    
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@250);
    }];
    
    self.label1 = label1;
    self.label2 = label2;
    
    
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = JPRandomColor;
    [self.view addSubview:view2];
    self.view2 = view2;
    
    UILabel *label3 = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.backgroundColor = JPRandomColor;
        aLabel.textColor = JPRandomColor;
        aLabel.text = @"周健平";
        aLabel;
    });
    [view2 addSubview:label3];
        
    UILabel *label4 = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.backgroundColor = JPRandomColor;
        aLabel.textColor = JPRandomColor;
        aLabel.text = @"帅";
        aLabel;
    });
    [view2 addSubview:label4];
    
    // setContentHuggingPriority：优先级越高，越不会被拉伸
    [label3 setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [label4 setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(view2);
    }];
    
    [label4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view2);
        make.left.equalTo(label3.mas_right).offset(10);
    }];
    
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_bottom).offset(20);
        make.left.right.equalTo(view1);
    }];
    
    self.label3 = label3;
    self.label4 = label4;
    
    
    
    
    UIView *view3 = [[UIView alloc] init];
    view3.backgroundColor = JPRandomColor;
    [self.view addSubview:view3];
    self.view3 = view3;
    
    UILabel *label5 = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.backgroundColor = JPRandomColor;
        aLabel.textColor = JPRandomColor;
        aLabel.text = @"周健平";
        aLabel;
    });
    [view3 addSubview:label5];
    
    UILabel *label6 = ({
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.backgroundColor = JPRandomColor;
        aLabel.textColor = JPRandomColor;
        aLabel.text = @"周健平";
        aLabel;
    });
    [view3 addSubview:label6];
    
    [label5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view3);
        self.label5Constraint1 = make.left.equalTo(view3).offset(20);
        self.label5Constraint2 = make.right.equalTo(view3).offset(-20);
    }];
    [self.label5Constraint2 deactivate];
    
    [label6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label5.mas_bottom);
        make.bottom.equalTo(view3);
        self.label6Constraint = make.right.equalTo(view3).offset(-20);
    }];
    
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view2.mas_bottom).offset(20);
        make.left.right.equalTo(view1);
    }];
    
    self.label5 = label5;
    self.label6 = label6;
    
//    UIView *view4 = [[UIView alloc] init];
//    view4.backgroundColor = JPRandomColor;
//    [self.view addSubview:view4];
//    [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.equalTo(@(CGSizeMake(200, 100)));
//        make.bottom.equalTo(self.view).offset(-100);
//
////        make.left.equalTo(self.view).offset(50);
//
//        make.left.equalTo(self.view).offset(50).priorityHigh();
//        make.right.equalTo(self.view).offset(-50).priorityMedium();
//    }];
//    self.view4 = view4;
}


- (void)switchDidChanged:(UISwitch *)sender {
    NSLog(@"????? ---- %d", sender.isOn);
    
//    [self.view4 mas_updateConstraints:^(MASConstraintMaker *make) {
//        if (sender.isOn) {
//            make.left.equalTo(self.view).offset(50);
//        } else {
//            make.left.equalTo(self.view).offset(150);
//        }
//    }];
    
//    [self.view4 mas_updateConstraints:^(MASConstraintMaker *make) {
//       if (sender.isOn) {
//           make.left.equalTo(self.view).offset(50).priorityHigh();
//       } else {
//           make.left.equalTo(self.view).offset(50).priorityLow();
//       }
//    }];
//
//
//    return;
    
    // ----------------- Compression和Hugging -----------------
    
    // setContentCompressionResistancePriority：优先级越高，越不会被压缩
    [self.label1 setContentCompressionResistancePriority:(sender.isOn ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow) forAxis:UILayoutConstraintAxisHorizontal];
    [self.label2 setContentCompressionResistancePriority:(sender.isOn ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh) forAxis:UILayoutConstraintAxisHorizontal];

    // setContentHuggingPriority：优先级越高，越不会被拉伸
    [self.label3 setContentHuggingPriority:(sender.isOn ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow) forAxis:UILayoutConstraintAxisHorizontal];
    [self.label4 setContentHuggingPriority:(sender.isOn ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh) forAxis:UILayoutConstraintAxisHorizontal];

    
    // ----------------- activate和deactivate -----------------
    
    if (sender.on) {
        [self.label5Constraint1 activate];
        [self.label5Constraint2 deactivate];
        
        self.label6Constraint.offset(-20);
    } else {
        [self.label5Constraint1 deactivate];
        [self.label5Constraint2 activate];
        
        self.label6Constraint.offset(-150);
    }
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view1 layoutIfNeeded];
        [self.view2 layoutIfNeeded];
        [self.view3 layoutIfNeeded];
    }];
}

@end
