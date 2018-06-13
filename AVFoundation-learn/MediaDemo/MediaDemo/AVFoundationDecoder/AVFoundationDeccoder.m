//
//  AVFoundationDeccoder.m
//  MediaDemo
//
//  Created by admin on 2018/6/8.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "AVFoundationDeccoder.h"
@interface AVFoundationDeccoder()
{
    AVAssetTrack *videoTrack;
    AVAssetReaderTrackOutput *videoReaderOutput;
    AVAssetReader *reader;
    AVAsset *assetVideo;
    
}

@end

@implementation AVFoundationDeccoder
- (instancetype)initWithAsset:(AVAsset *)asset{
    self = [super init];
    if (self){
        [self setAsset:asset];
    }
    return self;
}
- (void)setAsset:(AVAsset *)asset{
    if (asset == nil){
        NSLog(@" nil  nil nil ");
        return;
    }
    _asset = asset;
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startDecode:asset withSeekSecond:0];
        });
    }];
}
- (void)startDecode:(AVAsset *)asset withSeekSecond:(float)fSeekSecond{
    NSError *error;
    videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    //如果解码后需要直接由OpenGL显示可使用该类型，kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
    int pixelFormatType = kCVPixelFormatType_32BGRA;
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:@(pixelFormatType) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    videoReaderOutput = [[AVAssetReaderTrackOutput alloc]initWithTrack:videoTrack outputSettings:options];
    reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if ([reader canAddOutput:videoReaderOutput]){
        [reader addOutput:videoReaderOutput];
    }
    
    reader.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(fSeekSecond, asset.duration.timescale), kCMTimePositiveInfinity);
    //注意： timeRange 必须在startReading之前调用，否则无效，在startReading定义的地方有说明
    [reader startReading];
}
// 依次获取帧序列
- (CGImageRef)getNextFrameWithImageRef{
    if([reader status] ==  AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0){
        //读取video sample
        CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
        CGImageRef cgImage = [self updateBufferRef:videoBuffer];
        CFRelease(videoBuffer);
        return cgImage;
    }
    if ([reader status] ==  AVAssetReaderStatusCompleted ){
        [self endDecode];
    }
    return nil;
}

- (CGImageRef)updateBufferRef:(CMSampleBufferRef)videoBuffer{
    CGImageRef cgimage = [self imageFromSampleBufferRef:videoBuffer];
    if(!(__bridge id)cgimage){
        return nil;
    }
    return cgimage;
}
// AVFoundation 捕捉视频帧，很多时候都需要把某一帧转换成 image
- (CGImageRef)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef{
    //为媒体数据设置一个CMSampleBufferRef
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBufferRef);
    //锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    //得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    //得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    //得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    //创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用抽样缓存的数据创建一个位图格式的图形上下文（grraphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    //根据这个位图 context 中的像素创建一个 Quartz image 对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    //解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return quartzImage;
    
    
}
- (void)endDecode{
    [reader cancelReading];
}
@end
