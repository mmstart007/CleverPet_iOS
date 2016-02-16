//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPTile;

@interface CPTileCollectionViewDataSource : NSObject<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

- (void)addTile:(CPTile *)tile;
- (void)didSetLayout:(UICollectionViewFlowLayout *)layout;
@end