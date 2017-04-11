//
//  IKSVPublushViewController.m
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/28.
//  Copyright © 2017年 MeeLive. All rights reserved.
//

#import "IKSVPublishViewController.h"
#import "IKSVPublishBottomView.h"
#import "IKSVPublishTopView.h"
#import "IKSVPublishTextEidtView.h"
#import "UIImage+IKVideo.h"
#import "UIColor+help.h"
#import "JWVideoScanView.h"
@import AVFoundation;
@import MobileCoreServices;

#define kTestPhotoLib

@interface IKSVPublishViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, JWVideoScanViewDelegate>

#ifdef kTestPhotoLib
@property (strong, nonatomic) NSString *tempVideoPath;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) UIButton *trimButton;
#endif

@property (strong, nonatomic) UIImageView *renderImgView;
@property (strong, nonatomic) AVURLAsset *asset;
@property (strong, nonatomic) UIView *videoBgView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) IKSVPublishBottomView *bottomView;
@property (strong, nonatomic) IKSVPublishTopView    *topView;
@property (strong, nonatomic) JWVideoScanView     *trimmerView;
@property (strong, nonatomic) IKSVPublishTextEidtView *editView;
@property (strong, nonatomic) NSString *videoUrl;
@end

@implementation IKSVPublishViewController

- (instancetype)initWithVideoUrl:(NSString *)url{
    if (self = [super init]) {
        self.videoUrl = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"333333"];
#ifdef kTestPhotoLib
    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];
    [self setUpTestView];
#else
    if (self.videoUrl) {
        NSURL *url = [NSURL fileURLWithPath:self.videoUrl];
        self.asset = [AVURLAsset assetWithURL:url];
        [self setUpEiditView];
        //由于剪裁现在失败,通过trimmerView 控制前3s剪裁逻辑
        //        if (CMTimeGetSeconds(self.asset.duration) >= 3.0) {
        //            [self trimVideo:nil];
        //        }
    }
#endif
}

- (void)setUpEiditView{
    __weak typeof(self) wself = self;
    self.topView = [[IKSVPublishTopView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [IKSVPublishTopView properHeight])];
    self.topView.backgroundColor = [UIColor colorWithHexString:@"333333"];
    [self.view addSubview:self.topView];
    [self.topView setPublishBlock:^{
        [wself publish];
    }];
    [self.topView setBackBlock:^{
        [wself back];
    }];
    CGFloat leftMargin = 16;
    self.bottomView = [[IKSVPublishBottomView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - [IKSVPublishBottomView properHeight], self.view.bounds.size.width , [IKSVPublishBottomView properHeight])];
    self.bottomView.backgroundColor = [UIColor colorWithHexString:@"333333"];
    self.bottomView.contentMarginLeft = leftMargin;
    [self.view addSubview:self.bottomView];
    [self.bottomView setSelectedBlock:^(IKSVPublishTextEiditStyle style) {
        [wself bottomViewSelectIndex:style];
    }];
    
    CGFloat scanViewheight = 50;
    CGFloat scanViewMarginBottonView = 0;
    CGRect rect = CGRectZero;
    rect.origin.x = leftMargin;
    rect.origin.y = self.view.bounds.size.height - self.bottomView.frame.size.height - scanViewMarginBottonView - scanViewheight;
    rect.size.width = self.view.bounds.size.width - 2* leftMargin;
    rect.size.height = scanViewheight;
    
    //录制视频的宽高比
    //    CGFloat properRation = [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height;
    //外部指定宽高比，显示的内容采用ContentScaleAspectFill
    CGFloat properRation = 40.0 / 50;
    
    self.trimmerView = [[JWVideoScanView alloc] initWithFrame:rect];
    UIColor *borderColor = [UIColor colorWithHexString:@"00d8c9"];
    self.trimmerView.selectedViewBorderColor = borderColor;
    self.trimmerView.backgroundColor = [UIColor colorWithHexString:@"333333"];
    self.trimmerView.maximumSize = CGSizeMake(scanViewheight, scanViewheight);
    [self.trimmerView setDelegate:self];
    [self.view addSubview:self.trimmerView];
    self.trimmerView.scanDuration = CMTimeGetSeconds(self.asset.duration);
    
    self.trimmerView.valiadSize = CGSizeMake(properRation*scanViewheight, scanViewheight);
    [self.trimmerView loadAsset:self.asset];
    [self.trimmerView refreshViewAfterLoadAsset];

    //调用loadAsset之后可以获取实际视频的宽高比
    //videoRation = self.trimmerView.videoRation;//width / height
    CGFloat videoRation = properRation;
    CGFloat maxWidth = self.view.bounds.size.width - 2*leftMargin;
    CGFloat maxHeight =  CGRectGetMinY(self.trimmerView.frame) - 20 - CGRectGetMaxY(self.topView.frame);
    
    CGFloat needHeight = maxHeight;
    CGFloat needWidth = needHeight * videoRation;
    if (needWidth > maxWidth) {
        needWidth = maxWidth;
        needHeight = needWidth / videoRation;
    }
    
    leftMargin = (self.view.bounds.size.width - needWidth)/2.0;
    
    self.videoBgView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(self.topView.frame), needWidth, needHeight)];
    [self.view addSubview:self.videoBgView];
//    self.videoBgView.backgroundColor = [UIColor redColor];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.playerLayer.frame = self.videoBgView.bounds;
    [self.videoBgView.layer addSublayer:self.playerLayer];
    
    //根据图片的宽度，布局trimmerView 和 bottomView 的高度
//    CGRect frame = self.trimmerView.frame;
//    frame.origin.x = leftMargin;
//    frame.size.width = needWidth;
//    self.trimmerView.frame = frame;
//    [self.trimmerView refreshViewAfterLoadAsset];
//    [self.bottomView setContentMarginLeft:leftMargin];
    
    [self loadEidtViewWithStyle:IKSVPublishTextEiditStyleWhiteText];
}

- (void)loadEidtViewWithStyle:(IKSVPublishTextEiditStyle)style{
    self.editView = [[IKSVPublishTextEidtView alloc] initWithWidth:self.videoBgView.frame.size.width
                                                         textStyle:style];
    self.editView.textView.placeholder = @"输入标题...";
    self.editView.textView.placeholderColor = [UIColor whiteColor];
    [self.videoBgView addSubview:self.editView];
//    [self.editView editViewBecomeFirstResponder];
    
    CGRect rect = self.videoBgView.bounds;
    //        CGFloat ration = [UIScreen mainScreen].bounds.size.width/414;
    CGFloat ration= 1;
    rect.origin.y = 50 * ration;
    CGFloat height = rect.size.height - (50+88) * ration;
    rect.size.height = height;
    self.editView.showInRect = rect;
    
    self.editView.center = CGPointMake(self.videoBgView.bounds.size.width/2.0, CGRectGetMaxY(rect)- CGRectGetHeight(self.editView.bounds));
}


- (void)bottomViewSelectIndex:(IKSVPublishTextEiditStyle)style{
    if (self.editView == nil) {
        [self loadEidtViewWithStyle:style];
    }else{
        self.editView.hidden = NO;
        [self.editView setStyle:style];
        if (self.editView.inputText.length == 0) {
            [self.editView editViewBecomeFirstResponder];
        }
    }
}

- (void)publish{
    [self.editView editViewResignFirstResponder];

    UIImage *image = [self getImageAtSeconds:0 size:CGSizeZero];
    //#ifdef kTestRenderImageView
    self.renderImgView = [[UIImageView alloc] initWithFrame:self.videoBgView.frame];
    self.renderImgView.clipsToBounds = YES;
    self.renderImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.renderImgView];
    [self.renderImgView setImage:image];
    //#endif

    CGSize size = self.videoBgView.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.renderImgView.layer renderInContext:context];
    if ([self.editView.textView.text length] != 0) {//有录入文字
        [self.videoBgView.layer renderInContext:context];
    }
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    //录制的时候状态条被隐藏，消失的时候需要显示
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}


-(UIImage *)getImageAtSeconds:(CGFloat)second size:(CGSize)size{
    CMTime time = [[self.player currentItem] currentTime];
    return [UIImage ik_imageAtTime:time size:size forAsset:self.asset];
}

- (void)back{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Actions

#pragma mark -点击其他区域键盘消失
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.editView.textView isFirstResponder]) {
        [self.editView editViewResignFirstResponder];
        if (self.editView.textView.text.length == 0) {
            self.editView.hidden = YES;
        }
    }
}

#pragma mark - JWVideoScanViewDelegate

- (void)videoScanView:(nonnull JWVideoScanView *)trimmerView moveToTime:(CMTime)startTime{
    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

//点击选择帧回调
- (void)videoScanView:(JWVideoScanView *)trimmerView selectedTime:(CMTime)time{
    
}

//拖动结束 回调
- (void)videoScanViewEndDrag:(JWVideoScanView *)trimmerView{
    
}

#ifdef kTestPhotoLib
- (void)setUpTestView{
    UIButton *trimButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [trimButton setTitle:@"选择视频" forState:UIControlStateNormal];
    [trimButton setTintColor:[UIColor redColor]];
    [trimButton setFrame:CGRectMake(0, 0, 100, 44)];
    [trimButton addTarget:self action:@selector(selectAsset:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:trimButton];
    trimButton.center = CGPointMake(self.view.frame.size.width/2.0,self.view.frame.size.height/2.0);
    self.trimButton = trimButton;
}

- (void)selectAsset:(id)sender{
    UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
    myImagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    myImagePickerController.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    myImagePickerController.delegate = self;
    myImagePickerController.editing = NO;
    [self presentViewController:myImagePickerController animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    self.asset = [AVURLAsset assetWithURL:url];
    if (CMTimeGetSeconds(self.asset.duration) >= 3.0) {
        [self trimVideo:nil];
    }
}

- (void)deleteTempFile{
    [[NSFileManager defaultManager] removeItemAtPath:self.tempVideoPath error:NULL];
}

- (void)trimVideo:(id)sender
{
    [self deleteTempFile];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        
        NSURL *furl = [NSURL fileURLWithPath:self.tempVideoPath];
        
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        //        self.exportSession.outputFileType = AVFileTypeMPEG4;
        CGFloat timescale = self.asset.duration.timescale;
        //        if (timescale <= 0.1) {
        //            timescale = 600;
        //        }
        CMTime start = CMTimeMakeWithSeconds(0, timescale);
        CMTime duration = CMTimeMakeWithSeconds(3, timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSURL *movieUrl = [NSURL fileURLWithPath:self.tempVideoPath];
                        self.asset = [AVURLAsset assetWithURL:movieUrl];
                        [self setUpEiditView];
                    });
                    break;
            }
        }];
    }
}
#endif

@end
