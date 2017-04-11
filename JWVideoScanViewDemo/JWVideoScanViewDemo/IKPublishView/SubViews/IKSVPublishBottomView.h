//
//  IKSVPublishBottomView.h
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/29.
//  Copyright © 2017年 inke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IKSVPublishTextEidtView.h"

@interface IKSVPublishBottomView : UIView
//selectedIndex = -1 表示没有选择过
@property (nonatomic, assign, readonly) NSInteger selectedIndex;
@property (nonatomic, assign)           CGFloat   contentMarginLeft;
@property (nonatomic, copy) void(^selectedBlock)(IKSVPublishTextEiditStyle index);

+ (CGFloat)properHeight;

@end
