//
//  JWVideoSelectedView.h
//
//  Created by JianweiChenJianwei on 2017/3/28.
//  Copyright © 2017年 inke. All rights reserved.
//

#import "JWVideoSelectedView.h"
//#import "UIColor+help.h"

@interface JWVideoSelectedView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *topImgView;
//

@end


@implementation JWVideoSelectedView

static CGFloat kBorderWidth = 2;
+ (CGFloat)borderWidth{
    return kBorderWidth;
}

- (instancetype)initWithContainerSize:(CGSize)size{
    CGRect frame = CGRectMake(0, 0, size.width + 2*kBorderWidth , size.height + 2*kBorderWidth);
    if (self = [super initWithFrame:frame]) {
        UIColor *borderColor = [UIColor whiteColor];
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        self.contentView.layer.cornerRadius = 1;
        self.contentView.layer.masksToBounds = YES;
        [self addSubview:self.contentView];
        // add borders
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kBorderWidth)];
        [self.topView setBackgroundColor:borderColor];
        [self.contentView addSubview:self.topView];
        
        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kBorderWidth, self.frame.size.width, kBorderWidth)];
        [self.bottomView setBackgroundColor:borderColor];
        [self.contentView addSubview:self.bottomView];
        
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBorderWidth, self.frame.size.height)];
        [self.leftView setBackgroundColor:borderColor];
        [self.contentView addSubview:self.leftView];
        
        self.rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - kBorderWidth,0 , kBorderWidth, self.frame.size.height)];
        [self.rightView setBackgroundColor:borderColor];
        [self.contentView addSubview:self.rightView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kBorderWidth, kBorderWidth, size.width, size.height)];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        NSString *imageName = [@"JWVideoScanView.bundle" stringByAppendingPathComponent:@"scan_arrow"];
        UIImageView *topImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [self addSubview:topImgView];
        self.topImgView = topImgView;
        [self.topImgView sizeToFit];
        CGRect rect = self.topImgView.frame;
        rect.origin.y = -2 - rect.size.height;
        rect.origin.x = (self.frame.size.width - CGRectGetWidth(self.topImgView.frame))/2.0;
        self.topImgView.frame = rect;
    }
    return self;
}

- (void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    self.topView.backgroundColor = borderColor;
    self.bottomView.backgroundColor = borderColor;
    self.leftView.backgroundColor = borderColor;
    self.rightView.backgroundColor = borderColor;
}


- (void)setContentSize:(CGSize)size{
    CGRect oldFrame = self.frame;
    CGRect frame = CGRectMake(oldFrame.origin.x - kBorderWidth, oldFrame.origin.y - kBorderWidth, size.width + 2*kBorderWidth , size.height + 2*kBorderWidth);
    self.frame = frame;
    
    self.contentView.frame = self.bounds;
    self.topView.frame = CGRectMake(0, 0, self.frame.size.width, kBorderWidth);
    self.bottomView.frame = CGRectMake(0, self.frame.size.height - kBorderWidth, self.frame.size.width, kBorderWidth);
    self.leftView.frame = CGRectMake(0, 0, kBorderWidth, self.frame.size.height);
    self.rightView.frame = CGRectMake(self.frame.size.width - kBorderWidth,0 , kBorderWidth, self.frame.size.height);
    self.imageView.frame = CGRectMake(kBorderWidth, kBorderWidth, size.width, size.height);
    
    //change topImgView
    CGRect rect = self.topImgView.frame;
    rect.origin.y = -2 - rect.size.height;
    rect.origin.x = (self.frame.size.width - CGRectGetWidth(self.topImgView.frame))/2.0;
    self.topImgView.frame = rect;
}


-(void)setImage:(UIImage *)image{
    self.imageView.image = image;
}

@end
