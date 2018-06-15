//
//  BMDemo0ViewController.m
//  MediaDemo
//
//  Created by admin on 2018/6/6.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "BMDemo0ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface BMDemo0ViewController ()

@property(weak, nonatomic) IBOutlet UIView *preView;
@property(weak, nonatomic) IBOutlet UIView *overlayView;

@property(nonatomic, strong)AVCaptureSession *captureSession;
@property(nonatomic, strong)AVCaptureDevice *captureDevice;
@property(nonatomic, strong)AVCaptureDeviceInput * captureDeviceInput;
@property(nonatomic, strong)AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic, strong)AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property(nonatomic, strong)AVCaptureVideoDataOutput * videoDataOutput;

@property(nonatomic, strong)UIPinchGestureRecognizer *pinGestureRecongnizer;

@property (nonatomic, assign) CGFloat lastPinchDistance;

@end

@implementation BMDemo0ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupCaptureSession];
    [self startSession];
    self.pinGestureRecongnizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureRecognizer:)];
    [self.overlayView addGestureRecognizer:self.pinGestureRecongnizer];
}
- (void)setupCaptureSession{
    //1.创建会话，AVCaptureSession是AVFoundation的核心类,用于捕捉视频和音频,协调视频和音频的输入和输出流.
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    //2.创建输入设备
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //3.创建输入 输出
    NSError *error= nil;
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecTypeJPEG};


    //4.给Session添加input输入 一般是Video或者Audio数据,也可以两者都添加,即AVCaptureSession的输入源AVCaptureDeviceInput.
    if ([self.captureSession canAddInput:self.captureDeviceInput]){
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    // 5.给session添加output输出  添加AVCaptureOutput,即AVCaptureSession的输出源.一般输出源分成:音视频源,图片源,文件源等.
//    音视频输出AVCaptureAudioDataOutput,AVCaptureVideoDataOutput.
//    静态图片输出AVCaptureStillImageOutput(iOS10中被AVCapturePhotoOutput取代了)
//    AVCaptureMovieFileOutput表示文件源.
    if([self.captureSession canAddOutput:self.stillImageOutput]){
        [self.captureSession addOutput:self.stillImageOutput];
    }
    
    //6. 预览画面
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.videoPreviewLayer.frame = self.preView.bounds;
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.preView.layer addSublayer:self.videoPreviewLayer];

}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //NSLog(@"-------  %f",self.preView.safeAreaInsets.top);
    self.videoPreviewLayer.frame = self.preView.bounds;
    NSLog(@"-------  %@",NSStringFromCGRect(self.videoPreviewLayer.frame));
}
- (void)startSession{
    if(![self.captureSession isRunning]){
        [self.captureSession startRunning];
    }
}
- (void)stopSession{
    if([self.captureSession isRunning]){
        [self.captureSession stopRunning];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setFlashMode:(AVCaptureFlashMode)mode{
    if ([self.captureDevice isFlashModeSupported:mode]){
        NSError *error = nil;
        if ([self.captureDevice lockForConfiguration:&error]){
            [self.captureDevice setFlashMode:mode];
            [self.captureDevice unlockForConfiguration];
        }
    }
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
- (IBAction)flashPowerButtonAction:(id)sender {
    if([self.captureDevice isFlashActive]){
        [self setFlashMode:AVCaptureFlashModeOff];
    }else{
        [self setFlashMode:AVCaptureFlashModeOn];
    }
}
- (IBAction)cameraButtonAction:(UIButton *)sender {
    AVCaptureDevice *device = nil;
    if (self.captureDevice.position == AVCaptureDevicePositionFront) {
        device = [self deviceWithPosition:AVCaptureDevicePositionBack];
    }else {
        device = [self deviceWithPosition:AVCaptureDevicePositionFront];
    }
    if (!device) {
        return;
    }else {
        self.captureDevice = device;
    }
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!error) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.captureDeviceInput];
        if ([self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
            self.captureDeviceInput = input;
            [self.captureSession commitConfiguration];
        }
    }
    
}
- (IBAction)takeCamera:(id)sender {
    // 1.获得连接
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    // 2.拍摄照片
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }];
}
- (void)pinchGestureRecognizer:(UIPinchGestureRecognizer *)sender{
    if(sender.numberOfTouches  != 2){
        return;
    }
    CGPoint point1 = [sender locationOfTouch:0 inView:self.overlayView];
    CGPoint point2 = [sender locationOfTouch:1 inView:self.overlayView];
    CGFloat distanceX = point2.x = point1.x;
    CGFloat distanceY = point2.y - point1.y;
    CGFloat distance = sqrtf(distanceX * distanceX +distanceY * distanceY);
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.lastPinchDistance = distance;
    }
    CGFloat change = distance - self.lastPinchDistance;
    change = change / CGRectGetWidth(self.view.bounds);
    [self zoomCamera:change];
    self.lastPinchDistance = distance;
}
- (void)zoomCamera:(CGFloat)change {
    if (self.captureDevice.position == AVCaptureDevicePositionFront) {
        return;
    }
    if (![self.captureDevice respondsToSelector:@selector(videoZoomFactor)]){
        return;
    }
    NSError *error = nil;
    if ([self.captureDevice lockForConfiguration:&error]) {
        CGFloat max = MIN(self.captureDevice.activeFormat.videoMaxZoomFactor, 3.0);
        CGFloat factor = self.captureDevice.videoZoomFactor;
        CGFloat scale = MIN(MAX(factor + change, 1.0), max);
        self.captureDevice.videoZoomFactor = scale;
        [self.captureDevice unlockForConfiguration];
    }
}

@end
