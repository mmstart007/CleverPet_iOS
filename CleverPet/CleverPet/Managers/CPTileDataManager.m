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
#import "CPTileCommunicationManager.h"
#import "CPGraph.h"

@interface CPTileDataManager ()

@property (strong, nonatomic) NSMutableDictionary<CPSimpleDate *, CPTileSection *> *tileSections;
@property (strong, nonatomic) NSMutableArray<CPTileSection *> *tileSectionList;
@property (nonatomic, assign) BOOL moreTiles;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, assign) BOOL refreshInProgress;
@property (nonatomic, assign) BOOL pageInProgress;
@property (nonatomic, assign) BOOL performedInitialFetch;
@property (nonatomic, strong) NSString *filter;
@property (nonatomic, assign) BOOL shouldForceNextRefresh;

@end

@implementation CPTileDataManager

- (instancetype)initWithFilter:(NSString *)filter
{
    self = [super init];
    if (self) {
        self.filter = [filter lowercaseString];
        self.tileSectionList = [[NSMutableArray alloc] init];
        self.tileSections = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"[CPTileDataManager init] - initWithFilter: should be used instead");
    return [self initWithFilter:nil];
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

- (NSUInteger)indexOfTile:(CPTile *)tile {
    CPSimpleDate *simpleDate = [[CPSimpleDate alloc] initWithDate:tile.date];
    CPTileSection *tileSection = self.tileSections[simpleDate];
    if (!tileSection) {
        return NSNotFound;
    }
    
    NSUInteger sectionStart = [self indexOfSectionStart:tileSection];
    
    NSUInteger rowIndex = [tileSection indexOfTile:tile forInsertion:NO];
    
    if (rowIndex == NSNotFound) {
        return rowIndex;
    }
    
    return sectionStart + 1 + rowIndex;
}

#pragma mark - Backing data manipulation
- (NSIndexSet *)addTile:(CPTile *)tile {
    CPSimpleDate *simpleDate = [[CPSimpleDate alloc] initWithDate:tile.date];
    CPTileSection *tileSection = self.tileSections[simpleDate];
    
    NSUInteger sectionStart = NSNotFound;
    NSMutableIndexSet *newIndexes = [[NSMutableIndexSet alloc] init];

    // We're going to be creating a new section for this tile since one didn't already exist,
    // so we need to add the new index of the section header to the list of indexes to
    // animate.
    if (!tileSection) {
        tileSection = [[CPTileSection alloc] init];
        tileSection.simpleDate = simpleDate;
        
        [self insertTileSection:tileSection];
        sectionStart = [self indexOfSectionStart:tileSection];
        [newIndexes addIndex:sectionStart];
    } else {
        sectionStart = [self indexOfSectionStart:tileSection];
    }

    NSUInteger rowIndex = [tileSection indexOfTile:tile forInsertion:YES];
    [tileSection.tiles insertObject:tile atIndex:rowIndex];

    [newIndexes addIndex:sectionStart + 1 + rowIndex];
    
    return [newIndexes copy];
}

- (NSIndexSet *)deleteTile:(CPTile *)tile {
    // TODO: web call to delete
    CPSimpleDate *simpleDate = [[CPSimpleDate alloc] initWithDate:tile.date];
    CPTileSection *tileSection = self.tileSections[simpleDate];
    
    // We don't have this tile, so do nothing.
    if (!tileSection) {
        return [NSIndexSet indexSet];
    }
    
    NSUInteger sectionStart = [self indexOfSectionStart:tileSection];
    NSUInteger tileIndex = [tileSection indexOfTile:tile forInsertion:NO];
    
    // Couldn't find the tile in the section, so do nothing.
    if (tileIndex == NSNotFound) {
        return [NSIndexSet indexSet];
    }
    
    NSMutableIndexSet *deletedIndexes = [[NSMutableIndexSet alloc] init];
    
    // Deleting this tile will get rid of the section, so we need to get rid of the section header index as well.
    if (tileSection.tiles.count == 1) {
        [deletedIndexes addIndex:sectionStart];
        
        // Delete the section
        [self.tileSections removeObjectForKey:simpleDate];
        NSUInteger tileSectionIndex = [self indexOfSection:tileSection];
        [self.tileSectionList removeObjectAtIndex:tileSectionIndex];
    } else {
        // And delete the actual tile from the data source representation
        [tileSection.tiles removeObjectAtIndex:tileIndex];
    }
    
    // Finally, add the index of the tile within the bigger list of headers + tile indexes.
    [deletedIndexes addIndex:sectionStart + 1 + tileIndex];
    
    return [deletedIndexes copy];
}

- (BOOL)refreshTiles:(BOOL)forceRefresh
{
    if ((self.shouldForceNextRefresh || forceRefresh || !self.performedInitialFetch) && !self.refreshInProgress) {
        BLOCK_SELF_REF_OUTSIDE();
        [self clearBackingData];
        self.refreshInProgress = YES;
        self.shouldForceNextRefresh = NO;
        [[CPTileCommunicationManager sharedInstance] refreshTiles:self.filter completion:^(NSDictionary *tileInfo, NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            self.refreshInProgress = NO;
            self.pageInProgress = NO;
            NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
            // TODO: pass error/message back up the chain
            if (!error) {
                self.performedInitialFetch = YES;
                // Parse our tile objects, and slam into the backing data.
                NSError *modelError;
                NSArray *tiles = [CPTile arrayOfModelsFromDictionaries:tileInfo[kTilesKey] error:&modelError];
                for (CPTile *tile in tiles) {
                    [indexes addIndexes:[self addTile:tile]];
                }
                
                // Hold onto our paging cursor for future use
                self.cursor = [tileInfo[kCursorKey] isKindOfClass:[NSNull class]] ? nil : tileInfo[kCursorKey];
                self.moreTiles = [tileInfo[kMoreKey] boolValue];
                
                [self.delegate tileDataManager:self didDeleteRows:nil updateRows:nil insertRows:indexes fromRefresh:YES];
            } else {
                [self.delegate tileDataManager:self encounteredRefreshError:error];
            }
        }];
        return YES;
    } else {
        [self.delegate tileDataManager:self didDeleteRows:nil updateRows:nil insertRows:nil fromRefresh:YES];
    }
    return NO;
}

- (void)pageMoreTiles
{
    if (self.moreTiles && self.cursor && !self.refreshInProgress && !self.pageInProgress) {
        self.pageInProgress = YES;
        BLOCK_SELF_REF_OUTSIDE();
        // TODO: self.filter
        [[CPTileCommunicationManager sharedInstance] getNextPage:self.filter withCursor:self.cursor completion:^(NSDictionary *tileInfo, NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            self.pageInProgress = NO;
            NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
            if (!error) {
                NSError *modelError;
                NSArray *tiles = [CPTile arrayOfModelsFromDictionaries:tileInfo[kTilesKey] error:&modelError];
                for (CPTile *tile in tiles) {
                    [indexes addIndexes:[self addTile:tile]];
                }
                self.cursor = tileInfo[kCursorKey];
                self.moreTiles = [tileInfo[kMoreKey] boolValue];
                
                [self.delegate tileDataManager:self didDeleteRows:nil updateRows:nil insertRows:indexes fromRefresh:YES];
            } else {
                [self.delegate tileDataManager:self encounteredRefreshError:error];
            }
        }];
    } else {
        [self.delegate tileDataManager:self didDeleteRows:nil updateRows:nil insertRows:nil fromRefresh:YES];
    }
}

- (BOOL)allowPaging
{
    return !self.refreshInProgress && !self.pageInProgress && self.moreTiles;
}

- (void)clearBackingData
{
    // TODO: cancel in progress requests
    // TODO: Handle merging a refresh into the existing data set when we have server support for it
    self.performedInitialFetch = NO;
    self.cursor = nil;
    self.moreTiles = NO;
    [self.tileSectionList removeAllObjects];
    [self.tileSections removeAllObjects];
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

// TODO - This could probably use some optimization
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

- (void)forceNextRefresh
{
    self.shouldForceNextRefresh = YES;
}

- (void)updateTile:(CPTile *)tile
{
    if (self.filter == nil && tile.removed.boolValue) {
        NSIndexSet *deletedIndexes = [self deleteTile:tile];
        [self.delegate tileDataManager:self didDeleteRows:deletedIndexes updateRows:nil insertRows:nil fromRefresh:NO];
    } else if (!tile.removed.boolValue) {
        // We only care about adding this tile if it's part of our filter
        if (self.filter == nil || [tile.category isEqualToString:self.filter]) {
            NSUInteger tileIndex = [self indexOfTile:tile];
            if (tileIndex == NSNotFound) {
                NSIndexSet *addedTile = [self addTile:tile];
                [self.delegate tileDataManager:self didDeleteRows:nil updateRows:nil insertRows:addedTile fromRefresh:NO];
            } else {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:tileIndex];
                [self.delegate tileDataManager:self didDeleteRows:nil updateRows:indexSet insertRows:nil fromRefresh:NO];
            }
        }
    }
}
@end
