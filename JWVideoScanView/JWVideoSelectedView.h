//
//  JWVideoSelectedView.h
//
//  Created by JianweiChenJianwei on 2017/3/28.
//  Copyright © 2017年 inke. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface JWVideoSelectedView : UIView
@property (nonatomic, strong) UIColor *borderColor;

+ (CGFloat)borderWidth;

- (instancetype)initWithContainerSize:(CGSize)size;

- (void)setContentSize:(CGSize)size;

-(void)setImage:(UIImage *)image;
@end
