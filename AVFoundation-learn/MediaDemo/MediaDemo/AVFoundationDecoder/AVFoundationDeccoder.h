//
//  AVFoundationDeccoder.h
//  MediaDemo
//
//  Created by admin on 2018/6/8.
//  Copyright © 2018年 dai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface AVFoundationDeccoder : NSObject

@property(nonatomic, strong) AVAsset *asset;

- (instancetype)initWithAsset:(AVAsset *)asset;
// 依次获取帧序列
- (CGImageRef)getNextFrameWithImageRef;
- (void)endDecode;
@end
