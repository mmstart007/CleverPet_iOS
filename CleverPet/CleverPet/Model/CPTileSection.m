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
@end