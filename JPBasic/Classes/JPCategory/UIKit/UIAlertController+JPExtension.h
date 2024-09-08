//
//  UIAlertController+JPExtension.h
//  JPBasic
//
//  Created by aa on 2022/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (JPExtension)
/**
 * 没有configurationHandler
 */
+ (UIAlertController *)jp_alertControllerWithStyle:(UIAlertControllerStyle)style
                                             title:(NSString *_Nullable)title
                                           message:(NSString *_Nullable)message
                                           actions:(NSArray<UIAlertAction *> *)actions;

+ (UIAlertController *)jp_alertControllerWithStyle:(UIAlertControllerStyle)style
                                             title:(NSString *_Nullable)title
                                           message:(NSString *_Nullable)message
                                           actions:(NSArray<UIAlertAction *> *)actions
                                            fromVC:(UIViewController *_Nullable)fromVC;

/**
 * 有configurationHandler
 */
+ (UIAlertController *)jp_alertControllerWithStyle:(UIAlertControllerStyle)style
                                             title:(NSString *_Nullable)title
                                           message:(NSString *_Nullable)message
                                           actions:(NSArray<UIAlertAction *> *)actions
                              configurationHandler:(void (^_Nullable)(UITextField *textField))configurationHandler;

+ (UIAlertController *)jp_alertControllerWithStyle:(UIAlertControllerStyle)style
                                             title:(NSString *_Nullable)title
                                           message:(NSString *_Nullable)message
                                           actions:(NSArray<UIAlertAction *> *)actions
                              configurationHandler:(void (^_Nullable)(UITextField *textField))configurationHandler
                                            fromVC:(UIViewController *_Nullable)fromVC;
@end

NS_ASSUME_NONNULL_END
