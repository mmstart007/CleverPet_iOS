//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPTile;

@class CPTileCollectionViewDataSource;

@protocol CPTileCollectionViewDataSourceDelegate <NSObject>
- (void)dataSource:(CPTileCollectionViewDataSource *)dataSource headerPhotoVisible:(BOOL)headerPhotoVisible headerStatsFade:(CGFloat)headerStatsFade;
- (void)playVideoForTile:(CPTile*)tile;
- (BOOL)isViewVisible;
@end

@interface CPTileCollectionViewDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<CPTileCollectionViewDataSourceDelegate> delegate;

- (instancetype)initWithCollectionView:(UITableView *)tableView andPetImage:(UIImage *)petImage;

- (void)postInit;
- (void)updatePetImage:(UIImage*)petImage;
- (void)videoPlaybackCompletedForTile:(CPTile*)tile;
- (void)viewBecomingVisible;
@end