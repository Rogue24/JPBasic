//
//  JPResPathTestViewController.m
//  JPBasic_Example
//
//  Created by aa on 2021/9/26.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPResPathTestViewController.h"

@interface JPResPathTestViewController ()

@end

@implementation JPResPathTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = JPRandomColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *str = @"https://wxmp-yp-devcdn.rzhushou.com/sd_app_res/team_fight/victory_lottie/fight_victory_lv_3.zip?ver=4&ver=4&ver=4&ver=4";
    NSString *str1 = [self getResVerFullUrlPathWithUrl:str];
    JPLog(@"原来 %@", str);
    JPLog(@"之后 %@", str1);
}

- (NSString *)getResVerFullUrlPathWithUrl:(NSString *)urlStr {
    if (![urlStr containsString:@"/sd_app_res/"]) {
        return urlStr;
    }
    
    NSDictionary *resVersionMap = @{
        @"noble/mount_drees_up_privilege": @1,
        @"noble/nameplate_privilege": @1,
        @"relation": @1,
        @"default": @0,
        @"team_fight": @4
    };
    
    if (resVersionMap.count == 0) {
        return urlStr;
    }
    
    // xxx/sd_app_res/noble/mount_drees_up_privilege/lottie.zip?abc=2/s
    
    NSArray *urlStrs = [urlStr componentsSeparatedByString:@"/sd_app_res/"];
    if (urlStrs.count < 2) {
        return urlStr;
    }
    
    NSString *resKey = urlStrs.lastObject;
    // noble/mount_drees_up_privilege/lottie.zip?abc=2/s
    
    // 注意，如果在这里直接stringByDeletingLastPathComponent，只会把最后的“/s”去掉而已
    // 也就成这样：noble/mount_drees_up_privilege/lottie.zip?abc=2
    // 这里目标是要把?后面的都干掉
    urlStrs = [resKey componentsSeparatedByString:@"?"];
    BOOL isWithParameter = NO;
    if (urlStrs.count > 1) {
        isWithParameter = YES;
        resKey = urlStrs.firstObject;
    }
    // noble/mount_drees_up_privilege/lottie.zip
    
    resKey = resKey.stringByDeletingLastPathComponent;
    // noble/mount_drees_up_privilege
    
    if (resKey.length == 0) {
        return urlStr;
    }
    
    NSMutableArray *resKeys = [NSMutableArray array];
    [resKeys addObject:resKey]; // noble/mount_drees_up_privilege
    
    NSArray *paths = [resKey componentsSeparatedByString:@"/"];
    if (paths.count > 1) {
        [resKeys addObject:paths.firstObject]; // noble
    }
    
    [resKeys addObject:@"default"];
    
    // 按这个优先级匹配版本号
    // noble/mount_drees_up_privilege
    // noble
    // default
    NSInteger version = 0;
    for (NSString *key in resKeys) {
        NSNumber *verNum = resVersionMap[key];
        if (verNum != nil) {
            version = verNum.integerValue;
            break;
        }
    }
    
    if (version > 0) {
        if (isWithParameter) {
            NSMutableDictionary<NSString *, NSString *> *parameter = [NSMutableDictionary dictionary];
            NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlStr];
            [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.name.length > 0 && obj.value.length > 0) {
                    parameter[obj.name] = obj.value;
                }
            }];
            parameter[@"ver"] = [NSString stringWithFormat:@"%zd", version];
            
            NSMutableString *paramUrlStr = [NSMutableString string];
            [parameter enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
                if (paramUrlStr.length > 0) [paramUrlStr appendString:@"&"];
                [paramUrlStr appendString:[NSString stringWithFormat:@"%@=%@", key, obj]];
            }];
            
            if (paramUrlStr.length > 0) {
                urlStr = [urlStr componentsSeparatedByString:@"?"].firstObject;
                urlStr = [NSString stringWithFormat:@"%@?%@", urlStr, paramUrlStr];
            }
            
        } else {
            urlStr = [NSString stringWithFormat:@"%@?ver=%zd", urlStr, version];
        }
    }
    
    return urlStr;
}

@end
