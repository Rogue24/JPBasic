//
//  JPSystemImagePickerTool.h
//  WoLive
//
//  Created by 周健平 on 2019/1/3.
//  Copyright © 2019 zhoujianping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

typedef NS_ENUM(NSUInteger, JPSystemImagePickerOption) {
    JPSystemImagePickerPhotosAlbumOption = 1 << 0,  // default
    JPSystemImagePickerCameraOption      = 1 << 1,
    JPSystemImagePickerAllOption         = ~0UL
};

@interface JPSystemImagePickerTool : NSObject

/** 没裁剪 */
+ (void)openSystemImagePickerWithTitle:(NSString *)title
                               message:(NSString *)message
                               options:(JPSystemImagePickerOption)options
                     otherAlertActions:(NSArray<UIAlertAction *> *)otherAlertActions
                   willOpenImagePicker:(void(^)(UIImagePickerController *picker, BOOL isCamera))willOpenImagePicker
                  willCloseImagePicker:(void(^)(UIImagePickerController *picker))willCloseImagePicker
                  didClosedImagePicker:(void(^)(void))didClosedImagePicker
                   imagePickerComplete:(void(^)(NSURL *mediaURL, UIImage *image))imagePickerComplete;

/** 有裁剪 */
+ (void)openSystemImagePickerWithTitle:(NSString *)title
                               message:(NSString *)message
                               options:(JPSystemImagePickerOption)options
                     otherAlertActions:(NSArray<UIAlertAction *> *)otherAlertActions
                         resizeWHScale:(CGFloat)resizeWHScale
                  isOriginImageresizer:(BOOL)isOriginImageresizer
                   willOpenImagePicker:(void(^)(UIImagePickerController *picker, BOOL isCamera))willOpenImagePicker
                  willCloseImagePicker:(void(^)(UIImagePickerController *picker))willCloseImagePicker
                  didClosedImagePicker:(void(^)(void))didClosedImagePicker
                   imagePickerComplete:(void(^)(NSURL *mediaURL, UIImage *image))imagePickerComplete;
@end

