//
//  JPSystemImagePickerTool.m
//  WoLive
//
//  Created by 周健平 on 2019/1/3.
//  Copyright © 2019 zhoujianping. All rights reserved.
//

#import "JPSystemImagePickerTool.h"
#import "JPScreenRotationTool.h"
#import "JPPhotoTool.h"

static JPSystemImagePickerTool *systemImagePickerTool_ = nil;

@interface JPSystemImagePickerTool () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL isNeedResize;
@property (nonatomic, assign) CGFloat resizeWHScale;
@property (nonatomic, assign) BOOL isOriginImageresizer;
@property (nonatomic, copy) void (^willOpenImagePicker)(UIImagePickerController *picker, BOOL isCamera);
@property (nonatomic, copy) void (^willCloseImagePicker)(UIImagePickerController *picker);
@property (nonatomic, copy) void (^didClosedImagePicker)(void);
@property (nonatomic, copy) void (^imagePickerComplete)(NSURL *mediaURL, UIImage *image);

@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;
@property (nonatomic, assign) BOOL originStatusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) BOOL isCamera;

@property (nonatomic, weak) UIImagePickerController *picker;
@end

@implementation JPSystemImagePickerTool

+ (void)openSystemImagePickerWithTitle:(NSString *)title
                               message:(NSString *)message
                               options:(JPSystemImagePickerOption)options
                     otherAlertActions:(NSArray<UIAlertAction *> *)otherAlertActions
                   willOpenImagePicker:(void(^)(UIImagePickerController *picker, BOOL isCamera))willOpenImagePicker
                  willCloseImagePicker:(void(^)(UIImagePickerController *picker))willCloseImagePicker
                  didClosedImagePicker:(void(^)(void))didClosedImagePicker
                   imagePickerComplete:(void(^)(NSURL *mediaURL, UIImage *image))imagePickerComplete {
    [self openSystemImagePickerWithTitle:(NSString *)title
                                 message:(NSString *)message
                                 options:options
                         otherAlertActions:otherAlertActions
                              isNeedResize:NO
                             resizeWHScale:0
                      isOriginImageresizer:NO
                       willOpenImagePicker:willOpenImagePicker
                    willCloseImagePicker:willCloseImagePicker
                    didClosedImagePicker:didClosedImagePicker
                       imagePickerComplete:imagePickerComplete];
}

+ (void)openSystemImagePickerWithTitle:(NSString *)title
                               message:(NSString *)message
                               options:(JPSystemImagePickerOption)options
                     otherAlertActions:(NSArray<UIAlertAction *> *)otherAlertActions
                         resizeWHScale:(CGFloat)resizeWHScale
                  isOriginImageresizer:(BOOL)isOriginImageresizer
                   willOpenImagePicker:(void(^)(UIImagePickerController *picker, BOOL isCamera))willOpenImagePicker
                  willCloseImagePicker:(void(^)(UIImagePickerController *picker))willCloseImagePicker
                  didClosedImagePicker:(void(^)(void))didClosedImagePicker
                   imagePickerComplete:(void(^)(NSURL *mediaURL, UIImage *image))imagePickerComplete {
    [self openSystemImagePickerWithTitle:(NSString *)title
                                 message:(NSString *)message
                                 options:options
                         otherAlertActions:otherAlertActions
                              isNeedResize:YES
                             resizeWHScale:resizeWHScale
                      isOriginImageresizer:isOriginImageresizer
                       willOpenImagePicker:willOpenImagePicker
                    willCloseImagePicker:willCloseImagePicker
                    didClosedImagePicker:didClosedImagePicker
                       imagePickerComplete:imagePickerComplete];
}

+ (void)openSystemImagePickerWithTitle:(NSString *)title
                               message:(NSString *)message
                               options:(JPSystemImagePickerOption)options
                       otherAlertActions:(NSArray<UIAlertAction *> *)otherAlertActions
                            isNeedResize:(BOOL)isNeedResize
                           resizeWHScale:(CGFloat)resizeWHScale
                    isOriginImageresizer:(BOOL)isOriginImageresizer
                     willOpenImagePicker:(void(^)(UIImagePickerController *picker, BOOL isCamera))willOpenImagePicker
                    willCloseImagePicker:(void(^)(UIImagePickerController *picker))willCloseImagePicker
                  didClosedImagePicker:(void(^)(void))didClosedImagePicker
                     imagePickerComplete:(void(^)(NSURL *mediaURL, UIImage *image))imagePickerComplete {
    systemImagePickerTool_ = [JPSystemImagePickerTool new];
    systemImagePickerTool_.isNeedResize = isNeedResize;
    systemImagePickerTool_.resizeWHScale = resizeWHScale;
    systemImagePickerTool_.isOriginImageresizer = isOriginImageresizer;
    systemImagePickerTool_.willOpenImagePicker = willOpenImagePicker;
    systemImagePickerTool_.willCloseImagePicker = willCloseImagePicker;
    systemImagePickerTool_.didClosedImagePicker = didClosedImagePicker;
    systemImagePickerTool_.imagePickerComplete = imagePickerComplete;
    BOOL isOpenCamera = options & JPSystemImagePickerCameraOption;
    BOOL isOpenPhotos = options & JPSystemImagePickerPhotosAlbumOption;
    BOOL isOpenCameraOrPhotos = isOpenCamera && isOpenPhotos;
    if (isOpenCameraOrPhotos || otherAlertActions.count) {
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        for (UIAlertAction *action in otherAlertActions) {
            [alertCtr addAction:action];
        }
        if (isOpenCamera) {
            UIAlertAction *openCamera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [systemImagePickerTool_ openCameraOrAlbum:YES];
            }];
            [alertCtr addAction:openCamera];
        }
        if (isOpenPhotos) {
            UIAlertAction *openAlbum = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [systemImagePickerTool_ openCameraOrAlbum:NO];
            }];
            [alertCtr addAction:openAlbum];
        }
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [systemImagePickerTool_ killMySelf];
        }];
        [alertCtr addAction:cancel];
        
        [[UIWindow jp_topViewControllerFromDelegateWindow] presentViewController:alertCtr animated:YES completion:^{
            [JPScreenRotationTool.sharedInstance rotationToPortrait];
        }];
    } else {
        [systemImagePickerTool_ openCameraOrAlbum:isOpenCamera];
    }
}

- (void)dealloc {
    JPLog(@"JPSystemImagePickerTool 死了！！！！");
}

- (void)openCameraOrAlbum:(BOOL)isCamera {
    @jp_weakify(self);
    if (isCamera) {
        [JPPhotoToolSI cameraAuthorityWithAllowAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            [self reallyOpenCameraOrAlbum:isCamera];
        } refuseAccessAuthorityHandler:nil alreadyRefuseAccessAuthorityHandler:nil canNotAccessAuthorityHandler:nil];
    } else {
        [JPPhotoToolSI albumAccessAuthorityWithAllowAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            [self reallyOpenCameraOrAlbum:isCamera];
        } refuseAccessAuthorityHandler:nil alreadyRefuseAccessAuthorityHandler:nil canNotAccessAuthorityHandler:nil isRegisterChange:NO];
    }
}

- (void)reallyOpenCameraOrAlbum:(BOOL)isCamera {
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.originStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    self.isLandscape = JPScreenWidth > JPScreenHeight;
    self.isCamera = isCamera;
    
    // UIModalPresentationCustom：modal出来是盖在上面 不会触发viewwilldisappear、viewdiddisappear，退出也不会触发viewwillappear、viewdidappear
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationCustom;
    picker.delegate = self;
    picker.sourceType = isCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    
    UIViewController *topVC = [UIWindow jp_topViewControllerFromDelegateWindow];
    if (self.isLandscape) {
        picker.view.alpha = 0;
        [topVC presentViewController:picker animated:NO completion:^{
            !self.willOpenImagePicker ? : self.willOpenImagePicker(picker, isCamera);
            [UIView animateWithDuration:0.2 animations:^{
                picker.view.alpha = 1;
            }];
        }];
    } else {
        !self.willOpenImagePicker ? : self.willOpenImagePicker(picker, isCamera);
        [topVC presentViewController:picker animated:YES completion:nil];
    }
    
    UIStatusBarStyle statusBarStyle = isCamera ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
     [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
#pragma clang diagnostic pop
    self.picker = picker;
}

- (void)killMySelf {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:self.originStatusBarHidden withAnimation:UIStatusBarAnimationSlide];
#pragma clang diagnostic pop
    systemImagePickerTool_ = nil;
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    BOOL isGIF = NO;
    if (@available(iOS 11, *)) {
        if ([[info[UIImagePickerControllerImageURL] pathExtension] isEqualToString:@"gif"]) {
            isGIF = YES;
        }
    }
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (!image) {
        if (@available(iOS 13.0, *)) {
            NSURL *url = info[UIImagePickerControllerImageURL];
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        }
    }
    
    NSURL *mediaURL = (NSURL *)info[UIImagePickerControllerMediaURL];
    
    if (self.isNeedResize && image) {
//        @jp_weakify(self);
//        JPImageresizerViewController *imageresizerVC = [[UIStoryboard storyboardWithName:@"JPLiveModuleStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"JPImageresizerViewController"];
//        imageresizerVC.resizeImage = image;
//        imageresizerVC.resizeWHScale = self.resizeWHScale;
//        imageresizerVC.isOriginImageresizer = self.isOriginImageresizer;
//        imageresizerVC.dismissBlock = ^{
//            @jp_strongify(self);
//            if (!self) return;
//            if (self.isCamera || isGIF) {
//                [self imagePickerControllerDidCancel:self.picker];
//            } else {
//                self.picker.navigationBar.alpha = 1;
//                [self.picker popViewControllerAnimated:YES];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//                 [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//#pragma clang diagnostic pop
//            }
//        };
//        imageresizerVC.imageresizerComplete = ^(UIImage * _Nonnull resizeDoneImage) {
//            @jp_strongify(self);
//            if (!self) return;
//            !self.imagePickerComplete ? : self.imagePickerComplete(mediaURL, resizeDoneImage);
//            [self imagePickerControllerDidCancel:picker];
//        };
//        [picker pushViewController:imageresizerVC animated:YES];
    } else {
        !self.imagePickerComplete ? : self.imagePickerComplete(mediaURL, image);
        [self imagePickerControllerDidCancel:picker];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    !self.willCloseImagePicker ? : self.willCloseImagePicker(picker);
    [picker dismissViewControllerAnimated:YES completion:^{
        !self.didClosedImagePicker ? : self.didClosedImagePicker();
        [systemImagePickerTool_ killMySelf];
    }];
}

@end
