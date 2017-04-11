//
//  IKSVPublushViewController.h
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/28.
//  Copyright © 2017年 MeeLive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IKSVPublishViewController : UIViewController

@property (nonatomic, assign) CGFloat properRation; //预览视频的宽高比，采用AspectFill模式

- (instancetype)initWithVideoUrl:(NSString *)url;


@end
