//
//  JPPlayerViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2019/12/27.
//  Copyright © 2019 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPPlayerViewController.h"
#import "JPPlayerControlView.h"
#import "WTVGIFButton.h"
#import "JPPhotoTool.h"

@interface JPPlayerViewController ()
@property (nonatomic, weak) JPPlayerControlView *playerCV;
@property (nonatomic, weak) UIButton *playBtn;
@property (nonatomic, weak) WTVGIFButton *gifBtn;
@property (nonatomic, weak) UIButton *cutBtn;
@property (nonatomic, strong) NSURL *videoURL;
@end

@implementation JPPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    JPPlayerControlView *playerCV = [JPPlayerControlView playerControlViewWithPlayerItem:nil];
//    playerCV.delegate = self;
    [self.view addSubview:playerCV];
    self.playerCV = playerCV;
    
    UIButton *playBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"播放" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn setBackgroundColor:JPRandomColor];
        [btn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:playBtn];
    self.playBtn = playBtn;
    
    WTVGIFButton *gifBtn = [[WTVGIFButton alloc] init];
    gifBtn.player = playerCV.player;
    [self.view addSubview:gifBtn];
    self.gifBtn = gifBtn;
    
    UIButton *cutBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"裁剪" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn setBackgroundColor:JPRandomColor];
        [btn addTarget:self action:@selector(cutVideo1) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:cutBtn];
    self.cutBtn = cutBtn;
    
    UIButton *deleteBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"删除JPMoviePath" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn setBackgroundColor:JPRandomColor];
        [btn addTarget:self action:@selector(deleteMoviePath) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:deleteBtn];
    
    [playerCV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(JPNavTopMargin + 30));
        make.left.right.equalTo(self.view);
        make.height.equalTo(self.view.mas_width).multipliedBy(9.0/16.0);
    }];
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(playerCV.mas_bottom).offset(100);
        make.centerX.equalTo(self.view);
    }];
    
    [gifBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(playBtn.mas_bottom).offset(20);
        make.width.height.equalTo(@40);
        make.centerX.equalTo(self.view);
    }];
    
    [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gifBtn.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
    }];
    
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cutBtn.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *camceraBtn = ({
       UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
       btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
       [btn setTitle:@"保存" forState:UIControlStateNormal];
       [btn addTarget:self action:@selector(savePhotoToAppAlbum) forControlEvents:UIControlEventTouchUpInside];
       btn;
   });
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:camceraBtn];
}
- (void)savePhotoToAppAlbum {
    [JPPhotoToolSI saveVideoWithFileURL:[NSURL fileURLWithPath:JPMoviePath] successHandle:^(NSString *assetID) {
        [JPProgressHUD showSuccessWithStatus:@"保存成功" userInteractionEnabled:YES];
    } failHandle:^{
        [JPProgressHUD showSuccessWithStatus:@"保存失败" userInteractionEnabled:YES];
    }];
}

- (void)play {
//    NSString *videoURLStr = JPMainBundleResourcePath(@"iphone-11", @"mp4");
//    NSString *videoURLStr = @"http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/287432564564972819219071679/master_playlist.m3u8";
    
//    NSString *videoURLStr = self.videoURLStr ? self.videoURLStr : @"https://dhxy.v.netease.com/2019/0814/5757db881a2aff4543b7d9c846f3f415qt.mp4";
    
    NSString *videoURLStr = JPMoviePath;
    if (![JPFileTool fileExists:videoURLStr]) {
//        videoURLStr = JPMainBundleResourcePath(@"iphone-11-pro", @"mp4");
        videoURLStr = JPMainBundleResourcePath(@"yaorenmao_dance", @"mp4");
    }
    
    self.videoURL = [NSURL fileURLWithPath:videoURLStr];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.videoURL];
    
    self.playerCV.playerItem = item;
    [self.gifBtn setupPlayerItem:item videoOutput:nil];
}

- (void)deleteMoviePath {
    [JPProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [JPFileTool removeFile:JPMoviePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [JPProgressHUD showSuccessWithStatus:@"ok" userInteractionEnabled:YES];
        });
    });
}

#pragma mark - 1.直接整个视频文件进行截取
- (void)cutVideo1 {
    NSString *videoURLStr = JPMainBundleResourcePath(@"iphone-11-pro", @"mp4");
    NSURL *videoURL = [NSURL fileURLWithPath:videoURLStr];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    // AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    /*
     presetName 说明：
     * AVAssetExportPresetLowQuality  AVAssetExportPresetMediumQuality  AVAssetExportPresetHighestQuality
     * AVAssetExportPreset640x480 AVAssetExportPreset960x540 AVAssetExportPreset1280x720 AVAssetExportPreset1920x1080 AVAssetExportPreset3840x2160
     * AVAssetExportSessionStatusCancelled
     * AVAssetExportPresetAppleM4A
     * AVAssetExportPresetPassthrough
     */
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetHighestQuality];

    // 输出路径
    NSString *outputPath = @"/Users/zhoujianping/Desktop/testImages/testVideo.mp4";
    NSURL *outPutURL = [NSURL fileURLWithPath:outputPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }
    assetExportSession.outputURL = outPutURL;
    
    // 输出视频格式 outputFileType:mov或mp4及其它视频格式
    assetExportSession.outputFileType = AVFileTypeMPEG4; // 暂时写死mp4格式吧
    
    // 输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    // 裁剪区域
    NSRange videoRange = NSMakeRange(30, 15); // 第30秒起，截15秒
    // 开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    // 截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
    assetExportSession.timeRange = videoTimeRange;
    
    [JPProgressHUD show];
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{

            switch (assetExportSession.status) {
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    [JPProgressHUD showErrorWithStatus:@"失败" userInteractionEnabled:YES];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                {
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    [JPProgressHUD showErrorWithStatus:@"取消了" userInteractionEnabled:YES];
                    break;
                }
                    
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    [JPProgressHUD showSuccessWithStatus:@"搞定" userInteractionEnabled:YES];
                    break;
                }
                    
                case AVAssetExportSessionStatusUnknown: {
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                    [JPProgressHUD showErrorWithStatus:@"位置错误" userInteractionEnabled:YES];
                    break;
                }
                    
                case AVAssetExportSessionStatusExporting :
                {
                    NSLog(@"AVAssetExportSessionStatusExporting");
                    [JPProgressHUD showErrorWithStatus:@"Status Exporting" userInteractionEnabled:YES];
                    break;
                }
                    
                case AVAssetExportSessionStatusWaiting:
                {
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                    [JPProgressHUD showErrorWithStatus:@"Status Waiting" userInteractionEnabled:YES];
                    break;
                }
            }
        });
    }];
}

#pragma mark - 2.获取视频文件的视频源+音频源组合一起截取（这种方式也可以合成其他视频文件）
- (void)cutVideo2 {
    //不添加背景音乐

    NSURL *audioUrl =nil;
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    
//    videoAsset.audiovisualTypes;
//    NSLog(@"%@", videoAsset.type);

    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];

    //CMTimeRangeMake(start, duration),start起始时间，duration时长，都是CMTime类型
    //CMTimeMake(int64_t value, int32_t timescale)，返回CMTime，value视频的一个总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值
    //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)，返回CMTime，seconds截取时长（单位秒），preferredTimeScale每秒帧数

    NSRange timeRange = NSMakeRange(1, 30);
    //开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(timeRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime duration = CMTimeMakeWithSeconds(timeRange.length, videoAsset.duration.timescale);

#pragma mark 视频采集
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, duration);

    // 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];

#pragma mark 视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    //声音长度截取范围==视频长度
    CMTimeRange audioTimeRange = CMTimeRangeMake(startTime, duration);
    
    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];

#pragma mark 导出
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];


    //混合后的视频输出路径
    NSString *outputPath = @"/Users/zhoujianping/Desktop/testImages/testVideo.mp4";
    NSURL *outPutURL = [NSURL fileURLWithPath:outputPath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }

    //输出视频格式 outputFileType:mov或mp4及其它视频格式
    assetExportSession.outputFileType = AVFileTypeMPEG4; // 暂时写死mp4格式吧
    assetExportSession.outputURL = outPutURL;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{

            switch (assetExportSession.status) {
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                {
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    break;
                }
                    
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    break;
                }
                    
                case AVAssetExportSessionStatusUnknown: {
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                    break;
                }
                    
                case AVAssetExportSessionStatusExporting :
                {
                    NSLog(@"AVAssetExportSessionStatusExporting");
                    break;
                }
                    
                case AVAssetExportSessionStatusWaiting:
                {
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                    break;
                }
            }
        });
    }];
}

@end
