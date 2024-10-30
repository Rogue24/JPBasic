//
//  JPVideoTestViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/2/18.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPVideoTestViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface JPVideoTestViewController ()

@end

@implementation JPVideoTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [JPFileTool removeFile:JPMoviePath];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)cutVideo:(id)sender {
    //不添加背景音乐
    NSURL *audioUrl =nil;
    
    NSDictionary *optDict = @{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)};
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:@"/Users/zhoujianping/Desktop/测试的视频/iphone-11-pro-1.mp4"] options:optDict];
    
//    videoAsset.audiovisualTypes;
//    NSLog(@"%@", videoAsset.type);

    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];

    //CMTimeRangeMake(start, duration),start起始时间，duration时长，都是CMTime类型
    //CMTimeMake(int64_t value, int32_t timescale)，返回CMTime，value视频的一个总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值
    //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)，返回CMTime，seconds截取时长（单位秒），preferredTimeScale每秒帧数
    NSRange videoRange = NSMakeRange(60, 10); // 几秒起，截取几秒
    //开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);

    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    // 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [videoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];

    if (audioUrl) {
        //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
        AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
        //声音长度截取范围==视频长度
        CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
        //音频采集compositionCommentaryTrack
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    }
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];

    //混合后的视频输出路径
    NSString *outputPath = @"/Users/zhoujianping/Desktop/测试的视频/iphone-11-pro-1xx.mp4";
    [JPFileTool removeFile:outputPath];

    //输出视频格式 outputFileType:mov或mp4及其它视频格式
    assetExportSession.outputFileType = AVFileTypeMPEG4; // 暂时写死mp4格式吧
    assetExportSession.outputURL = [NSURL fileURLWithPath:outputPath];
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

- (IBAction)mergeVideo:(id)sender {
    NSString *firstVideo = @"/Users/zhoujianping/Desktop/测试的视频/iphone-11-pro-1x.mp4";
    NSString *secondVideo = @"/Users/zhoujianping/Desktop/测试的视频/iphone-11-pro-1xx.mp4";
    
    // 如果创建AVURLAsset时传入的AVURLAssetPreferPreciseDurationAndTimingKey值为NO(不传默认为NO)，duration会取一个估计值，计算量比较小。反之如果为YES，duration需要返回一个精确值，计算量会比较大，耗时比较长。
    NSDictionary *optDict = @{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)};
    AVURLAsset *firstAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:firstVideo] options:optDict];
    AVURLAsset *secondAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:secondVideo] options:optDict];
    
    // 由于没有计算当前CMTime的起始位置，现在插入0的位置,所以合并出来的视频是后添加在前面，可以计算一下时间，插入到指定位置
    //CMTimeRangeMake 指定起去始位置
    CMTimeRange firstTimeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration);
    CMTimeRange secondTimeRange = CMTimeRangeMake(kCMTimeZero, secondAsset.duration);
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    //为视频类型的的Track
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [videoTrack insertTimeRange:secondTimeRange ofTrack:[secondAsset tracksWithMediaType:AVMediaTypeVideo][0] atTime:kCMTimeZero error:nil];
//    [videoTrack insertTimeRange:firstTimeRange ofTrack:[firstAsset tracksWithMediaType:AVMediaTypeVideo][0] atTime:kCMTimeZero error:nil];
    [videoTrack insertTimeRange:firstTimeRange ofTrack:[firstAsset tracksWithMediaType:AVMediaTypeVideo][0] atTime:kCMTimeZero error:nil];
    [videoTrack insertTimeRange:secondTimeRange ofTrack:[secondAsset tracksWithMediaType:AVMediaTypeVideo][0] atTime:firstAsset.duration error:nil];
    
    //只合并视频，导出后声音会消失，所以需要把声音插入到混淆器中
    //添加音频,添加本地其他音乐也可以,与视频一致
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    [audioTrack insertTimeRange:secondTimeRange ofTrack:[secondAsset tracksWithMediaType:AVMediaTypeAudio][0] atTime:kCMTimeZero error:nil];
//    [audioTrack insertTimeRange:firstTimeRange ofTrack:[firstAsset tracksWithMediaType:AVMediaTypeAudio][0] atTime:kCMTimeZero error:nil];
    [audioTrack insertTimeRange:firstTimeRange ofTrack:[firstAsset tracksWithMediaType:AVMediaTypeAudio][0] atTime:kCMTimeZero error:nil];
    [audioTrack insertTimeRange:secondTimeRange ofTrack:[secondAsset tracksWithMediaType:AVMediaTypeAudio][0] atTime:firstAsset.duration error:nil];
    
    NSString *filePath = @"/Users/zhoujianping/Desktop/测试的视频/iphone-11-pro-1xxx.mp4";
    [JPFileTool removeFile:filePath];
    
    AVAssetExportSession *exporterSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exporterSession.outputFileType = AVFileTypeMPEG4;
    exporterSession.outputURL = [NSURL fileURLWithPath:filePath]; //如果文件已存在，将造成导出失败
    exporterSession.shouldOptimizeForNetworkUse = YES; //用于互联网传输
    
    [exporterSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exporterSession.status) {
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"exporter Unknow");
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"exporter Canceled");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"exporter Failed");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"exporter Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"exporter Exporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporter Completed");
                break;
        }
    }];
}

@end
