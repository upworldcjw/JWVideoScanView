//
//  UIImage+IKVideo.m
//  inke
//
//  Created by JianweiChenJianwei on 2017/2/19.
//  Copyright © 2017年 MeeLive. All rights reserved.
//

#import "UIImage+IKVideo.h"

@implementation UIImage (IKVideo)

+ (nullable UIImage *)ik_fristFrameImageForFilePath:(NSString *)path{
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    return [self ik_fristFrameImageForUrlAsset:urlAsset];
}

+ (nullable UIImage *)ik_fristFrameImageForUrlAsset:(AVURLAsset *)asset{
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    // First image
    NSError *error;
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 60) actualTime:NULL error:&error];
    UIImage *videoScreen;
    if ([UIScreen mainScreen].scale > 1.0){
        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
    } else {
        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
    }
    if(halfWayImage){
         CGImageRelease(halfWayImage);
    }
    return videoScreen;
}


+ (nullable UIImage *)ik_imageAtSeconds:(CGFloat)second
                                   size:(CGSize)size
                               forAsset:(nonnull AVURLAsset *)asset{
    CMTime time = CMTimeMake(second, asset.duration.timescale);
    return [self ik_imageAtTime:time size:size forAsset:asset];
}

+ (nullable UIImage *)ik_imageAtTime:(CMTime)time
                                size:(CGSize)size
                            forAsset:(nonnull AVURLAsset *)asset{
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGFloat scale = [UIScreen mainScreen].scale;
    imageGenerator.maximumSize = CGSizeMake(size.width*scale, size.height*scale);
    
    if ([imageGenerator respondsToSelector:@selector(setRequestedTimeToleranceBefore:)] && [imageGenerator respondsToSelector:@selector(setRequestedTimeToleranceAfter:)]) {
        [imageGenerator setRequestedTimeToleranceBefore:kCMTimeZero];
        [imageGenerator setRequestedTimeToleranceAfter:kCMTimeZero];
    }
    
    CGImageRef imgRef = [imageGenerator copyCGImageAtTime:time
                                               actualTime:NULL
                                                    error:NULL];
    if (imgRef == nil) {
        if ([imageGenerator respondsToSelector:@selector(setRequestedTimeToleranceBefore:)] && [imageGenerator respondsToSelector:@selector(setRequestedTimeToleranceAfter:)]) {
            [imageGenerator setRequestedTimeToleranceBefore:kCMTimePositiveInfinity];
            [imageGenerator setRequestedTimeToleranceAfter:kCMTimePositiveInfinity];
        }
        imgRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    }
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    if(imgRef){
      CGImageRelease(imgRef);
    }
    return image;
}

@end
