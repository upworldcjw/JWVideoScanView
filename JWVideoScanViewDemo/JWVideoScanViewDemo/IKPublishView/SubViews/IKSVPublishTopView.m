//
//  IKSVPublishTopView.m
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/29.
//  Copyright © 2017年 inke. All rights reserved.
//

#import "IKSVPublishTopView.h"
#import "UIColor+help.h"
@interface IKSVPublishTopView ()

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel  *titleLbl;
@property (nonatomic, strong) UIButton *publishBtn;

@end

@implementation IKSVPublishTopView

CGFloat kMarignTop = 10;
CGFloat kMarginBottom = 10;

+ (CGFloat)properHeight{
    return 44;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backBtn setBackgroundImage:[UIImage imageNamed:@"iksv_publish_back"] forState:UIControlStateNormal];
        [self addSubview:self.backBtn];
        [self.backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        
        self.titleLbl = [UILabel new];
        self.titleLbl.font = [UIFont systemFontOfSize:18];
        self.titleLbl.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLbl];
        self.titleLbl.text = @"封面和标题";
        
        self.publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.publishBtn setTitle:@"发布" forState:UIControlStateNormal];
        self.publishBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.publishBtn setTitleColor:[UIColor colorWithHexString:@"00d8c9"] forState:UIControlStateNormal];
        [self addSubview:self.publishBtn];
        [self.publishBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout{
    [self.backBtn sizeToFit];
    CGRect rect = self.backBtn.bounds;
    rect.origin.x = 20;
    rect.origin.y = ([IKSVPublishTopView properHeight] - CGRectGetHeight(self.backBtn.frame))/2.0;
    self.backBtn.frame = rect;
    
    [self.titleLbl sizeToFit];
    self.titleLbl.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    
    [self.publishBtn sizeToFit];
    rect = self.publishBtn.frame;
    rect.origin.x = self.frame.size.width - (self.publishBtn.frame.size.width) - 20;
    rect.origin.y =  ([IKSVPublishTopView properHeight] - CGRectGetHeight(self.publishBtn.frame))/2.0;
    self.publishBtn.frame = rect;
}


- (void)back:(id)sender{
    if (_backBlock) {
        _backBlock();
    }
}

- (void)publish:(id)sender{
    if (_publishBlock) {
        _publishBlock();
    }
}
@end
