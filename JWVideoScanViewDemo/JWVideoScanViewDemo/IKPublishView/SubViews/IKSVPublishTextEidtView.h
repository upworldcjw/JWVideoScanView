//
//  IKSVPublishTextEidtView.h
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/29.
//  Copyright © 2017年 inke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XNHPGrowingTextView.h"
typedef NS_ENUM(NSInteger,IKSVPublishTextEiditStyle){
    IKSVPublishTextEiditStyleNone = 0,      //纯文本
    IKSVPublishTextEiditStyleDarkText = 1,  //字体黑色
    IKSVPublishTextEiditStyleWhiteText = 2, //白色字体
//    IKSVPublishTextEiditStyleBorder,    //上线线
};

@class IKSVPublishTextEidtView;

@protocol IKSVPublishTextEidtViewDelegate <NSObject>

- (void)publishTextEidtViewChageFrame:(IKSVPublishTextEidtView *)eiditView;

@end

//外面不支持改变frame 及 bound
@interface IKSVPublishTextEidtView : UIView

@property (nonatomic, assign) IKSVPublishTextEiditStyle style;

@property (nonatomic, weak) id<IKSVPublishTextEidtViewDelegate> delegate;

@property (nonatomic, strong, readonly) XNHPGrowingTextView *textView;

@property (nonatomic, assign) CGRect showInRect;    //是否限制显示区域

- (instancetype)initWithWidth:(CGFloat)width textStyle:(IKSVPublishTextEiditStyle)style;

- (NSString *)inputText;

- (void)editViewBecomeFirstResponder;

- (void)editViewResignFirstResponder;

@end
