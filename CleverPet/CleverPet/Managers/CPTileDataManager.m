//
//  CPTileDataManager.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileDataManager.h"
#import "CPSimpleDate.h"
#import "CPTile.h"

@interface CPTileDataManager ()
@property (strong, nonatomic) NSMutableDictionary<CPSimpleDate *, CPTileSection *> *tileSections;
@property (strong, nonatomic) NSMutableArray<CPTileSection *> *tileSectionList;
@end

@implementation CPTileDataManager
- (instancetype)init {
    self = [super init];
    if (self) {
        self.tileSectionList = [[NSMutableArray alloc] init];
        self.tileSections = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (NSUInteger)sectionCount {
    return self.tileSectionList.count;
}

- (CPSimpleDate *)sectionHeaderAtIndex:(NSUInteger)index {
    return self.tileSectionList[index].simpleDate;
}

- (NSUInteger)tileCountForSection:(NSUInteger)section {
    return [self tileSectionForIndex:section].tiles.count;
}

- (CPTile *)tileForRow:(NSUInteger)row inSection:(NSUInteger)section {
    return [self tileSectionForIndex:section].tiles[row];
}

- (CPTileSection *)tileSectionForIndex:(NSUInteger)index {
    return self.tileSections[self.tileSectionList[index].simpleDate];
}

- (NSUInteger)indexOfSection:(CPTileSection *)tileSection {
    return [self.tileSectionList indexOfObject:tileSection inSortedRange:NSMakeRange(0, self.tileSectionList.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(CPTileSection *tileSection1, CPTileSection *tileSection2) {
        return -[tileSection1.simpleDate compareToSimpleDate:tileSection2.simpleDate];
    }];
}

- (CPInsertionInfo)addTile:(CPTile *)tile {
    CPSimpleDate *simpleDate = [[CPSimpleDate alloc] initWithDate:tile.date];
    CPTileSection *tileSection = self.tileSections[simpleDate];

    CPInsertionInfo insertionInfo = {
            .isNewSection = NO,
            .rowIndex = NSNotFound,
            .sectionIndex = NSNotFound
    };

    if (!tileSection) {
        insertionInfo.isNewSection = YES;
        tileSection = [[CPTileSection alloc] init];
        tileSection.simpleDate = simpleDate;
        insertionInfo.sectionIndex = [self insertTileSection:tileSection];
    } else {
        insertionInfo.sectionIndex = [self indexOfSection:tileSection];
    }

    insertionInfo.rowIndex = [tileSection.tiles indexOfObject:tile inSortedRange:NSMakeRange(0, tileSection.tiles.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CPTile *tile1, CPTile *tile2) {
        return -[tile1.date compare:tile2.date];
    }];

    [tileSection.tiles insertObject:tile atIndex:insertionInfo.rowIndex];

    return insertionInfo;
}

- (NSUInteger)insertTileSection:(CPTileSection *)tileSection {
    NSUInteger index = [self.tileSectionList indexOfObject:tileSection
                          inSortedRange:NSMakeRange(0, self.tileSectionList.count)
                                options:NSBinarySearchingInsertionIndex
                        usingComparator:^NSComparisonResult(CPTileSection *tileSection1, CPTileSection *tileSection2) {
                            return -[tileSection1.simpleDate compareToSimpleDate:tileSection2.simpleDate];
                        }];

    [self.tileSectionList insertObject:tileSection atIndex:index];
    self.tileSections[tileSection.simpleDate] = tileSection;

    return index;
}
@end
