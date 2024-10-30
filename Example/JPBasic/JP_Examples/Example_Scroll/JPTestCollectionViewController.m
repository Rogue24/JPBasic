//
//  JPTestCollectionViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2020/1/16.
//  Copyright © 2020 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPTestCollectionViewController.h"

@interface JPTestCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView *collectionView;
@end

#pragma mark - 探究`scrollToItemAtIndexPath:atScrollPosition:animated:`方法挪动的位置受contentInset的影响

@implementation JPTestCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = flowLayout.minimumInteritemSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 20, 5, 20);
    flowLayout.itemSize = CGSizeMake(100, 80);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, JPNavTopMargin + 100, JPPortraitScreenWidth, 90) collectionViewLayout:flowLayout];
    [self jp_contentInsetAdjustmentNever:collectionView];
    collectionView.backgroundColor = JPRandomColor;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentInset = UIEdgeInsetsMake(0, 50, 0, 50);
    [collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = JPRandomColor;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 受collectionView.contentInset的影响，例如 contentInset.left = 0 则贴边，contentInset = 20 则距离左边20
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

@end

#pragma mark - 探究`contentSize`的组成

//@implementation JPTestCollectionViewController
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.view.backgroundColor = JPRandomColor;
//
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.minimumLineSpacing = flowLayout.minimumInteritemSpacing = 10;
//    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    flowLayout.sectionInset = UIEdgeInsetsMake(20, 0, 10, 0);
//    flowLayout.itemSize = CGSizeMake(JPPortraitScreenWidth, 300);
//
//    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, JPNavTopMargin, JPPortraitScreenWidth, JPPortraitScreenHeight - JPNavTopMargin) collectionViewLayout:flowLayout];
//    [self jp_contentInsetAdjustmentNever:collectionView];
//    collectionView.backgroundColor = JPRandomColor;
//    collectionView.dataSource = self;
//    collectionView.delegate = self;
//    collectionView.contentInset = UIEdgeInsetsMake(100, 0, 100, 0);
//    [collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
//    [self.view addSubview:collectionView];
//    self.collectionView = collectionView;
//}
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 2;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 3;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    cell.backgroundColor = JPRandomColor;
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    // contentSize.height = (20 + 300 + 10 + 300 + 10 + 300 + 10) + (20 + 300 + 10 + 300 + 10 + 300 + 10) = 1900
//    [self looklook];
//}
//
//- (void)looklook {
//    JPLog(@"viewHeight --- %lf", self.collectionView.jp_height);
//    JPLog(@"zoomScale --- %lf", self.collectionView.zoomScale);
//    JPLog(@"contentSize --- %@", NSStringFromCGSize(self.collectionView.contentSize));
//    JPLog(@"contentInset --- %@", NSStringFromUIEdgeInsets(self.collectionView.contentInset));
//    JPLog(@"contentOffset --- %@", NSStringFromCGPoint(self.collectionView.contentOffset));
//    JPLog(@"======================================");
//}
//
//@end


