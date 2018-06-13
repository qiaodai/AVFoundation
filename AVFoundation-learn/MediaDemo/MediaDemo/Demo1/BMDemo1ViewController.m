//
//  BMDemo1ViewController.m
//  MediaDemo
//
//  Created by admin on 2018/6/6.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "BMDemo1ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface BMDemo1ViewController ()<AVCaptureFileOutputRecordingDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDevice *audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation BMDemo1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCaptureSession];
    [self startSession];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopSession];
}
#pragma mark - set up
- (void)setupCaptureSession{
    // 1.获取视频设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *device in devices){
        if(device.position == AVCaptureDevicePositionBack){
            self.videoDevice = device;
            break;
        }
    }
    // 2.获取音频设备
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    // 3.创建视频输入
    NSError *error = nil;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    if (error){
        return;
    }
    // 4.创建音频输入
    self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice error:&error];
    if (error) {
        return;
    }
    // 5.创建视频输出
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    //6.创建会话
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    if ([self.captureSession canAddInput:self.videoInput]){
        [self.captureSession addInput:self.videoInput];
    }
    if ([self.captureSession canAddInput:self.audioInput]){
        [self.captureSession addInput:self.audioInput];
    }
    if ([self.captureSession canAddOutput:self.movieFileOutput]){
        [self.captureSession addOutput:self.movieFileOutput];
    }
    
    //7.预览画面
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = self.preView.bounds;
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.preView.layer addSublayer:self.previewLayer];
    

}
#pragma mark -  Tool
- (NSString *)videoPath{
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *moviePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.mp4",[NSDate date].timeIntervalSince1970]];
    return moviePath;
}

- (AVCaptureDevice *)deviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
- (IBAction)cameraPositionButtonClicked:(UIButton *)sender {
    AVCaptureDevice *device =nil;
    if(self.videoDevice.position == AVCaptureDevicePositionFront) {
        device = [self deviceWithPosition:AVCaptureDevicePositionBack];
    }else{
        device = [self deviceWithPosition:AVCaptureDevicePositionFront];
    }
    if(!device) {
        return;
    }else{
        self.videoDevice = device;
    }
    NSError*error =nil;
    AVCaptureDeviceInput*input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(!error) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.videoInput];
        if([self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
            self.videoInput = input;
            [self.captureSession commitConfiguration];
            
        }
    }
}
- (IBAction)recordButtonTouchDown:(id)sender {
    NSLog(@"touch down");
    [self startRecord];
}
- (IBAction)recordButtonTouchUp:(id)sender {
    NSLog(@"touch up");
    [self stopRecord];
}

#pragma mark - Session

- (void)startSession {
    if(![self.captureSession isRunning]) {
        [self.captureSession startRunning];
    }
}

- (void)stopSession {
    if([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
}

#pragma mark- Record

- (void)startRecord {
    if (self.videoDevice.isSmoothAutoFocusSupported){
        NSError *error = nil;
        if ([self.videoDevice lockForConfiguration:&error]){
            self.videoDevice.smoothAutoFocusEnabled = YES;
            [self.videoDevice unlockForConfiguration];
        }
        [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self videoPath]] recordingDelegate:self];
    }
}
- (void)stopRecord {
    if ([self.movieFileOutput isRecording]) {
        [self.movieFileOutput stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    NSLog(@"record start ************************");
}
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    NSLog(@"record finish *****************************");
    
    UISaveVideoAtPathToSavedPhotosAlbum([outputFileURL path], nil, nil, nil);
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
