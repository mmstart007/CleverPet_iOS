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
#import "CPMainTableDateHeader.h"

#define TILE_VIEW_CELL @"TILE_VIEW_CELL"
#define PET_STATS_HEADER @"PET_STATS_HEADER"
#define SECTION_HEADER @"SECTION_HEADER"
#define DATE_HEADER @"DATE_HEADER"
#define HEADER_VIEW_SECTION 0

@interface CPTileCollectionViewDataSource () <CPTileViewCellDelegate, CPMainTableSectionHeaderDelegate>
@property (strong, nonatomic) CPTileDataManager *tileDataManager;
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CPTileViewCell *sizingCell;
@property (strong, nonatomic) CPTableHeaderView *tableHeaderView;

@property (assign, nonatomic) CGFloat headerImageHeight;
@property (assign, nonatomic) CGFloat headerStatsHeight;

@property (strong, nonatomic) NSMutableArray<CPTileViewCell *> *precachedTableViewCells;

@property (strong, nonatomic) NSArray<CPMainTableSectionHeaderFilter *> *filters;
@property (strong, nonatomic) CPMainTableSectionHeaderFilter *currentFilter;
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
        [tableView registerNib:[UINib nibWithNibName:@"CPMainTableDateHeader" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:DATE_HEADER];
        
        [tableView registerNib:[UINib nibWithNibName:@"CPPetStatsView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:PET_STATS_HEADER];
        [tableView registerNib:[UINib nibWithNibName:@"CPMainTableSectionHeader" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:SECTION_HEADER];
        
        self.tileDataManager = [[CPTileDataManager alloc] init];
        
        [self precacheTableViewCells];
        
        self.filters = @[
                         [CPMainTableSectionHeaderFilter filterWithName:@"Reports"],
                         [CPMainTableSectionHeaderFilter filterWithName:@"Videos"],
                         [CPMainTableSectionHeaderFilter filterWithName:@"Device Messages"]
                         ];
        
        self.currentFilter = self.filters[0];
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
    NSIndexSet *indexSet = [self.tileDataManager addTile:tile];
    UITableViewRowAnimation animation;
    
    if (withAnimation) {
        animation = UITableViewRowAnimationAutomatic;
    } else {
        animation = UITableViewRowAnimationNone;
        }
        
    [self.tableView beginUpdates];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:1]];
    }];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        [self.tableView endUpdates];
    }

- (void)updatePetImage:(UIImage *)petImage
{
    [self.tableHeaderView updateImage:petImage];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HEADER_VIEW_SECTION) {
        return 0;
    } else {
        return [self.tileDataManager rowCount];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *innerIndexPath = [self.tileDataManager indexPathFromCellIndex:indexPath.row];

    if (innerIndexPath.row == NSNotFound) {
        // Header type cell
        CPSimpleDate *tileHeader = [self.tileDataManager sectionHeaderAtIndex:innerIndexPath.section];
        CPMainTableDateHeader *sectionHeader = [tableView dequeueReusableCellWithIdentifier:DATE_HEADER];
        sectionHeader.mainLabel.text = FormatSimpleDateForRelative(tileHeader);
        return sectionHeader;
    } else {
    CPTileViewCell *cell = [self.precachedTableViewCells lastObject];
    if (cell) {
        [self.precachedTableViewCells removeLastObject];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:TILE_VIEW_CELL];
    }
        
        CPTile *tile = [self.tileDataManager tileForInternalIndexPath:innerIndexPath];
    cell.tile = tile;
    cell.delegate = self;
    return cell;
}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == HEADER_VIEW_SECTION) {
        return [tableView dequeueReusableHeaderFooterViewWithIdentifier:PET_STATS_HEADER];
    } else {
        CPMainTableSectionHeader *sectionHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SECTION_HEADER];
        sectionHeader.delegate = self;
        
        if (!sectionHeader.hasFiltersSetup) {
            for (CPMainTableSectionHeaderFilter *filter in self.filters) {
                [sectionHeader addFilter:filter];
            }
            
            sectionHeader.hasFiltersSetup = YES;
        }
        
        [sectionHeader setCurrentFilterObject:self.currentFilter withAnimation:NO];
        
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
        NSIndexPath *internalIndexPath = [self.tileDataManager indexPathFromCellIndex:indexPath.row];
        if (internalIndexPath.row == NSNotFound) {
            return 50;
        } else {
            CPTile *tile = [self.tileDataManager tileForInternalIndexPath:internalIndexPath];
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
}

#pragma mark - CPMainTableSectionHeaderDelegate

- (void)sectionHeader:(CPMainTableSectionHeader *)sectionHeader didChangeToFilter:(CPMainTableSectionHeaderFilter *)filter {
    if (self.currentFilter != filter) {
        self.currentFilter = filter;
        NSLog(@"%@", filter.filterName);
        [self.tableView reloadData];
    }
}

#pragma mark - CPTileViewCellDelegate methods

- (void)didSwipeTileViewCell:(CPTileViewCell *)tileViewCell {
    // TODO: Get rid of the tile here
}
@end