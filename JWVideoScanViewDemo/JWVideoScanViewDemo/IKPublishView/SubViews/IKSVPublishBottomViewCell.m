//
//  IKSVPublishBottomViewCellCollectionViewCell.m
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/29.
//  Copyright © 2017年 inke. All rights reserved.
//

#import "IKSVPublishBottomViewCell.h"

@interface IKSVPublishBottomViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *innerImgView;

@end

@implementation IKSVPublishBottomViewCell

+ (CGFloat)properWidth{
    return 36;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [UIImageView new];
        [self.contentView addSubview:self.imageView];
        self.innerImgView = [UIImageView new];
        [self.contentView addSubview:self.innerImgView];
      
    }
    return self;
}

- (void)layoutSubviews{
    [self.imageView setFrame:self.contentView.bounds];
    [self.innerImgView setFrame:self.contentView.bounds];
}

- (void)refreshBgImage:(UIImage *)image{
    self.imageView.image = image;
}

- (void)refreshInnerImage:(UIImage *)image{
    self.innerImgView.image = image;
}

@end
