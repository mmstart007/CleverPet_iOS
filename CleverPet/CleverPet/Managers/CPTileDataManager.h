//
//  CPTileDataManager.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPTileSection.h"

@interface CPTileDataManager : NSObject
- (instancetype)initWithFilter:(NSString *)filter;
- (NSUInteger)sectionCount;
- (CPSimpleDate *)sectionHeaderAtIndex:(NSUInteger)index;
- (NSUInteger)tileCountForSection:(NSUInteger)section;
- (CPTile *)tileForInternalIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)rowCount;
- (NSIndexPath *)indexPathFromCellIndex:(NSUInteger)cellIndex;

- (NSIndexSet *)addTile:(CPTile *)tile;
- (NSIndexSet *)deleteTile:(CPTile *)tile;
- (BOOL)refreshTiles:(BOOL)forceRefresh completion:(void (^)(NSIndexSet *indexes, NSError *error))completion;
- (ASYNC)pageMoreTiles:(void (^)(NSIndexSet *indexes, NSError *error))completion;
- (void)clearBackingData;
- (BOOL)allowPaging;
- (void)forceNextRefresh;
@end
