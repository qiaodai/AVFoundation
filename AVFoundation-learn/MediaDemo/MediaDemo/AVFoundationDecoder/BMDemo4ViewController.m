//
//  BMDemo4ViewController.m
//  MediaDemo
//
//  Created by admin on 2018/6/8.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "BMDemo4ViewController.h"
#import "AVFoundationDeccoder.h"
@interface BMDemo4ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageVideoFrame;
@property (strong, nonatomic) AVFoundationDeccoder *decoder;
@property (strong, nonatomic) CADisplayLink *displayLink;
@end

@implementation BMDemo4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self initAVAsset];
}
- (void)initAVAsset
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    NSURL *urlVideo = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVAsset assetWithURL:urlVideo];
    _decoder = [[AVFoundationDeccoder alloc] initWithAsset:asset];
}
- (IBAction)playAction:(id)sender {
    [self initCADisplayLink];
}
- (void)initCADisplayLink{
    if (_displayLink != nil){
        [_displayLink invalidate];
    }
    //定义
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrame)];
    [_displayLink setPreferredFramesPerSecond:60];
   // [_displayLink setFrameInterval:3];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)updateFrame{
    CGImageRef cgImage = [_decoder getNextFrameWithImageRef];
    if (cgImage != nil){
        [_imageVideoFrame setImage:[UIImage imageWithCGImage:cgImage]];
    }else{
        [_decoder endDecode];
        [_displayLink invalidate];
    }
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
