//
//  Demo3ViewController.m
//  MediaDemo
//
//  Created by admin on 2018/6/7.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "BMDemo3ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface BMDemo3ViewController ()

@end

@implementation BMDemo3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)startAction:(id)sender {
    NSURL *videoUrl1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"]];
    NSURL *videoUrl2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"]];
    NSURL *videoUrl3 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp4"]];
    NSArray *videoURLs = [NSArray arrayWithObjects:videoUrl1, videoUrl2,videoUrl3, nil];
    [self mergeVideosToOneVedio:videoURLs toStorePath:@"Export" withStoreName:@"out" andIf3D:NO success:^{
        NSLog(@"Success");
    } failure:^{
        NSLog(@"failed");
    }];
    
}
/**
 *  多个视频合成为一个视频输出到指定路径,注意区分是否3D视频
 *
 *  @param videos       视频文件NSURL地址
 *  @param storePath    沙盒目录下的文件夹
 *  @param storeName    合成的文件名字
 *  @param tbool        是否3D视频,YES表示是3D视频
 *  @param successBlock 成功block
 *  @param failureBlock 失败block
 */
- (void)mergeVideosToOneVedio:(NSArray *)videos toStorePath:(NSString *)storePath withStoreName:(NSString *)storeName andIf3D:(BOOL)tbool success:(void (^)(void))successBlock failure:(void (^)(void))failureBlock{
    AVMutableComposition *mixComposition = [self mergeVideosToOnevideo:videos];
    NSURL *outputFileUrl = [self joinStorePath:storePath togetherStoreName:storeName];
    //__weak typeof (self)weakSelf = self;
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];

    assetExport.outputURL = outputFileUrl;
    assetExport.outputFileType = AVFileTypeMPEG4;
    assetExport.shouldOptimizeForNetworkUse = YES;
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UISaveVideoAtPathToSavedPhotosAlbum([outputFileUrl path], nil, nil, nil);
            successBlock();
        });
    }];
}

/**
 *  多个视频合成为一个
 *
 *  @param array 多个视频的NSURL地址
 *
 *  @return 返回AVMutableComposition
 */
- (AVMutableComposition *)mergeVideosToOnevideo:(NSArray *)array{
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    Float64 tmpDuration = 0.0f;
    for (NSInteger i = 0; i < array.count; i++) {
        AVURLAsset *videoAsset = [[AVURLAsset alloc]initWithURL:array[i] options:nil];
        CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
        NSError *error = nil;
        BOOL atbool = [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:CMTimeMake(tmpDuration, 0) error:&error];

        BOOL btbool = [b_compositionAudioTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:CMTimeMake(tmpDuration, 0) error:&error];
        
        if (error != nil || !atbool || !btbool){
            continue;
        }
        tmpDuration += CMTimeGetSeconds(videoAsset.duration);
    }
    return mixComposition;
}
/**
 *  拼接url地址
 *
 *  @param sPath 沙盒文件夹名
 *  @param sName 文件名称
 *
 *  @return 返回拼接好的url地址
 */
- (NSURL *)joinStorePath:(NSString *)sPath togetherStoreName:(NSString *)sName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *storePath = [documentPath stringByAppendingPathComponent:sPath];
    BOOL isExist = [fileManager fileExistsAtPath:storePath];
    if(!isExist){
        [fileManager createDirectoryAtPath:storePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *realName = [NSString stringWithFormat:@"%@.mp4", sName];
    storePath = [storePath stringByAppendingPathComponent:realName];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:storePath];
    return outputFileUrl;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
