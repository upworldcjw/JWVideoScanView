//
//  UIImage+IKVideo.h
//  inke
//
//  Created by JianweiChenJianwei on 2017/2/19.
//  Copyright © 2017年 MeeLive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (IKVideo)

+ (nullable UIImage *)ik_fristFrameImageForFilePath:(nonnull NSString *)path;

+ (nullable UIImage *)ik_fristFrameImageForUrlAsset:(nonnull AVURLAsset *)asset;


/**
 获取指定秒数，指定最适合size大小尺寸

 @param second 单位s
 @param size 尺寸
 @return image
 */
+ (nullable UIImage *)ik_imageAtSeconds:(CGFloat)second size:(CGSize)size forAsset:(nonnull AVURLAsset *)asset;


/**
 获取指定CMTime，指定最适合size大小尺寸
 
 @param time CMTime
 @param size CGSize
 @return image
 */
+ (nullable UIImage *)ik_imageAtTime:(CMTime)time
                                size:(CGSize)size
                            forAsset:(nonnull AVURLAsset *)asset;

@end
