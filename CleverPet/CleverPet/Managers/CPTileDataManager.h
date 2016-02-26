//
//  CPTileDataManager.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPTileSection.h"

typedef struct {
    BOOL isNewSection;
    NSUInteger sectionIndex;
    NSUInteger rowIndex;
} CPInsertionInfo;

@interface CPTileDataManager : NSObject
- (NSUInteger)sectionCount;
- (CPSimpleDate *)sectionHeaderAtIndex:(NSUInteger)index;
- (NSUInteger)tileCountForSection:(NSUInteger)section;
- (CPTile *)tileForRow:(NSUInteger)row inSection:(NSUInteger)section;
- (CPInsertionInfo)addTile:(CPTile *)tile;
@end
