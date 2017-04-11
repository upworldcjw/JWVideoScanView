//
//  JWVideoScanView.h
//
//  Created by JianweiChenJianwei on 2017/3/28.
//  Copyright © 2017年 inke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol JWVideoScanViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface JWVideoScanView : UIView

@property (nonatomic, assign) CGFloat scanDuration;         //浏览视频的长度。如果<=0 为原来视频长度

@property (nonatomic, assign, readonly) CGFloat videoRation;//原视频的width/height

@property (nonatomic, assign) CGSize maximumSize;           //从视频中读取帧图片的“最大宽高值”

@property (weak, nonatomic, nullable) id<JWVideoScanViewDelegate> delegate;

@property (assign, nonatomic) CGSize valiadSize;            //实际显示“帧”的宽高。填充采用AspectFill策略
@property (nonatomic, strong) UIColor *selectedViewBorderColor;

- (instancetype)initWithFrame:(CGRect)frame;

//属性设置好之后调用
- (void)loadAsset:(AVAsset *)asset;

- (void)refreshViewAfterLoadAsset;

@end

@protocol JWVideoScanViewDelegate <NSObject>

@optional
//拖动选择回调
- (void)videoScanView:(nonnull JWVideoScanView *)trimmerView moveToTime:(CMTime)time;
//点击“帧”选择回调
- (void)videoScanView:(nonnull JWVideoScanView *)trimmerView selectedTime:(CMTime)time;
//拖动结束 回调
- (void)videoScanViewEndDrag:(JWVideoScanView *)trimmerView;
//拖动或者选择的时候，获取的帧图片
- (void)videoScanView:(nonnull JWVideoScanView *)trimmerView refreshFrameImage:(UIImage *)image atTime:(CMTime)time;
@end

NS_ASSUME_NONNULL_END




