//
//  JPNotiTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2019/12/19.
//  Copyright © 2019 zhoujianping24@hotmail.com. All rights reserved.
//
// 【发出通知，接收的任务会在发出通知的线程执行，并且发出通知的线程会等待任务执行完后继续，因为是同一线程】

#import "JPNotiTestViewController.h"

//#define SDNewATDecodeFormat  @"[s[type:1[,]Mention:%u]e]"
//#define SDNewATAllDecodeString  @"[s[type:2[,]text:所有人]e]"
//
//#define SDNewATDecodeRegular @"\\[s\\[type:1\\[,\\]Mention:[\\d{1,}]+\\]e\\]"
//#define SDNewATAllDecodeRegular @"\\[s\\[type:2\\[,\\]text:所有人\\]e\\]"
//
//#define SDV2DecodeRegular @"\\[s\\[.*?\\]e\\]"

//[s[type:3[,]text:替换文本1]e]

@interface JPNotiTestViewController ()

@end

@implementation JPNotiTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = JPRandomColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(abc) name:@"aaaa" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)abc {
    JPLog(@"begin ---- %@", [NSThread currentThread]);
    sleep(3);
    JPLog(@"end ---- %@", [NSThread currentThread]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JPLog(@"post begin ---- %@", [NSThread currentThread]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"aaaa" object:nil userInfo:nil];
        JPLog(@"post end ---- %@", [NSThread currentThread]);
    });
    
//    NSString *str1 = [NSString stringWithFormat:SDNewATDecodeFormat, 123];
//    NSString *str2 = [NSString stringWithFormat:SDNewATDecodeFormat, 456];
//    NSString *str3 = [NSString stringWithFormat:SDNewATDecodeFormat, 789];
//
//    NSString *str = [NSString stringWithFormat:@"我 %@ 叼 %@ 你 %@ 妈 %@", str1, str2, str3, SDNewATAllDecodeString];
//
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:SDNewATDecodeRegular options:NSRegularExpressionCaseInsensitive error:nil];
//    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, [str length])];
//    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *containStr = [str substringWithRange:obj.range];
//        JPLog(@"containStr1 --- %@", containStr);
//    }];
//
//    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:SDNewATAllDecodeRegular options:NSRegularExpressionCaseInsensitive error:nil];
//    NSArray<NSTextCheckingResult *> *matches2 = [regex2 matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, [str length])];
//    [matches2 enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *containStr = [str substringWithRange:obj.range];
//        JPLog(@"containStr2 --- %@", containStr);
//    }];
//
//    NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:SDNewATDecodeRegular options:NSRegularExpressionCaseInsensitive error:nil];
//    NSArray<NSTextCheckingResult *> *matches3 = [regex3 matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, [str length])];
//    [matches3 enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *containStr = [str substringWithRange:obj.range];
//        JPLog(@"containStr3 --- %@", containStr);
//    }];
    
}

@end
