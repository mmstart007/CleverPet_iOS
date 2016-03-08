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
#import "CPMainTableSectionHeaderFilter.h"
#import "CPTileCommunicationManager.h"

#define TILE_VIEW_CELL @"TILE_VIEW_CELL"
#define PET_STATS_HEADER @"PET_STATS_HEADER"
#define SECTION_HEADER @"SECTION_HEADER"
#define DATE_HEADER @"DATE_HEADER"
#define HEADER_VIEW_SECTION 0

CGFloat const kPagingThreshhold = 100.f;

@interface CPTileCollectionViewDataSource () <CPTileViewCellDelegate, CPMainTableSectionHeaderDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CPTileViewCell *sizingCell;
@property (strong, nonatomic) CPTableHeaderView *tableHeaderView;

@property (assign, nonatomic) CGFloat headerImageHeight;
@property (assign, nonatomic) CGFloat headerStatsHeight;

@property (strong, nonatomic) NSMutableArray<CPTileViewCell *> *precachedTableViewCells;

@property (strong, nonatomic) NSArray<CPMainTableSectionHeaderFilter *> *filters;
@property (strong, nonatomic) CPMainTableSectionHeaderFilter *currentFilter;
@property (strong, nonatomic) NSMutableDictionary<CPMainTableSectionHeaderFilter *, CPTileDataManager *> *tileDataManagers;
@property (nonatomic, weak) UIActivityIndicatorView *footerSpinner;
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
        
        [self precacheTableViewCells];
        [self setupTableFooter];
        
        self.filters = @[
                         [CPMainTableSectionHeaderFilter filterWithName:@"Latest"],
                         [CPMainTableSectionHeaderFilter filterWithName:@"Reports"],
                         [CPMainTableSectionHeaderFilter filterWithName:@"Videos"],
                         [CPMainTableSectionHeaderFilter filterWithName:@"Challenges"]
                         ];
        
        self.currentFilter = self.filters[0];
        
        self.tileDataManagers = [[NSMutableDictionary alloc] init];
        // TODO: clean this up
        self.tileDataManagers[self.filters[0]] = [[CPTileDataManager alloc] initWithFilter:nil];
        self.tileDataManagers[self.filters[1]] = [[CPTileDataManager alloc] initWithFilter:@"report"];
        self.tileDataManagers[self.filters[2]] = [[CPTileDataManager alloc] initWithFilter:@"video"];
        self.tileDataManagers[self.filters[3]] = [[CPTileDataManager alloc] initWithFilter:@"challenge"];
        for (CPMainTableSectionHeaderFilter *filter in self.filters) {
            // Run through our refresh call for the first manager so we populate the table. Call refresh on the others so their content is ready when we change between filters
            if ([filter isEqualToFilter:self.currentFilter]) {
                [self refreshTilesWithAnimation:YES];
            } else {
                [self.tileDataManagers[filter] refreshTiles:nil];
            }
        }
    }
    
    return self;
}

- (void)setupTableFooter
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40.f)];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:logo];
    // center image in footer
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:logo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:logo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [view addConstraints:@[centerX, centerY]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor appGreyColor];
    spinner.hidesWhenStopped = YES;
    spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:spinner];
    self.footerSpinner = spinner;
    NSLayoutConstraint *spinnerCenterY = [NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *spinnerSpacing = [NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:logo attribute:NSLayoutAttributeLeading multiplier:1 constant:-10];
    [view addConstraints:@[spinnerCenterY, spinnerSpacing]];
    
    self.tableView.tableFooterView = view;
}

- (CPTileDataManager *)currentTileDataManager {
    return self.tileDataManagers[self.currentFilter];
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
    
    [self.delegate dataSource:self
                 headerPhotoVisible:scrollView.contentOffset.y < self.headerImageHeight - 4
                    headerStatsFade:fade];
    
    // TODO: loading section
    // TODO: trigger page if our initial content size is less than our bounds, and we have more tiles
    // Start paging if we've reached our threshhold
    if ([self.tileDataManagers[self.currentFilter] allowPaging]) {
        CGFloat offsetY = scrollView.contentOffset.y + scrollView.bounds.size.height;
        if (scrollView.contentSize.height - offsetY < kPagingThreshhold) {
            [self pageMoreTilesWithAnimation:YES];
        }
    }
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

- (void)addTiles:(NSIndexSet *)tileIndexes withAnimation:(BOOL)withAnimation {
    UITableViewRowAnimation animation;
    
    if (withAnimation) {
        animation = UITableViewRowAnimationAutomatic;
    } else {
        animation = UITableViewRowAnimationNone;
    }
    
    [self.tableView beginUpdates];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [tileIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:1]];
    }];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)deleteTile:(CPTile *)tile withAnimation:(BOOL)withAnimation {
    NSIndexSet *deletedIndexes = [self.currentTileDataManager deleteTile:tile];
    
    // Only need to animate changes if there were changes.
    if (deletedIndexes.count > 0) {
        UITableViewRowAnimation animation;
        
        if (withAnimation) {
            animation = UITableViewRowAnimationAutomatic;
        } else {
            animation = UITableViewRowAnimationNone;
        }
        
        NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
        [deletedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:1]];
        }];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)updatePetImage:(UIImage *)petImage
{
    [self.tableHeaderView updateImage:petImage];
}

- (void)videoPlaybackCompletedForTile:(CPTile *)tile
{
    // Inform the server video playback completed for the tile. We don't care if this was successful or not
    [[CPTileCommunicationManager sharedInstance] handleButtonPressWithPath:tile.secondaryButtonUrl completion:nil];
}

#pragma mark - UITableView delegate and data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HEADER_VIEW_SECTION) {
        return 0;
    } else {
        return [self.currentTileDataManager rowCount];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *innerIndexPath = [self.currentTileDataManager indexPathFromCellIndex:indexPath.row];
    
    if (innerIndexPath.row == NSNotFound) {
        // Header type cell
        CPSimpleDate *tileHeader = [self.currentTileDataManager sectionHeaderAtIndex:innerIndexPath.section];
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
        
        CPTile *tile = [self.currentTileDataManager tileForInternalIndexPath:innerIndexPath];
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
                [sectionHeader addFilter:filter withColor:filter.color];
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
        NSIndexPath *internalIndexPath = [self.currentTileDataManager indexPathFromCellIndex:indexPath.row];
        if (internalIndexPath.row == NSNotFound) {
            return 50;
        } else {
            // TODO: separate cache for each filter
            CPTile *tile = [self.currentTileDataManager tileForInternalIndexPath:internalIndexPath];
            if (tile.cachedRowHeight != 0) {
                return tile.cachedRowHeight;
            }
            
            if (!self.sizingCell) {
                self.sizingCell = [self.tableView dequeueReusableCellWithIdentifier:TILE_VIEW_CELL];
                NSLayoutConstraint *layoutConstraint = [NSLayoutConstraint constraintWithItem:self.sizingCell.contentView
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                   multiplier:1.0
                                                                                     constant:[UIScreen mainScreen].bounds.size.width];
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
        [self.tableView reloadData];
    }
}

#pragma mark - CPTileViewCellDelegate methods

- (void)didSwipeTileViewCell:(CPTileViewCell *)tileViewCell {
    // We don't particularly care about success or failure here, so just update the ui
    [[CPTileCommunicationManager sharedInstance] handleTileSwipe:tileViewCell.tile.tileId completion:nil];
    [self deleteTile:tileViewCell.tile withAnimation:YES];
}

- (void)playVideoForCell:(CPTileViewCell *)tileViewCell
{
    [self.delegate playVideoForTile:tileViewCell.tile];
}

#pragma mark - Data source management
// TODO: kill page if we refresh
- (void)refreshTilesWithAnimation:(BOOL)withAnimation
{
    [self.footerSpinner startAnimating];
    CPTileDataManager *currentManager = self.tileDataManagers[self.currentFilter];
    BLOCK_SELF_REF_OUTSIDE();
    [currentManager refreshTiles:^(NSIndexSet *indexes, NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        [self.footerSpinner stopAnimating];
        if (error) {
            // TODO: display error
        } else if (currentManager == self.tileDataManagers[self.currentFilter]) {
            // TODO: animate from old data to new data instead of refresh?
            [self.tableView reloadData];
        }
    }];
}

- (void)pageMoreTilesWithAnimation:(BOOL)withAnimation
{
    [self.footerSpinner startAnimating];
    CPTileDataManager *currentManager = self.tileDataManagers[self.currentFilter];
    BLOCK_SELF_REF_OUTSIDE();
    [currentManager pageMoreTiles:^(NSIndexSet *indexes, NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        [self.footerSpinner stopAnimating];
        if (error) {
            // TODO: display error
        } else if (currentManager == self.tileDataManagers[self.currentFilter]) {
            [self addTiles:indexes withAnimation:YES];
        }
    }];
}

@end