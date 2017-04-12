//
//  PublishImageViewController.m
//  JWVideoScanViewDemo
//
//  Created by JianweiChenJianwei on 2017/4/12.
//  Copyright © 2017年 IK. All rights reserved.
//

#import "PublishImageViewController.h"

@interface PublishImageViewController ()

@property (nonatomic, strong) UIImageView *renderImgView;

@end

@implementation PublishImageViewController

-(instancetype)initWithImage:(UIImage *)image{
    if (self = [super init]) {
        self.renderImgView = [[UIImageView alloc] initWithImage:image];
        self.renderImgView.clipsToBounds = YES;
        self.renderImgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:self.renderImgView];
        [self.renderImgView setImage:image];
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *cancelBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:cancelBut];
    [cancelBut addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
//    [cancelBut setTitle:@"取消" ];
    [cancelBut setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [cancelBut setFrame:CGRectMake(20, 44, 80, 44)];
}

- (void)viewDidLayoutSubviews{
    self.renderImgView.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
