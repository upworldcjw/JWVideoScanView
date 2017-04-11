//
//  IKSVPublishTextEidtView.m
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/29.
//  Copyright © 2017年 inke. All rights reserved.
//

#import "IKSVPublishTextEidtView.h"
#import "XNHPGrowingTextView.h"
//#import "TWMessageBarManager.h"
@interface IKSVPublishTextEidtView ()<XNHPGrowingTextViewDelegate>

@property (nonatomic, strong) XNHPGrowingTextView *textView;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, copy)   NSString *lastRelaceStr;
@property (nonatomic, assign) BOOL isTip;

@end

@implementation IKSVPublishTextEidtView

static CGFloat kMarginLeft = 7;
static CGFloat lineHeight = 2;

- (instancetype)initWithWidth:(CGFloat)width textStyle:(IKSVPublishTextEiditStyle)style{
    CGRect rect = CGRectMake(0, 0, width, 30.0);
    if (self = [super initWithFrame:rect]) {
        self.showInRect = CGRectZero;
        XNHPGrowingTextView *inputTextView = [[XNHPGrowingTextView alloc] initWithFrame:rect];
        inputTextView.internalTextView.backgroundColor = [UIColor redColor];
        inputTextView.contentInset = UIEdgeInsetsMake(0, kMarginLeft, 0, kMarginLeft);
        [inputTextView setBackgroundColor:[UIColor clearColor]];
        inputTextView.delegate = self;
        [inputTextView setReturnKeyType:UIReturnKeyDone];
        inputTextView.enablesReturnKeyAutomatically = YES;
        inputTextView.minNumberOfLines = 1;
        inputTextView.maxNumberOfLines = 3;//最多三行
//        inputTextView.maxHeight = 84;
//        inputTextView.font = [UIFont systemFontOfSize:16];
        inputTextView.font = [UIFont boldSystemFontOfSize:20];
        inputTextView.text = @"";
        inputTextView.internalTextView.scrollEnabled = NO;
        [self addSubview:inputTextView];
        self.textView = inputTextView;
        //代码暂时注销，下个版本在开启
//        CGFloat defaultWidth = 0;
//        self.topLineView = [[UIView alloc] initWithFrame:CGRectMake(kMarginLeft, 0, defaultWidth, lineHeight)];
//        self.topLineView.layer.cornerRadius = 1;
//        self.topLineView.backgroundColor = [UIColor whiteColor];
//        [self addSubview:self.topLineView];
//        
//        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(kMarginLeft, self.bounds.size.height-lineHeight, defaultWidth, lineHeight)];
//        self.bottomLineView.layer.cornerRadius = 1;
//        self.bottomLineView.backgroundColor = [UIColor whiteColor];
//        [self addSubview:self.bottomLineView];
        
        self.style = style;
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveOverlayView:)];
        [self addGestureRecognizer:panGestureRecognizer];
    
    }
    return self;
}

- (void)setStyle:(IKSVPublishTextEiditStyle)style{
    _style = style;
    self.topLineView.hidden = YES;
    self.bottomLineView.hidden = YES;
    switch (style) {
        case IKSVPublishTextEiditStyleNone:
            self.textView.internalTextView.textColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor clearColor];
            self.textView.placeholderColor = [UIColor colorWithWhite:1 alpha:0.7];
            [self.textView.internalTextView setNeedsDisplay];
            break;
        case IKSVPublishTextEiditStyleDarkText:
            self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
            self.textView.internalTextView.textColor = [UIColor darkTextColor];
            self.textView.placeholderColor = [UIColor colorWithWhite:0 alpha:0.7];
            [self.textView.internalTextView setNeedsDisplay];
            break;
        case IKSVPublishTextEiditStyleWhiteText:
            self.textView.placeholderColor = [UIColor colorWithWhite:1 alpha:0.7];
            self.backgroundColor = [[UIColor darkTextColor] colorWithAlphaComponent:0.4];
            self.textView.internalTextView.textColor = [UIColor whiteColor];
            [self.textView.internalTextView setNeedsDisplay];
            break;
//        case IKSVPublishTextEiditStyleBorder:
//            self.topLineView.hidden = NO;
//            self.bottomLineView.hidden = NO;
//            self.textView.internalTextView.textColor = [UIColor whiteColor];
//            self.backgroundColor = [UIColor clearColor];
//            break;
        default:
            break;
    }
}

- (NSString *)inputText{
    return self.textView.text;
}

- (void)editViewBecomeFirstResponder{
    [self.textView becomeFirstResponder];
}

- (void)editViewResignFirstResponder{
    [self.textView resignFirstResponder];
}

- (BOOL)resignFirstResponder{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark -UIPanGestureRecognizer
- (void)moveOverlayView:(UIPanGestureRecognizer *)gesture{
    if (CGRectEqualToRect(self.showInRect, CGRectZero)) {
        return;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            
        }    break;
        case UIGestureRecognizerStateChanged:{
            CGPoint point = [gesture translationInView:self];
            CGRect frame = self.frame;
            frame.origin.y += point.y;
            [self adjustFrame:frame];
            [gesture setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:{
        }
        default:
            break;
    }
}

- (void)adjustFrame:(CGRect)frame{
    if (!CGRectEqualToRect(self.showInRect, CGRectZero)) {
        if (frame.origin.y < self.showInRect.origin.y) {//坐标y太小
            frame.origin.y = self.showInRect.origin.y;
        }else if (CGRectGetMaxY(frame) > CGRectGetMaxY(self.showInRect)){//坐标y太大
            frame.origin.y = CGRectGetMaxY(self.showInRect) - CGRectGetHeight(frame);
        }
    }
    self.frame = frame;
    
    CGRect lineFrame = self.bottomLineView.frame;
    CGFloat maxY = CGRectGetMaxY(self.bounds);
    maxY -= CGRectGetHeight(lineFrame);
    lineFrame.origin.y = maxY;
    self.bottomLineView.frame = lineFrame;
}

#pragma mark-XNHPGrowingTextViewDelegate

- (void)growingTextView:(XNHPGrowingTextView *)growingTextView didChangeHeight:(float)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    [self adjustFrame:frame];

    if ([self.delegate respondsToSelector:@selector(publishTextEidtViewChageFrame:)]) {
        [self.delegate publishTextEidtViewChageFrame:self];
    }
}

- (BOOL)growingTextView:(XNHPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    self.lastRelaceStr = growingTextView.text;
    return YES;
}

//如果高度超过maxLineNum，则需要提示
- (void)growingTextViewContentExceedMaxLine:(XNHPGrowingTextView *)growingTextView{
    [self adjustToMaxText];
    if (!self.isTip) {
        self.isTip = YES;
//        [TWMessageBarManager showToastWithMsg:@"文本最大长度不能超过3行"];
//        kWeak(wself, self);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            wself.isTip = NO;
//        });
    }
}

- (void)adjustToMaxText{
    self.textView.text = self.lastRelaceStr;
}

- (BOOL)growingTextViewShouldReturn:(XNHPGrowingTextView *)growingTextView{
    [self.textView resignFirstResponder];
    return YES;
}

- (void)growingTextViewRefreshSize:(CGSize)size{
    self.topLineView.frame = CGRectMake(kMarginLeft, 0, size.width, lineHeight);
    self.bottomLineView.frame = CGRectMake(kMarginLeft, self.bounds.size.height-lineHeight, size.width, lineHeight);
}

@end
