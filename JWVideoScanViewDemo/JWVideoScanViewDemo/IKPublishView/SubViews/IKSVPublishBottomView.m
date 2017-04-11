//
//  IKSVPublishBottomView.m
//  inke
//
//  Created by JianweiChenJianwei on 2017/3/29.
//  Copyright © 2017年 inke. All rights reserved.
//

#import "IKSVPublishBottomView.h"
#import "IKSVPublishBottomViewCell.h"
#import "UIColor+help.h"


NSInteger kInvailadIndex = -1;

@interface IKSVPublishBottomItem : NSObject

@property (nonatomic, assign) IKSVPublishTextEiditStyle style;
@property (nonatomic, strong) NSString *imageName;

@end

@implementation IKSVPublishBottomItem
-(instancetype)initStyle:(IKSVPublishTextEiditStyle)style
                   image:(NSString *)imageName{
    if (self = [super init]) {
        self.style = style;
        self.imageName = imageName;
    }
    return self;
}
@end

@interface IKSVPublishBottomView ()<UICollectionViewDelegate,UICollectionViewDataSource>

//@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<IKSVPublishBottomItem *> *models;
@property (nonatomic, strong) UIImage *bgImage;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation IKSVPublishBottomView

static CGFloat kTopMargin = 16;
static CGFloat kBottomMargin = 16;
static CGFloat kCotentHeight = 36;

static NSString *kIKSVPublishBottomViewCell = @"kIKSVPublishBottomViewCell";

+ (CGFloat)properHeight{
    return kTopMargin + kCotentHeight + kBottomMargin;
}

- (void)buildModel{
    IKSVPublishBottomItem *itemNone = [[IKSVPublishBottomItem alloc] initStyle:IKSVPublishTextEiditStyleNone image:@"iksv_publish_textStyleC"];
    
    IKSVPublishBottomItem *itemDarkText = [[IKSVPublishBottomItem alloc] initStyle:IKSVPublishTextEiditStyleDarkText image:@"iksv_publish_textStyleA"];
    
    IKSVPublishBottomItem *itemWhiteText = [[IKSVPublishBottomItem alloc] initStyle:IKSVPublishTextEiditStyleWhiteText image:@"iksv_publish_textStyleB"];
    
//    IKSVPublishBottomItem *itemOpaque = [[IKSVPublishBottomItem alloc] initStyle:IKSVPublishTextEiditStyleBgOpaque image:@"iksv_publish_textStyleD"];
    //上划线，镂空，背景透明，
//    self.models = @[itemBorder,itemOpaque,itemBgAlpha,itemNore];
    self.models = @[itemDarkText,itemNone,itemWhiteText];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.selectedIndex = kInvailadIndex;
        _contentMarginLeft = 40;
        [self buildModel];
        
//        self.topLine = [UIView new];
//        self.topLine.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
//        [self addSubview:self.topLine];

        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowlayout.itemSize = CGSizeMake([IKSVPublishBottomViewCell properWidth], kCotentHeight);
        CGRect rect = CGRectMake(self.contentMarginLeft, kTopMargin, CGRectGetWidth(self.frame) - 2*self.contentMarginLeft, kCotentHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect
                                             collectionViewLayout:flowlayout];
        [_collectionView registerClass:[IKSVPublishBottomViewCell class] forCellWithReuseIdentifier:kIKSVPublishBottomViewCell];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:self.collectionView];
   
//        [self setUpLayout];
    }
    return self;
}


- (void)setContentMarginLeft:(CGFloat)contentMarginLeft{
    if (_contentMarginLeft != contentMarginLeft) {
        _contentMarginLeft = contentMarginLeft;
        CGRect rect = CGRectMake(self.contentMarginLeft, kTopMargin, CGRectGetWidth(self.frame) - 2*self.contentMarginLeft, kCotentHeight);
        _collectionView.frame = rect;
        [_collectionView reloadData];
    }
}

//- (void)setUpLayout{
//    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self);
//        make.height.mas_equalTo(0.5);
//    }];
//}

//- (void)setBgImage:(UIImage *)bgImage{
    //TODO:collection reload cell
//    [_collectionView reloadData];
//}

#pragma mark -UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.models.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IKSVPublishBottomViewCell *cell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:kIKSVPublishBottomViewCell
                                       forIndexPath:indexPath];
    IKSVPublishBottomItem *model = self.models[indexPath.row];
//    [cell refreshBgImage:self.bgImage];
    [cell refreshInnerImage:[UIImage imageNamed:model.imageName]];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    CGFloat contentWidth = CGRectGetWidth(collectionView.frame);
//    contentWidth = contentWidth - self.models.count * [IKSVPublishBottomViewCell properWidth];
//    CGFloat itemSpace = contentWidth / ((self.models.count - 1)?:1);
//    return itemSpace;
    return 16;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    CGFloat margin = self.contentMarginLeft;
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndex != kInvailadIndex) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:self.selectedIndex
                                                        inSection:0];
        [collectionView deselectItemAtIndexPath:oldIndexPath
                                       animated:YES];
    }
    self.selectedIndex = indexPath.item;
    IKSVPublishBottomItem *model = self.models[indexPath.row];
    if (_selectedBlock) {
        _selectedBlock(model.style);
    }
}


@end
