//
//  CPTileDataManager.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPTileSection.h"

@class CPTileDataManager;
@protocol CPTileDataManagerDelegate <NSObject>
- (void)tileDataManager:(CPTileDataManager *)dataManager didDeleteRows:(NSIndexSet *)deletedRows updateRows:(NSIndexSet *)updatedRows insertRows:(NSIndexSet *)insertedRows fromRefresh:(BOOL)isFromRefresh;
- (void)tileDataManager:(CPTileDataManager *)dataManager encounteredRefreshError:(NSError *)error;
@end

@interface CPTileDataManager : NSObject
- (instancetype)initWithFilter:(NSString *)filter;
- (NSUInteger)sectionCount;
- (CPSimpleDate *)sectionHeaderAtIndex:(NSUInteger)index;
- (NSUInteger)tileCountForSection:(NSUInteger)section;
- (CPTile *)tileForInternalIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)rowCount;
- (NSIndexPath *)indexPathFromCellIndex:(NSUInteger)cellIndex;

- (BOOL)refreshTiles:(BOOL)forceRefresh;
- (void)pageMoreTiles;
- (void)clearBackingData;
- (BOOL)allowPaging;
- (void)updateTile:(CPTile *)tile;
- (id)deleteTile:(CPTile *)tile;
- (void)petInfoUpdated;

@property (weak, nonatomic) id<CPTileDataManagerDelegate> delegate;
@end
