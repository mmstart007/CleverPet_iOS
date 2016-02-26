//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileCollectionViewDataSource.h"
#import "CPTile.h"
#import "CPTileViewCell.h"
#import "CPTableHeaderView.h"
#import "CPTileDataManager.h"
#import "CPMainTableSectionHeader.h"

#define TILE_VIEW_CELL @"TILE_VIEW_CELL"
#define PET_STATS_HEADER @"PET_STATS_HEADER"
#define SECTION_HEADER @"SECTION_HEADER"
#define HEADER_VIEW_SECTION 0

@interface CPTileCollectionViewDataSource ()
@property (strong, nonatomic) CPTileDataManager *tileDataManager;
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CPTileViewCell *cell;
@property (strong, nonatomic) CPTableHeaderView *tableHeaderView;

@property (assign, nonatomic) CGFloat headerImageHeight;
@property (assign, nonatomic) CGFloat headerStatsHeight;
@end

@implementation CPTileCollectionViewDataSource {

}

- (instancetype)initWithCollectionView:(UITableView *)tableView andPetImage:(UIImage *)petImage {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width / (640.0f/262.0f);
        
        self.headerImageHeight = height;
        self.headerStatsHeight = 140;
        
        self.tableHeaderView = [[CPTableHeaderView alloc] initWithImage:petImage frame:CGRectMake(0, 0, width, height)];

        [tableView registerNib:[UINib nibWithNibName:@"CPTileViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:TILE_VIEW_CELL];
        [tableView registerNib:[UINib nibWithNibName:@"CPPetStatsView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:PET_STATS_HEADER];
        [tableView registerNib:[UINib nibWithNibName:@"CPMainTableSectionHeader" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:SECTION_HEADER];
        
        self.tileDataManager = [[CPTileDataManager alloc] init];
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

- (void)addTile:(CPTile *)tile withAnimation:(BOOL)withAnimation {
    CPInsertionInfo insertionInfo = [self.tileDataManager addTile:tile];
    
    if (withAnimation) {
        [self.tableView beginUpdates];
        
        if (insertionInfo.isNewSection && insertionInfo.sectionIndex != NSNotFound) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:insertionInfo.sectionIndex + 1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (insertionInfo.rowIndex != NSNotFound) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:insertionInfo.rowIndex inSection:insertionInfo.sectionIndex + 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [self.tileDataManager sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HEADER_VIEW_SECTION) {
        return 0;
    } else {
        return [self.tileDataManager tileCountForSection:section - 1];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPTileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TILE_VIEW_CELL];
    CPTile *tile = [self.tileDataManager tileForRow:indexPath.row inSection:indexPath.section - 1];
    cell.tile = tile;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == HEADER_VIEW_SECTION) {
        return [tableView dequeueReusableHeaderFooterViewWithIdentifier:PET_STATS_HEADER];
    } else {
        CPMainTableSectionHeader *sectionHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SECTION_HEADER];
        CPSimpleDate *sectionHeaderDate = [self.tileDataManager sectionHeaderAtIndex:section - 1];
        sectionHeader.sectionHeaderLabel.text = [NSString stringWithFormat:@"%@/%@/%@", @(sectionHeaderDate.year), @(sectionHeaderDate.month), @(sectionHeaderDate.day)];
        return sectionHeader;
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