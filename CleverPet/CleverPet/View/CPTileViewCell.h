//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPTile;
@class CPTileViewCell;

@protocol CPTileViewCellDelegate <NSObject>
- (void)didSwipeTileViewCell:(CPTileViewCell *)tileViewCell;
- (void)playVideoForCell:(CPTileViewCell *)tileViewCell;
- (void)displayError:(NSError*)error;
@end

@interface CPTileViewCell : UITableViewCell

@property (weak, nonatomic) id<CPTileViewCellDelegate> delegate;

- (void)setTile:(CPTile *)tile forSizing:(BOOL)forSizing allowSwiping:(BOOL)allowSwiping;
- (CPTile *)tile;
- (void)resetSwipeState;

@end