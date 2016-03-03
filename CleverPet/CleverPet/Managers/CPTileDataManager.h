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
- (NSUInteger)sectionCount;
- (CPSimpleDate *)sectionHeaderAtIndex:(NSUInteger)index;
- (NSUInteger)tileCountForSection:(NSUInteger)section;
- (CPTile *)tileForInternalIndexPath:(NSIndexPath *)indexPath;
- (NSIndexSet *)addTile:(CPTile *)tile;
- (NSIndexSet *)deleteTile:(CPTile *)tile;

- (NSUInteger)rowCount;
- (NSIndexPath *)indexPathFromCellIndex:(NSUInteger)cellIndex;
@end
