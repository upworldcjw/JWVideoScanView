//
//  JWVideoScanView.m
//
//  Created by JianweiChenJianwei on 2017/3/28.
//  Copyright © 2017年 inke. All rights reserved.
//


#import "JWVideoScanView.h"
#import "JWVideoSelectedView.h"

typedef struct IKSVVideoStatus{
    CGFloat videoRation;        //视频宽高比 width/height
    CGFloat timescale;          //视频帧率 CMTime.timescale
    CGFloat durationPerFrame;   //每一帧图片，占用多长时间
    CGFloat videoFrameWidth;    //JWVideoScanView显示视频帧的有效宽度
    CGFloat videoFrameHeight;   //JWVideoScanView显示视频帧的有效高度
}IKSVVideoStatus;

typedef struct IKSVVideoSelectedPosition{
    NSInteger pageIndex;
    CGFloat progress;
}IKSVVideoSelectedPosition;

@interface JWVideoScanView() <UIScrollViewDelegate>

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *frameView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;
@property (strong, nonatomic) JWVideoSelectedView *selectedView;
@property (nonatomic)         IKSVVideoStatus status;
@property (nonatomic, assign) IKSVVideoSelectedPosition selectPosition;
@property (nonatomic, assign) CMTime requestTime;
@property (nonatomic, assign) BOOL isRequesting;

@property (strong, nonatomic) UIImage       *firstFrameImage;
@property (strong, nonatomic, nullable) AVAsset *asset;
//埋点启动
@property (assign, nonatomic) BOOL dragValiadEnd;

@end

@implementation JWVideoScanView

#pragma mark - Private methods
- (CGFloat)borderWidth{
    return [JWVideoSelectedView borderWidth];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        memset(&(self->_status), 0, sizeof(self->_status));
        self.scanDuration = 3.0;
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
        
        self.frameView = [[UIView alloc] initWithFrame:CGRectMake(self.borderWidth, 0, CGRectGetWidth(self.contentView.frame)-(2*self.borderWidth), CGRectGetHeight(self.contentView.frame))];
        [self.contentView addSubview:self.frameView];
        self.frameView.clipsToBounds = YES;
        
        self.maskView = [[UIView alloc] initWithFrame:self.frameView.bounds];
        self.maskView.backgroundColor = [[UIColor darkTextColor] colorWithAlphaComponent:0.5];
        [self.contentView addSubview:self.maskView];
        
        self.selectedView = [[JWVideoSelectedView alloc] initWithContainerSize:CGSizeZero];
        [self addSubview:self.selectedView];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveOverlayView:)];
        [self.selectedView addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelectedView:)];
        [self.maskView addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)setSelectedViewBorderColor:(UIColor *)selectedViewBorderColor{
    self.selectedView.borderColor = selectedViewBorderColor;
}

//加载视频资源
- (void)loadAsset:(AVAsset *)asset{
    _asset = asset;
    [self doAfterLoadAsset];
}

- (void)doAfterLoadAsset{
    [self.frameView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(self.maximumSize.width *2,self.maximumSize.height*2);
    }
    else {
        self.imageGenerator.maximumSize = self.maximumSize;
    }
    // First image
    NSError *error;
    CMTime actualTime;
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    UIImage *videoScreen;
    if ([self isRetina]){
        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
    } else {
        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
    }
    if (halfWayImage != NULL) {
        CGImageRelease(halfWayImage);
        self.firstFrameImage = videoScreen;
    }
    if (CGSizeEqualToSize(self.valiadSize, CGSizeZero)) {
        self-> _status.videoFrameWidth = videoScreen.size.width;
        self-> _status.videoFrameHeight = videoScreen.size.height;
    }else{
        self-> _status.videoFrameWidth = self.valiadSize.width;
        self-> _status.videoFrameHeight = self.valiadSize.height;
    }
    self-> _status.videoRation = videoScreen.size.width/videoScreen.size.height;
    self-> _status.timescale = self.asset.duration.timescale;
    Float64 duration = CMTimeGetSeconds([self.asset duration]);
    if(duration > self.scanDuration)
    {
        duration = self.scanDuration;
    }
    [self.selectedView setImage:self.firstFrameImage];
}

- (void)refreshViewAfterLoadAsset{
    [self refreshViewFrame];
    [self addFrames];
}

- (void)refreshViewFrame{
    CGFloat screenWidth = CGRectGetWidth(self.frame);//- 2*self.borderWidth
    CGFloat height = self.status.videoFrameHeight;
    CGFloat offsetY = (CGRectGetHeight(self.frame) - height)/2.0;
    [self.contentView setFrame:CGRectMake(0,offsetY, screenWidth, height)];
    
    CGFloat contentWidth = screenWidth - 2*[self borderWidth];
    [self.frameView setFrame:CGRectMake(self.borderWidth, 0, contentWidth, CGRectGetHeight(self.contentView.frame))];
    self.maskView.frame = self.frameView.frame;
    
    [self.selectedView setContentSize:CGSizeMake(self.status.videoFrameWidth, self.status.videoFrameHeight)];
    CGRect frame = self.selectedView.frame;
    frame.origin = CGPointMake(0, -[self borderWidth]);
    self.selectedView.frame = frame;
}

- (void)addFrames{
    CGFloat frameWidth = CGRectGetWidth(self.frameView.frame);
    NSInteger actualFramesNeeded = ceil(frameWidth / self.status.videoFrameWidth);
    
    Float64 duration = CMTimeGetSeconds([self.asset duration]);
    if(duration > self.scanDuration){
        duration = self.scanDuration;
    }
    self->_status.durationPerFrame = (duration / frameWidth) * self.status.videoFrameWidth;
    
    UIImageView *tmp = [[UIImageView alloc] initWithImage:self.firstFrameImage];
    tmp.contentMode = UIViewContentModeScaleAspectFill;
    tmp.clipsToBounds = YES;
    CGRect rect = tmp.frame;
    rect.size.width = self.status.videoFrameWidth;
    rect.size.height = self.status.videoFrameHeight;
    tmp.frame = rect;
    tmp.tag = 0;
    [self.frameView addSubview:tmp];
    
    NSMutableArray *times = [[NSMutableArray alloc] init];
    for (int i=1; i<actualFramesNeeded; i++){
        CMTime time = CMTimeMakeWithSeconds(i*self.status.durationPerFrame, self.status.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        UIImageView *tmp = [[UIImageView alloc] initWithImage:self.firstFrameImage];
        tmp.contentMode = UIViewContentModeScaleAspectFill;
        tmp.clipsToBounds = YES;
        tmp.tag = i;
        CGRect currentFrame = tmp.frame;
        currentFrame.origin.x = i * self.status.videoFrameWidth;
        currentFrame.origin.y = 0;
        currentFrame.size.width = self.status.videoFrameWidth;
        currentFrame.size.height = self.status.videoFrameHeight;
        tmp.frame = currentFrame;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.frameView addSubview:tmp];
        });
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i=1; i<=[times count]; i++) {
            CMTime time = [((NSValue *)[times objectAtIndex:i-1]) CMTimeValue];
            
            CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
            UIImage *videoScreen = nil;
            if ([self isRetina]){
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            } else {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
            }
            if (halfWayImage) {
                CGImageRelease(halfWayImage);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = (UIImageView *)[self.frameView viewWithTag:i];
                [imageView setImage:videoScreen];
            });
        }
    });
}
#pragma mark - after invoke loadAsset

- (CGFloat)videoRation{
    return self.status.videoRation;
}

//根据position 计算时间
- (CMTime)timeForPosition:(IKSVVideoSelectedPosition)position{
    NSInteger frameIndex = position.pageIndex;
    CGFloat progress = position.progress;
    CGFloat seconds = (frameIndex + progress) * self.status.durationPerFrame;
    CMTime time = CMTimeMakeWithSeconds(seconds , self.status.timescale);
    return time;
}

//根据position 刷新UI,当force=NO时如果移动距离太少则不刷新.否则设置就获取
- (void)refreshWhenSelectePosition:(IKSVVideoSelectedPosition)position force:(BOOL)force{
    if(self.selectPosition.pageIndex == position.pageIndex &&
       ABS(self.selectPosition.progress - position.progress) < 0.05)
    {
        return;
    }
//    NSLog(@"refreshAtFrame %ld %f",(long)frameIndex,progress);
    self.selectPosition = position;
    CMTime time = [self timeForPosition:position];
    self.requestTime = time;
    [self tryRequestNext];
    if ([self.delegate respondsToSelector:@selector(videoScanView:moveToTime:)]) {
        [self.delegate videoScanView:self moveToTime:time];
    }
}

- (void)tryRequestNext{
    NSAssert([NSThread isMainThread],@"main thread require");
    __weak typeof(self) wself = self;
    CMTime time = self.requestTime;
    if (CMTIME_IS_POSITIVE_INFINITY(time)) {
        return;
    }
    if (!self.isRequesting) {
        [self requestImageForTime:time
                       completion:^(UIImage *image) {
                           [wself.selectedView setImage:image];
                           if ([self.delegate respondsToSelector:@selector(videoScanView:refreshFrameImage:atTime:)]) {
                               [self.delegate videoScanView:self refreshFrameImage:image atTime:time];
                           }
                       }];
        self.requestTime = kCMTimePositiveInfinity;
    }
}

//请求图片
- (void)requestImageForTime:(CMTime)time
                 completion:(void (^)(UIImage *image))completion{
    __weak typeof(self) wself = self;
    wself.isRequesting = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        
        UIImage *videoScreen;
        if ([self isRetina]){
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        } else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        }
        
        CGImageRelease(halfWayImage);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(videoScreen);
            wself.isRequesting = NO;
            [wself tryRequestNext];
        });
    });
}



- (BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale > 1.0));
}

#pragma mark - gesture
//selectedView 的frame 发生变化的时候，调整图片
- (void)afterSelectedViewFrameUpdate{
    CGFloat x = self.selectedView.frame.origin.x;
    CGFloat offsetX = x + self.borderWidth; // -10
    NSInteger page = floor(offsetX / self.status.videoFrameWidth);
    CGFloat progress = (offsetX - page * self.status.videoFrameWidth)/self.status.videoFrameWidth;
    
    IKSVVideoSelectedPosition position;
    position.pageIndex = page;
    position.progress = progress;
    [self refreshWhenSelectePosition:position force:NO];
}

- (void)refreshSelectedViewFrame:(IKSVVideoSelectedPosition)position{
    CGFloat x = self.borderWidth;
    x += self.status.videoFrameWidth * (position.pageIndex + position.progress);
    CGRect frame = self.selectedView.frame;
    frame.origin.x = x;
    self.selectedView.frame = frame;
}


- (void)moveOverlayView:(UIPanGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.dragValiadEnd = NO;
            break;
        case UIGestureRecognizerStateChanged:{
            self.dragValiadEnd = YES;
            CGPoint point = [gesture translationInView:self.selectedView];
            CGRect frame = self.selectedView.frame;
            frame.origin.x += point.x;
            if (CGRectGetMinX(frame) < CGRectGetMinX(self.contentView.frame))
            {
                frame.origin.x = CGRectGetMinX(self.contentView.frame);
            }
            else if(CGRectGetMaxX(frame) > CGRectGetMaxX(self.contentView.frame))
            {
                frame.origin.x = CGRectGetMaxX(self.contentView.frame) - CGRectGetWidth(self.selectedView.frame);
            }
            self.selectedView.frame = frame;
            
            [self afterSelectedViewFrameUpdate];
            [gesture setTranslation:CGPointZero inView:self.selectedView];
            break;
        }
        case UIGestureRecognizerStateEnded:
        default:
        {
            if (self.dragValiadEnd) {
                [self.delegate videoScanViewEndDrag:self];
            }
            self.dragValiadEnd = NO;
        }
            break;
    }
}

- (void)tapSelectedView:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture  locationInView:self.maskView];
    CGRect frame = self.maskView.frame;
    CGFloat offsetX = point.x;
    if(CGRectContainsPoint(frame, point)){
        NSInteger page = floor(offsetX / self.status.videoFrameWidth);
        IKSVVideoSelectedPosition position;
        position.pageIndex = page;
        position.progress = 0;
        [self refreshSelectedViewFrame:position];
        [self refreshWhenSelectePosition:position force:YES];
        [self.delegate videoScanView:self selectedTime:[self timeForPosition:position]];
    }
}

@end
