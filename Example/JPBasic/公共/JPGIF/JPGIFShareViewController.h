//
//  JPGIFShareViewController.h
//  WoTV
//
//  Created by 周健平 on 2019/12/23.
//  Copyright © 2019 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPGIFShareViewController : UIViewController
+ (instancetype)showGIFShareVcWithPlaceholder:(UIImage *)placeholder isPortrait:(BOOL)isPortrait dismissBlock:(void(^)(void))dismissBlock;
@property (nonatomic, copy) NSString *gifFilePath;
- (void)createFaild;
@end
