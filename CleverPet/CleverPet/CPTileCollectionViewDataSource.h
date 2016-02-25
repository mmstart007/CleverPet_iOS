//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPTile;

@interface CPTileCollectionViewDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithCollectionView:(UITableView *)tableView;

- (void)addTile:(CPTile *)tile;
- (void)postInit;
@end