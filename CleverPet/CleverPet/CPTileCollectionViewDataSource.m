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
@property (strong, nonatomic) CPTileViewCell *sizingCell;
@property (strong, nonatomic) CPTableHeaderView *tableHeaderView;

@property (assign, nonatomic) CGFloat headerImageHeight;
@property (assign, nonatomic) CGFloat headerStatsHeight;

@property (strong, nonatomic) NSMutableArray<CPTileViewCell *> *precachedTableViewCells;
@end

@implementation CPTileCollectionViewDataSource {

}

- (instancetype)initWithCollectionView:(UITableView *)tableView andPetImage:(UIImage *)petImage {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width / (640.0f/262.0f);
        
        self.headerImageHeight = height;
        self.headerStatsHeight = 140;
        
        self.tableHeaderView = [[CPTableHeaderView alloc] initWithImage:petImage frame:CGRectMake(0, 0, width, height)];

        [tableView registerNib:[UINib nibWithNibName:@"CPTileViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:TILE_VIEW_CELL];
        [tableView registerNib:[UINib nibWithNibName:@"CPPetStatsView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:PET_STATS_HEADER];
        [tableView registerNib:[UINib nibWithNibName:@"CPMainTableSectionHeader" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:SECTION_HEADER];
        
        self.tileDataManager = [[CPTileDataManager alloc] init];
        
        [self precacheTableViewCells];
    }

    return self;
}

- (void)precacheTableViewCells {
    self.precachedTableViewCells = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 100; i++) {
        [self.precachedTableViewCells addObject:[self.tableView dequeueReusableCellWithIdentifier:TILE_VIEW_CELL]];
    }
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

NSString *FormatSimpleDateForRelative(CPSimpleDate *simpleDate) {
    static NSCalendar *s_calendar = nil;
    static NSDateFormatter *s_dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_calendar = [NSCalendar autoupdatingCurrentCalendar];
        s_dateFormatter = [[NSDateFormatter alloc] init];
        [s_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [s_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [s_dateFormatter setDoesRelativeDateFormatting:YES];
    });
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.timeZone = [NSTimeZone localTimeZone];
    dateComponents.year = simpleDate.year;
    dateComponents.month = simpleDate.month;
    dateComponents.day = simpleDate.day;
    
    NSDate *date = [s_calendar dateFromComponents:dateComponents];
    return [s_dateFormatter stringFromDate:date];
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
    CPTileViewCell *cell = [self.precachedTableViewCells lastObject];
    if (cell) {
        [self.precachedTableViewCells removeLastObject];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:TILE_VIEW_CELL];
    }
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
        sectionHeader.sectionHeaderLabel.text = FormatSimpleDateForRelative(sectionHeaderDate);
        return sectionHeader;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == HEADER_VIEW_SECTION) {
        return self.headerStatsHeight;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == HEADER_VIEW_SECTION) {
        return 0;
    } else {
        CPTile *tile = [self.tileDataManager tileForRow:indexPath.row inSection:indexPath.section - 1];
        
        if (tile.cachedRowHeight != 0) {
            return tile.cachedRowHeight;
        }
        
        if (!self.sizingCell) {
            self.sizingCell = [self.tableView dequeueReusableCellWithIdentifier:TILE_VIEW_CELL];
            NSLayoutConstraint *layoutConstraint = [NSLayoutConstraint constraintWithItem:self.sizingCell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:[UIScreen mainScreen].bounds.size.width];
            [self.sizingCell.contentView addConstraint:layoutConstraint];
        }
        
        self.sizingCell.tile = tile;
        
        CGSize size = [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        tile.cachedRowHeight = size.height;
        return size.height;
    }
}

@end