//
//  JPTextTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2019/11/27.
//  Copyright © 2019 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPTextTestViewController.h"
#import "JPConstant.h"
#import "JPMacro.h"
#import "UIColor+JPExtension.h"
#import "JPTextField.h"
#import "JPTextView.h"

@interface JPTextTestViewController ()
@property (nonatomic, strong) JPTextField *textField;
@property (nonatomic, strong) JPTextView *textView;
@end

@implementation JPTextTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    UIButton *closeBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont systemFontOfSize:29];
        [btn setTitle:@"退出" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = JPRandomColor;
        [btn sizeToFit];
        btn;
    });
    [self.view addSubview:closeBtn];
    
    self.textField = [[JPTextField alloc] initWithFrame:CGRectMake(20, 100, 200, 80)];
    self.textField.backgroundColor = JPRandomColor;
    self.textField.textColor = JPRandomColor;
    self.textField.textDidChange = ^(JPTextField *textField, BOOL isLenovo) {
        JPLog(@"textField --- %@ --- %@", isLenovo ? @"联想" : @"实际", textField.text);
    };
    [self.view addSubview:self.textField];
    
    self.textView = [[JPTextView alloc] initWithFrame:CGRectMake(20, 200, 200, 200)];
    self.textView.backgroundColor = JPRandomColor;
    self.textView.textColor = JPRandomColor;
    self.textView.textDidChange = ^(JPTextView *textView, BOOL isLenovo) {
        JPLog(@"textView --- %@ --- %@", isLenovo ? @"联想" : @"实际", textView.text);
    };
    [self.view addSubview:self.textView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.textField.text = @"123";
    self.textView.text = @"456";
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    JPLog(@"死的好惨");
}

@end
