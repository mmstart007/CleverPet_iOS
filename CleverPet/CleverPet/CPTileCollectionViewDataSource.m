//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileCollectionViewDataSource.h"
#import "CPTileSection.h"
#import "CPTile.h"
#import "CPTileViewCell.h"


#define TILE_VIEW_CELL @"TILE_VIEW_CELL"

@interface CPTileCollectionViewDataSource ()
@property (strong, nonatomic) NSMutableArray<CPTile *> *tiles;
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CPTileViewCell *cell;
@end

@implementation CPTileCollectionViewDataSource {

}

- (instancetype)initWithCollectionView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.estimatedRowHeight = 100;

        [tableView registerNib:[UINib nibWithNibName:@"CPTileViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:TILE_VIEW_CELL];
    }

    return self;
}

- (void)addTile:(CPTile *)tile {
    NSUInteger index = [self.tiles indexOfObject:tile inSortedRange:NSMakeRange(0, self.tiles.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CPTile *a, CPTile *b) {
        return [a.date compare:b.date];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tiles insertObject:tile atIndex:index];
    [self.tableView endUpdates];
}

- (NSMutableArray *)tiles {
    if (!_tiles) {
        _tiles = [[NSMutableArray alloc] init];
    }

    return _tiles;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPTileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TILE_VIEW_CELL];
    CPTile *tile = self.tiles[(NSUInteger) indexPath.item];
    cell.tile = tile;

    return cell;
}

@end