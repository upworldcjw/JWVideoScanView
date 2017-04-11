//
//  IKSVPublishBottomViewCellCollectionViewCell.h
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/29.
//  Copyright © 2017年 inke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IKSVPublishBottomViewCell : UICollectionViewCell

+ (CGFloat)properWidth;

- (void)refreshBgImage:(UIImage *)image;

- (void)refreshInnerImage:(UIImage *)image;

@end
