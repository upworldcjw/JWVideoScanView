//
//  IKSVPublishTopView.h
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/29.
//  Copyright © 2017年 inke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IKSVPublishTopView : UIView

@property (nonatomic, copy) void (^backBlock)(void);
@property (nonatomic, copy) void (^publishBlock)(void);

+ (CGFloat)properHeight;
@end
