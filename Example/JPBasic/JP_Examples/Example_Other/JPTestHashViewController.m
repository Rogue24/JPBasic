//
//  JPTestHashViewController.m
//  JPBasic_Example
//
//  Created by aa on 2021/6/2.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPTestHashViewController.h"

@interface JPPerson: NSObject
@property (nonatomic, assign) NSInteger a;
@property (nonatomic, assign) NSInteger b;
@end
@implementation JPPerson
- (NSUInteger)hash {
    NSUInteger hash = [super hash];
    JPLog(@"JPPerson hash %zd --- self: %p", hash, self);
    return hash;
}
- (BOOL)isEqual:(id)object {
    if (self == object) {
        JPLog(@"JPPerson isEqual YES --- self: %p, other: %p", self, object);
        return YES;
    }

    if (![object isKindOfClass:[JPPerson class]]) {
        JPLog(@"JPPerson isEqual NO --- self: %p, other: %p", self, object);
        return NO;
    }

    JPPerson *other = (JPPerson *)object;
    BOOL isEq = self.a == other.a && self.b == other.b;
    JPLog(@"JPPerson isEqual %@ --- self: %p, other: %p", isEq ? @"YES" : @"NO", self, object);
    return isEq;
}
- (void)dealloc {
    JPLog(@"JPPerson 死了 --- self: %p", self);
}
@end

@interface JPDog: NSObject
@property (nonatomic, assign) NSInteger a;
@property (nonatomic, assign) NSInteger b;
@end
@implementation JPDog
- (NSUInteger)hash {
    NSUInteger hash = [@(self.a) hash] ^ [@(self.b) hash];
    JPLog(@"JPDog hash %zd --- self: %p", hash, self);
    return hash;
}
- (BOOL)isEqual:(id)object {
    if (self == object) {
        JPLog(@"JPDog isEqual YES --- self: %p, other: %p", self, object);
        return YES;
    }
    
    if (![object isKindOfClass:[JPDog class]]) {
        JPLog(@"JPDog isEqual NO --- self: %p, other: %p", self, object);
        return NO;
    }
    
    JPDog *other = (JPDog *)object;
    BOOL isEq = self.a == other.a && self.b == other.b;
    JPLog(@"JPDog isEqual %@ --- self: %p, other: %p", isEq ? @"YES" : @"NO", self, object);
    return isEq;
}
- (void)dealloc {
    JPLog(@"JPDog 死了 --- self: %p", self);
}
@end

@interface JPTestHashViewController ()
@property (nonatomic, strong) NSMutableSet<JPPerson *> *set1;
@property (nonatomic, strong) NSMutableSet<JPDog *> *set2;
@property (nonatomic, strong) JPPerson *per1;
@property (nonatomic, strong) JPDog *dog1;
@end

@implementation JPTestHashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
    self.set1 = [NSMutableSet set];
    self.set2 = [NSMutableSet set];
    
    self.per1 = [[JPPerson alloc] init];
    self.per1.a = 1;
    self.per1.b = 2;
    
    self.dog1 = [[JPDog alloc] init];
    self.dog1.a = 1;
    self.dog1.b = 2;
    
    UIButton *btn1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:@"test1" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(test1) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = JPRandomColor;
        [btn sizeToFit];
        btn.jp_origin = CGPointMake(10, 100);
        btn;
    });
    [self.view addSubview:btn1];
    
    UIButton *btn2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:@"test2" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(test2) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = JPRandomColor;
        [btn sizeToFit];
        btn.jp_origin = CGPointMake(10, 160);
        btn;
    });
    [self.view addSubview:btn2];
}

- (void)test1 {
    JPPerson *per2 = [[JPPerson alloc] init];
    per2.a = 1;
    per2.b = 2;
    
    NSUInteger per1Hash = self.per1.hash;
    NSUInteger per2Hash = per2.hash;
    
    JPLog(@"per1 %p %zd", self.per1, per1Hash);
    JPLog(@"per2 %p %zd", per2, per2Hash);
    
    if (self.per1 == per2) {
        JPLog(@"per1 per2 == 相等");
    } else {
        JPLog(@"per1 per2 == 不相等");
    }
    
    if (per1Hash == per2Hash) {
        JPLog(@"per1 per2 hash 相等");
    } else {
        JPLog(@"per1 per2 hash 不相等");
    }
    
    if ([self.per1 isEqual:per2]) {
        JPLog(@"per1 per2 isEqual 一样");
    } else {
        JPLog(@"per1 per2 isEqual 不一样");
    }
    
    JPLog(@"per1 per2 add to set");
    
    JPLog(@"----- add per1 00 -----");
    [self.set1 addObject:self.per1];
    JPLog(@"----- add per1 00 -----");
    
    JPLog(@"----- add per2 00 -----");
    [self.set1 addObject:per2];
    JPLog(@"----- add per2 00 -----");
    
    JPLog(@"set1 111 %@", self.set1);
    
    for (NSInteger i = 0; i < 5; i++) {
        self.per1.a = self.per1.a == 1 ? 2 : 1;
        JPLog(@"----- add per1 1%zd -----", i);
        [self.set1 addObject:self.per1];
        JPLog(@"----- add per1 1%zd -----", i);
    }
    
    JPLog(@"set1 222 %@", self.set1);
    
    JPLog(@"--------------------- %zd", self.set1.count);
}

- (void)test2 {
    JPDog *dog2 = [[JPDog alloc] init];
    dog2.a = 1;
    dog2.b = 2;
    
    NSUInteger dog1Hash = self.dog1.hash;
    NSUInteger dog2Hash = dog2.hash;
    
    JPLog(@"dog1 %p %zd", self.dog1, dog1Hash);
    JPLog(@"dog2 %p %zd", dog2, dog2Hash);
    
    if (self.dog1 == dog2) {
        JPLog(@"dog1 dog2 == 相等");
    } else {
        JPLog(@"dog1 dog2 == 不相等");
    }
    
    if (dog1Hash == dog2Hash) {
        JPLog(@"dog1 dog2 hash 相等");
    } else {
        JPLog(@"dog1 dog2 hash 不相等");
    }
    
    if ([self.dog1 isEqual:dog2]) {
        JPLog(@"dog1 dog2 isEqual 一样");
    } else {
        JPLog(@"dog1 dog2 isEqual 不一样");
    }
    
    JPLog(@"dog1 dog2 add to set");
    
    JPLog(@"----- add dog1 00 -----");
    [self.set2 addObject:self.dog1];
    JPLog(@"----- add dog1 00 -----");
    
    JPLog(@"----- add dog2 00 -----");
    [self.set2 addObject:dog2];
    JPLog(@"----- add dog2 00 -----");
    
    JPLog(@"set2 111 %@", self.set2);
    
    for (NSInteger i = 0; i < 5; i++) {
        self.dog1.a = self.dog1.a == 1 ? 2 : 1;
        JPLog(@"----- add dog1 1%zd -----", i);
        [self.set2 addObject:self.dog1];
        JPLog(@"----- add dog1 1%zd -----", i);
    }
    
    JPLog(@"set2 222 %@", self.set2);
    
    JPLog(@"--------------------- %zd", self.set2.count);
}

@end
