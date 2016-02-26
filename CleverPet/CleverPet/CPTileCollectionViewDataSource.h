//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPTile;

@class CPTileCollectionViewDataSource;

@protocol CPTileCollectionViewDataSourceScrollDelegate <NSObject>
- (void)dataSource:(CPTileCollectionViewDataSource *)dataSource headerPhotoVisible:(BOOL)headerPhotoVisible headerStatsFade:(CGFloat)headerStatsFade;
@end

@interface CPTileCollectionViewDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<CPTileCollectionViewDataSourceScrollDelegate> scrollDelegate;

- (instancetype)initWithCollectionView:(UITableView *)tableView;

- (void)addTile:(CPTile *)tile withAnimation:(BOOL)withAnimation;
- (void)postInit;
@end