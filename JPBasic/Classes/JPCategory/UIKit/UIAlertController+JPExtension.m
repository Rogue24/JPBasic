//
//  UIAlertController+JPExtension.m
//  JPBasic
//
//  Created by aa on 2022/3/15.
//

#import "UIAlertController+JPExtension.h"
#import "UIWindow+JPExtension.h"

@implementation UIAlertController (JPExtension)

+ (UIAlertController *)jp_alertControllerWithStyle:(UIAlertControllerStyle)style
                                             title:(NSString *_Nullable)title
                                           message:(NSString *_Nullable)message
                                           actions:(NSArray<UIAlertAction *> *)actions {
    return [self jp_alertControllerWithStyle:style
                                       title:title
                                     message:message
                                     actions:actions
                        configurationHandler:nil
                                      fromVC:[UIWindow jp_topViewControllerFromKeyWindow]];
}

+ (UIAlertController *)jp_alertControllerWithStyle:(UIAlertControllerStyle)style
                                             title:(NSString *_Nullable)title
                                           message:(NSString *_Nullable)message
                                           actions:(NSArray<UIAlertAction *> *)actions
                                            fromVC:(UIViewController *_Nullable)fromVC {
    return [self jp_alertControllerWithStyle:style
                                       title:title
                                     message:message
                                     actions:actions
                        configurationHandler:nil
                                      fromVC:fromVC];
}

+ (UIAlertController *)jp_alertControllerWithStyle:(UIAlertControllerStyle)style
                                             title:(NSString *_Nullable)title
                                           message:(NSString *_Nullable)message
                                           actions:(NSArray<UIAlertAction *> *)actions
                              configurationHandler:(void (^_Nullable)(UITextField *textField))configurationHandler {
    return [self jp_alertControllerWithStyle:style
                                       title:title
                                     message:message
                                     actions:actions
                        configurationHandler:configurationHandler
                                      fromVC:[UIWindow jp_topViewControllerFromKeyWindow]];
}

+ (UIAlertController *)jp_alertControllerWithStyle:(UIAlertControllerStyle)style
                                             title:(NSString *_Nullable)title
                                           message:(NSString *_Nullable)message
                                           actions:(NSArray<UIAlertAction *> *)actions
                              configurationHandler:(void (^_Nullable)(UITextField *textField))configurationHandler
                                            fromVC:(UIViewController *_Nullable)fromVC {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:style];
    
    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    
    if (configurationHandler) {
        [alertController addTextFieldWithConfigurationHandler:configurationHandler];
    }
    
    if (fromVC && actions.count > 0) {
        [fromVC presentViewController:alertController animated:YES completion:nil];
    }
    
    return alertController;
}

@end
