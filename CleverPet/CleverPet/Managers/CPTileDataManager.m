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

- (NSUInteger)rowCount {
    NSUInteger rowCount = self.sectionCount;
    
    for (CPTileSection *tileSection in [self.tileSections allValues]) {
        rowCount += tileSection.tiles.count;
    }
    
    return rowCount;
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

- (CPTile *)tileForInternalIndexPath:(NSIndexPath *)indexPath {
    return [self tileSectionForIndex:indexPath.section].tiles[indexPath.row];
}

- (CPTileSection *)tileSectionForIndex:(NSUInteger)index {
    return self.tileSections[self.tileSectionList[index].simpleDate];
}

- (NSUInteger)indexOfSection:(CPTileSection *)tileSection {
    return [self.tileSectionList indexOfObject:tileSection inSortedRange:NSMakeRange(0, self.tileSectionList.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(CPTileSection *tileSection1, CPTileSection *tileSection2) {
        return -[tileSection1.simpleDate compareToSimpleDate:tileSection2.simpleDate];
    }];
}

- (NSUInteger)indexOfSectionStart:(CPTileSection *)tileSection {
    NSUInteger indexOfSectionStart = 0;
    NSUInteger indexOfSection = [self indexOfSection:tileSection];
    
    for (NSUInteger i = 0; i < indexOfSection; i++) {
        CPTileSection *tileSection = self.tileSectionList[i];
        indexOfSectionStart += 1 + tileSection.tiles.count;
    }
    
    return indexOfSectionStart;
}

- (NSIndexSet *)addTile:(CPTile *)tile {
    CPSimpleDate *simpleDate = [[CPSimpleDate alloc] initWithDate:tile.date];
    CPTileSection *tileSection = self.tileSections[simpleDate];
    
    NSUInteger sectionStart = NSNotFound;
    NSMutableIndexSet *newIndexes = [[NSMutableIndexSet alloc] init];

    if (!tileSection) {
        tileSection = [[CPTileSection alloc] init];
        tileSection.simpleDate = simpleDate;
        
        [self insertTileSection:tileSection];
        sectionStart = [self indexOfSectionStart:tileSection];
        [newIndexes addIndex:sectionStart];
    } else {
        sectionStart = [self indexOfSectionStart:tileSection];
    }

    NSUInteger rowIndex = [tileSection.tiles indexOfObject:tile inSortedRange:NSMakeRange(0, tileSection.tiles.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CPTile *tile1, CPTile *tile2) {
        return -[tile1.date compare:tile2.date];
    }];

    [tileSection.tiles insertObject:tile atIndex:rowIndex];

    [newIndexes addIndex:sectionStart + 1 + rowIndex];
    
    return [newIndexes copy];
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

- (NSIndexPath *)indexPathFromCellIndex:(NSUInteger)cellIndex {
    NSUInteger section = 0, row = 0;
    
    NSInteger cellIndexTemp = cellIndex;
    
    // Find the section that it's in
    CPTileSection *tileSection = nil;
    while (cellIndexTemp >= 0 && section < self.tileSectionList.count) {
        tileSection = self.tileSectionList[section];
        cellIndexTemp -= 1 + tileSection.tiles.count;
        section++;
    }
    
    section -= 1;
    cellIndexTemp += 1 + tileSection.tiles.count;
    tileSection = self.tileSectionList[section];
    
    if (cellIndexTemp == 0) {
        row = NSNotFound; // refers to the section header for a given section
    } else {
        row = cellIndexTemp - 1;
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}
@end
