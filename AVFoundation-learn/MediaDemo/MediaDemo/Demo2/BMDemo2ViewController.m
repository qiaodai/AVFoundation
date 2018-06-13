//
//  BMDemo2ViewController.m
//  MediaDemo
//
//  Created by admin on 2018/6/6.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "BMDemo2ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVPlayerViewController.h>
@interface BMDemo2ViewController ()
@property (nonatomic, strong) AVAssetReader *reader;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetReaderTrackOutput *videoOutput;
@property (nonatomic, strong) AVAssetReaderTrackOutput *audioOutput;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;

@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) dispatch_queue_t audioQueue;

@property (nonatomic, assign) BOOL videoAppendFinish;
@property (nonatomic, assign) BOOL audioAppendFinish;

@property (nonatomic, copy) NSString *outputPath;

@property (nonatomic, strong) NSMutableArray* audioMixParams;
@property (nonatomic, copy) NSURL *mixURL;
@property (nonatomic, copy) NSURL *theEndVideoURL;
@property (strong, nonatomic)AVAudioPlayer *player ;
@end

@implementation BMDemo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
//- (void)setup{
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
//    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:sourcePath] options:nil];
//
//    NSString *sourcePath2 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
//    AVURLAsset *asset2 = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:sourcePath2] options:nil];
//    self.outputPath = [self outputPath];
////    self.reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
////    self.writer = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.outputPath] fileType:AVFileTypeMPEG4 error:nil];
//
//    AVMutableComposition *composition = [AVMutableComposition composition];
//    AVMutableCompositionTrack *video = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:0];
//    [video insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
//    AVMutableCompositionTrack *audio1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
//    [audio1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];
//    AVMutableCompositionTrack *audio2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
//    [audio2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:[[asset2 tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];
//
//    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
//    session.outputURL = [NSURL fileURLWithPath:self.outputPath];
//    session.outputFileType =
//}
//抽取原视频的音频与需要的音乐混合
-(void)addmusic:(id)sender
{
    
    AVMutableComposition *composition =[AVMutableComposition composition];
    _audioMixParams = [NSMutableArray array];
    
    //录制的视频
    NSURL *videoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"]];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    CMTime startTime = CMTimeMakeWithSeconds(0,songAsset.duration.timescale);
    CMTime trackDuration = songAsset.duration;
    
    //获取视频中的音频素材
    BOOL success = [self setUpAndAddAudioAtPath:videoUrl toComposition:composition start:startTime duration:trackDuration offset:CMTimeMake(14*44100,44100)];
    if (!success){
        NSLog(@"添加音频1失败");
    }
    //本地要插入的音乐
    NSString *sourcePath2 = [[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp3"];
    NSURL *assetURL2 =[NSURL fileURLWithPath:sourcePath2];
    //获取设置完的本地音乐素材
    success = [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition start:startTime duration:trackDuration offset:CMTimeMake(14*44100,44100)];
    if (!success){
        NSLog(@"添加音频2失败");
    }
    //创建一个可变的音频混合
    AVMutableAudioMix *audioMix =[AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithArray:_audioMixParams];//从数组里取出处理后的音频轨道参数
    
    //创建一个输出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                     initWithAsset:composition
                                     presetName:AVAssetExportPresetAppleM4A];
    exporter.audioMix = audioMix;
    exporter.outputFileType=@"com.apple.m4a-audio";
    NSString* fileName = [NSString stringWithFormat:@"%@.mov",@"overMix"];
    //输出路径
    NSString *exportFile = [NSString stringWithFormat:@"%@/%@",[self getLibarayPath], fileName];
    
    if([[NSFileManager defaultManager]fileExistsAtPath:exportFile]) {
        [[NSFileManager defaultManager]removeItemAtPath:exportFile error:nil];
    }

    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    self.mixURL = exportURL;
    /* 测试音频是否合成 */
//    if([[NSFileManager defaultManager]fileExistsAtPath:exportFile]) {
//        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:exportURL error:nil];
//        [self.player prepareToPlay];
//        [self.player play];
//        return;
//    }

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:exportURL error:nil];
    [self.player prepareToPlay];
    [self.player play];
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus =(int)exporter.status;
        switch (exportStatus){
            case AVAssetExportSessionStatusFailed:{
                NSError *exportError = exporter.error;
                NSLog(@"错误，信息: %@", exportError);
                break;
            }
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"成功");
                //最终混合
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self theVideoWithMixMusic];
                });
                
                break;
            }
        }
    }];
    
}
//最终音频和视频混合
- (void)theVideoWithMixMusic
{
    //声音来源路径（最终混合的音频）
    NSURL  *audio_inputFileUrl = self.mixURL;
    
    //视频来源路径
    NSURL *videoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"]];

    //最终合成输出路径
    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.outputPath])
        [[NSFileManager defaultManager]removeItemAtPath:self.outputPath error:nil];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    //创建可变的音频视频组合
    AVMutableComposition* mixComposition =[AVMutableComposition composition];
    
    //视频采集
    NSError *error = nil;
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:nextClipStartTime error:&error];
    if (error != nil) {
        NSLog(@"1-------%@",error.description);
    }
    //声音采集
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);//声音长度截取范围==视频长度
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:nextClipStartTime error:&error];
    if (error != nil) {
        NSLog(@"2-------%@",error.description);
    }
    
    //创建一个输出
    NSString *exportFile = [NSString stringWithFormat:@"%@/%@",[self getLibarayPath], @"lastOut.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile]){
        if (![[NSFileManager defaultManager] removeItemAtPath:exportFile error:&error]) {
            NSLog(@"无法删除文件，错误信息：%@",[error localizedDescription]);
        }
    }
    NSURL *lastURL = [NSURL fileURLWithPath:exportFile];
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = lastURL;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    self.theEndVideoURL = lastURL;
    NSLog(@"outputFileType - %@",_assetExport.supportedFileTypes);
    
    

    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         NSLog(@"_assetExport.status = %ld",(long)_assetExport.status);
         switch (_assetExport.status) {
             case AVAssetExportSessionStatusCompleted:
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UISaveVideoAtPathToSavedPhotosAlbum([self.theEndVideoURL path], nil, nil, nil);
                     });
                 }
                 break;
             default:
                 break;
         }
    }];
    
}

//通过文件路径建立和添加音频素材
- (BOOL)setUpAndAddAudioAtPath:(NSURL*)assetURL toComposition:(AVMutableComposition*)composition start:(CMTime)start duration:(CMTime)duration offset:(CMTime)offset{
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSError *error = nil;
    BOOL success = NO;
    
    CMTime startTime = start;
    CMTime trackDuration = songAsset.duration;
    CMTimeRange tRange = CMTimeRangeMake(startTime,trackDuration);
    //设置音量
    //AVMutableAudioMixInputParameters（输入参数可变的音频混合）
    //audioMixInputParametersWithTrack（音频混音输入参数与轨道）
    AVMutableAudioMixInputParameters *trackMix =[AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [trackMix setVolume:0.8f atTime:startTime];
    
    //素材加入数组
    [_audioMixParams addObject:trackMix];
    
    success = [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:kCMTimeInvalid error:&error];
    
    return success;
}

#pragma mark - 保存路径
-(NSString*)getLibarayPath
{
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString* path = [paths objectAtIndex:0];
    NSString *movDirectory = [path stringByAppendingPathComponent:@"tmpMovMix"];
    if (![fileManager fileExistsAtPath:movDirectory]){
        [fileManager createDirectoryAtPath:movDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return movDirectory;
}
- (IBAction)touchExport:(id)sender {
    [self addmusic:sender];
}
- (NSString *)outputPath {
    NSString *root = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [root stringByAppendingPathComponent:@"lastout.mp4"];
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
