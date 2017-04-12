//
//  JWVideoScanDetailView.m
//  JWVideoScanViewDemo
//
//  Created by JianweiChenJianwei on 2017/4/12.
//  Copyright © 2017年 IK. All rights reserved.
//

#import "JWVideoScanDetailView.h"
#import "UIImage+JWVideo.h"

@import AVFoundation;

@interface JWVideoScanDetailView ()

//@property (strong, nonatomic) UIImageView *renderImgView;
@property (strong, nonatomic) AVURLAsset *asset;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end


@implementation JWVideoScanDetailView

//如果有maxSize 空间可以用来显示 ration（宽/高）比例的视频，那么“返回值”就是实际适合显示大小
+ (CGSize)properSizeForRation:(CGFloat)ration maxAvaliableSize:(CGSize)maxSize{    
    CGFloat maxWidth = maxSize.width;
    CGFloat maxHeight = maxSize.height;
    CGFloat needHeight = maxHeight;
    CGFloat needWidth = needHeight * ration;
    if (needWidth > maxWidth) {
        needWidth = maxWidth;
        needHeight = needWidth / ration;
    }
    return CGSizeMake(needWidth, needHeight);
}

- (instancetype)initWithAsset:(AVURLAsset *)asset{
    if (self = [super initWithFrame:CGRectZero]) {
        self.asset = asset;
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
        self.player = [AVPlayer playerWithPlayerItem:item];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        //    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspectFill;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [self.layer addSublayer:self.playerLayer];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.playerLayer.frame = self.bounds;
}

- (void)seekToTime:(CMTime)time{
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

//- (instancetype)initWithFrame:(CGRect)frame{
//    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor redColor];
//    }
//    return self;
//}

-(UIImage *)getCurrentShowImageForsize:(CGSize)size{
    CMTime time = [[self.player currentItem] currentTime];
    return [UIImage jw_imageAtTime:time size:size forAsset:self.asset];
}

- (UIImage *)renderImageCurrentShow{
    UIImage *image = [self getCurrentShowImageForsize:CGSizeZero];
    //#ifdef kTestRenderImageView
    UIImageView *renderImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    renderImgView.clipsToBounds = YES;
    renderImgView.contentMode = UIViewContentModeScaleAspectFill;
    [renderImgView setImage:image];
    [self addSubview:renderImgView];
//    self.renderImgView = renderImgView;
    //#endif
    CGSize size = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)renderInContext:(CGContextRef)context{
    UIImage *image = [self getCurrentShowImageForsize:CGSizeZero];
    UIImageView *renderImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    renderImgView.clipsToBounds = YES;
    renderImgView.contentMode = UIViewContentModeScaleAspectFill;
    [renderImgView setImage:image];
    [renderImgView.layer renderInContext:context];
}


@end
