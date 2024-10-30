//
//  JPMainTableViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2019/12/10.
//  Copyright © 2019 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPMainTableViewController.h"
#import "JPPhotoViewController.h"
#import "JPFPSLabel.h"
#import "JPPhotoTool.h"
#import <FunnyButton/FunnyButton-Swift.h>

@interface JPMainTableViewController ()
@property (nonatomic, strong) NSArray *subVcNames;
@property (nonatomic, strong) UILabel *header1;
@property (nonatomic, strong) UILabel *header2;
@property (nonatomic, strong) UIView *header;
@end

@implementation JPMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试代码";
    
    JPFPSLabel *fpsLabel = [JPFPSLabel new];
    fpsLabel.jp_origin = CGPointMake(40, JPPortraitScreenHeight - JPDiffTabBarH - fpsLabel.jp_height - 5);
    fpsLabel.layer.zPosition = 999;
    [JPKeyWindow addSubview:fpsLabel];
    
    self.header1 = ({
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JPPortraitScreenWidth, 40)];
        aLabel.font = [UIFont boldSystemFontOfSize:17];
        aLabel.text = @"故事版";
        aLabel;
    });
    
    self.header2 = ({
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JPPortraitScreenWidth, 40)];
        aLabel.font = [UIFont boldSystemFontOfSize:17];
        aLabel.text = @"代码";
        aLabel;
    });
    
#pragma mark 故事版
    self.subVcNames = @[@[@"LittleRedBookViewController",
                          @"JPGIFTestViewController",
                          @"JPRotateViewController",
                          @"JPGPUImageMovieViewController",
                          @"JPGPUImageCameraViewController",
                          @"JPGPUImageSingleFilterViewController",
                          @"JPCaptureViewController",
                          @"JPPropertyAnimatorViewController",
                          @"JPAnimatorViewController",
                          @"JPGCDSemaphoreTestViewController",
                          @"JPGCDTargetQueueViewController",
                          @"JPVideoTestViewController"],
#pragma mark 代码
                        @[@"JPPhotoViewController",
                          @"JPTableTestUpdateViewController",
                          @"SDWebImageTestViewController",
                          @"JPNSCacheViewController",
                          @"JPSwizzleTestViewController",
                          @"WLRecordConfirmViewController",
                          @"TTWheelViewViewController",
                          @"JPResizableImageViewController",
                          @"JPPlayerViewController",
                          @"JPImageVideoViewController",
                          @"JPCollectionTestViewController",
                          @"JPResPathTestViewController",
                          @"JPScrollViewDelegateController",
                          @"JPNotiTestViewController",
                          @"JPAnimateTestViewController",
                          @"JPTestHashViewController",
                          @"JPAnimationSpeedViewController",
                          @"JPGIFPreviewViewController",
                          @"JPTXLiveViewController",
                          @"JPRegularCubeViewController",
                          @"JPImageXuanzhuanViewController",
                          @"JPCutVideoViewController",
                          @"JPStartButtonViewController",
                          @"JPYYLabelTestViewController",
                          @"JPFMDBViewController",
                          @"JPBarrierViewController",
                          @"JPGCDSpecificTestViewController",
                          @"JPImageMaskTestViewController",
                          @"GPUImageViewController",
                          @"JPCameraTestViewController",
                          @"JPTextTestViewController",
                          @"JPMasonryTestViewController",
                          @"JPLottieTestViewController",
                          @"JPTestViewController",
                          @"JPRedPackageRainViewController",
                          @"JPScrollViewController",
                          @"JPImageViewTestViewController",
                          @"JPTestCollectionViewController",
                          @"JPLoadBigImageViewController",
                          @"JPHitTestViewController",
                          @"JPBlockTestViewController",
                          @"JPShapeTestViewController",
                          @"JPWebImageTestViewController",
                          @"JPGradientTestViewController",
                          @"TCIFilterViewController"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self removeFunnyActions];
    
    @jp_weakify(self);
    [self addFunnyActionWithName:@"" work:^{
        @jp_strongify(self);
        if (!self) return;
        
    }];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.header1;
    } else {
        return self.header2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.header1.jp_height;
    } else {
        return self.header2.jp_height;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.subVcNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *subVcNames = self.subVcNames[section];
    return subVcNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSArray *subVcNames = self.subVcNames[indexPath.section];
    cell.textLabel.text = subVcNames[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINotificationFeedbackGenerator *r = [[UINotificationFeedbackGenerator alloc] init];
    [r notificationOccurred:UINotificationFeedbackTypeSuccess];
            
//    UIImpactFeedbackGenerator *r = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
//    [r prepare];
//    [r impactOccurred];
    
    NSArray *subVcNames = self.subVcNames[indexPath.section];
    NSString *vcName = subVcNames[indexPath.row];
    
    if ([vcName isEqualToString:@"JPPhotoViewController"]) {
        @jp_weakify(self);
        [JPPhotoToolSI albumAccessAuthorityWithAllowAccessAuthorityHandler:^{
            @jp_strongify(self);
            if (!self) return;
            JPPhotoViewController *vc = [[JPPhotoViewController alloc] initWithTitle:nil maxSelectedCount:3 confirmHandle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        } refuseAccessAuthorityHandler:nil alreadyRefuseAccessAuthorityHandler:nil canNotAccessAuthorityHandler:nil isRegisterChange:YES];
        return;
    }
    
    UIViewController *vc;
    if (indexPath.section == 0) {
        @try {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:vcName];
        } @catch (NSException *exception) {}
    } else {
        vc = [[NSClassFromString(vcName) alloc] init];
    }
    
    if (!vc) {
        [JPProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n目前不存在！", vcName] userInteractionEnabled:YES];
        return;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
