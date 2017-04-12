//
//  JWVideoScanDetailView.h
//  JWVideoScanViewDemo
//
//  Created by JianweiChenJianwei on 2017/4/12.
//  Copyright © 2017年 IK. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface JWVideoScanDetailView : UIView

//如果有maxSize 空间可以用来显示 ration（宽/高）比例的视频，那么“返回值”就是实际适合显示大小
+ (CGSize)properSizeForRation:(CGFloat)ration maxAvaliableSize:(CGSize)maxSize;

//- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithAsset:(AVURLAsset *)asset;

- (void)seekToTime:(CMTime)time;

- (UIImage *)renderImageCurrentShow;


- (void)renderInContext:(CGContextRef)context;

@end
