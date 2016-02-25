//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileCollectionViewDataSource.h"
#import "CPTileSection.h"
#import "CPTile.h"
#import "CPTileViewCell.h"
#import "CPPetStatsView.h"
#import "CPTableHeaderView.h"

#define TILE_VIEW_CELL @"TILE_VIEW_CELL"
#define PET_STATS_HEADER @"PET_STATS_HEADER"
#define SECTION_HEADER @"SECTION_HEADER"
#define HEADER_VIEW_SECTION 0

@interface CPTileCollectionViewDataSource ()
@property (strong, nonatomic) NSMutableArray<CPTile *> *tiles;
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CPTileViewCell *cell;
@property (strong, nonatomic) CPTableHeaderView *tableHeaderView;

@property (assign, nonatomic) CGFloat headerImageHeight;
@property (assign, nonatomic) CGFloat headerStatsHeight;
@end

@implementation CPTileCollectionViewDataSource {

}

- (instancetype)initWithCollectionView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width / (640.0/262.0);
        
        self.headerImageHeight = height;
        self.headerStatsHeight = 140;
        
        self.tableHeaderView = [[CPTableHeaderView alloc] initWithImage:[UIImage imageNamed:@"vallhund"] frame:CGRectMake(0, 0, width, height)];

        [tableView registerNib:[UINib nibWithNibName:@"CPTileViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:TILE_VIEW_CELL];
        [tableView registerNib:[UINib nibWithNibName:@"CPPetStatsView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:PET_STATS_HEADER];
        [tableView registerNib:[UINib nibWithNibName:@"CPMainTableSectionHeader" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:SECTION_HEADER];
    }

    return self;
}

- (void)postInit
{
    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableHeaderView scrollViewDidScroll:scrollView];
        
    CGFloat fade = MIN(1, MAX(0, scrollView.contentOffset.y - self.headerImageHeight) / self.headerStatsHeight);
    
    [self.scrollDelegate dataSource:self headerPhotoVisible:scrollView.contentOffset.y < self.headerImageHeight - 4 headerStatsFade:fade];
}

- (void)addTile:(CPTile *)tile {
    NSUInteger index = [self.tiles indexOfObject:tile inSortedRange:NSMakeRange(0, self.tiles.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CPTile *a, CPTile *b) {
        return -[a.date compare:b.date];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tiles insertObject:tile atIndex:index];
    [self.tableView endUpdates];
}

- (NSMutableArray *)tiles {
    if (!_tiles) {
        _tiles = [[NSMutableArray alloc] init];
    }

    return _tiles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HEADER_VIEW_SECTION) {
        return 0;
    } else {
        return self.tiles.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPTileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TILE_VIEW_CELL];
    CPTile *tile = self.tiles[(NSUInteger) indexPath.item];
    cell.tile = tile;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == HEADER_VIEW_SECTION) {
        return [tableView dequeueReusableHeaderFooterViewWithIdentifier:PET_STATS_HEADER];
    } else {
        return [tableView dequeueReusableHeaderFooterViewWithIdentifier:SECTION_HEADER];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == HEADER_VIEW_SECTION) {
        return self.headerStatsHeight;
    } else {
        return 50;
    }
}

@end