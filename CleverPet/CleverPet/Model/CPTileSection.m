//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileSection.h"
#import "CPTile.h"
#import "CPSimpleDate.h"

@implementation CPTileSection {

}

- (NSMutableArray *)tiles {
    if (!_tiles) {
        _tiles = [[NSMutableArray alloc] init];
    }

    return _tiles;
}

- (NSUInteger)indexOfTile:(CPTile *)tile forInsertion:(BOOL)forInsertion {
    return [self.tiles indexOfObject:tile inSortedRange:NSMakeRange(0, self.tiles.count) options:forInsertion ? NSBinarySearchingInsertionIndex : NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(CPTile *tile1, CPTile *tile2) {
        return -[tile1.date compare:tile2.date];
    }];
}
@end