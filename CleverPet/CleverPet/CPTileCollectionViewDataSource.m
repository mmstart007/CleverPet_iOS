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
#import "CPFirebaseManager.h"

#define TILE_VIEW_CELL @"TILE_VIEW_CELL"
#define PET_STATS_HEADER @"PET_STATS_HEADER"
#define SECTION_HEADER @"SECTION_HEADER"
#define DATE_HEADER @"DATE_HEADER"
#define HEADER_VIEW_SECTION 0

CGFloat const kPagingThreshhold = 300.f;

@interface CPTileCollectionViewDataSource () <CPTileViewCellDelegate, CPMainTableSectionHeaderDelegate, CPTileDataManagerDelegate>
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
@property (nonatomic, weak) UIImageView *footerIcon;
//@property (nonatomic, strong) CPTileUpdateListener *tileUpdateListener;
@property (strong, nonatomic) FirebaseManagerHandle tileUpdateHandle;
@property (nonatomic, assign) BOOL shouldRefresh;

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
                         [CPMainTableSectionHeaderFilter filterWithName:@"Videos"],
                         [CPMainTableSectionHeaderFilter filterWithName:@"Challenges"],
                         [CPMainTableSectionHeaderFilter filterWithName:@"Reports"]
                         ];
        
        self.currentFilter = self.filters[0];
        
        self.tileDataManagers = [[NSMutableDictionary alloc] init];
        // TODO: clean this up
        self.tileDataManagers[self.filters[0]] = [[CPTileDataManager alloc] initWithFilter:nil];
        self.tileDataManagers[self.filters[1]] = [[CPTileDataManager alloc] initWithFilter:@"video"];
        self.tileDataManagers[self.filters[2]] = [[CPTileDataManager alloc] initWithFilter:@"challenge"];
        self.tileDataManagers[self.filters[3]] = [[CPTileDataManager alloc] initWithFilter:@"report"];
        
        for (CPTileDataManager *tileDataManager in self.tileDataManagers.allValues) {
            tileDataManager.delegate = self;
        }
        
        BLOCK_SELF_REF_OUTSIDE()
        self.tileUpdateHandle = [[CPFirebaseManager sharedInstance] subscribeToTilesWithBlock:^(NSError *error, CPTile *tile) {
            BLOCK_SELF_REF_INSIDE();
            for (CPMainTableSectionHeaderFilter *filter in self.filters) {
                // Inform data managers that their next refresh needs to be forced and refresh the current
                CPTileDataManager *dataManager = self.tileDataManagers[filter];
                
                [dataManager updateTile:tile];
            }
        }];
        
        // Listen for pet gender/name updates
        REG_SELF_FOR_NOTIFICATION(kPetInfoUpdated, petInfoUpdated:);
    }
    
    return self;
}

- (void)setupTableFooter
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 60.f)];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:logo];
    self.footerIcon = logo;
    // center image in footer
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:logo attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-8];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:logo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [view addConstraints:@[centerX, centerY]];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor appGreyColor];
    spinner.hidesWhenStopped = YES;
    spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:spinner];
    self.footerSpinner = spinner;
    NSLayoutConstraint *spinnerCenterY = [NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *spinnerCenterX = [NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [view addConstraints:@[spinnerCenterY, spinnerCenterX]];
    
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
    
    [self refreshTilesWithAnimation:YES];
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

- (void)tileDataManager:(CPTileDataManager *)dataManager didDeleteRows:(NSIndexSet *)deletedRows updateRows:(NSIndexSet *)updatedRows insertRows:(NSIndexSet *)insertedRows fromRefresh:(BOOL)isFromRefresh
{
    if (self.currentTileDataManager == dataManager) {
        [self.tableView beginUpdates];
        
        if (deletedRows.count > 0) {
            [self.tableView deleteRowsAtIndexPaths:[self indexPathsFromIndexSet:deletedRows] withRowAnimation:isFromRefresh ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationRight];
        }
        
        if (updatedRows.count > 0) {
            [self.tableView reloadRowsAtIndexPaths:[self indexPathsFromIndexSet:updatedRows] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        if (insertedRows.count > 0) {
            [self.tableView insertRowsAtIndexPaths:[self indexPathsFromIndexSet:insertedRows] withRowAnimation:isFromRefresh ? UITableViewRowAnimationFade : UITableViewRowAnimationLeft];
        }
        
        [self.tableView endUpdates];
    }
    
    [self animateFooterSpinner:NO];
}

- (void)tileDataManager:(CPTileDataManager *)dataManager encounteredRefreshError:(NSError *)error
{
    [self animateFooterSpinner:NO];
}

- (NSArray<NSIndexPath *> *)indexPathsFromIndexSet:(NSIndexSet *)indexSet
{
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:1]];
    }];
    
    return [indexPaths copy];
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

- (void)viewBecomingVisible
{
    [self.tableView reloadData];
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
        [cell setTile:tile forSizing:NO allowSwiping:self.currentFilter == self.filters[0]];
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
            
            [self.sizingCell setTile:tile forSizing:YES allowSwiping:YES];
            
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
        [self refreshTilesWithAnimation:YES];
    }
}

#pragma mark - CPTileViewCellDelegate methods

- (void)didSwipeTileViewCell:(CPTileViewCell *)tileViewCell {
    CPTile *requestTile = tileViewCell.tile;
    BLOCK_SELF_REF_OUTSIDE();
    [[CPTileCommunicationManager sharedInstance] handleTileSwipe:tileViewCell.tile.tileId completion:^(NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (error) {
            [self.delegate displayError:error];
            if ([requestTile.tileId isEqualToString:tileViewCell.tile.tileId]) {
                [tileViewCell resetSwipeState];
            }
        }
    }];
}

- (void)playVideoForCell:(CPTileViewCell *)tileViewCell
{
    [self.delegate playVideoForTile:tileViewCell.tile];
}

- (void)displayError:(NSError *)error
{
    [self.delegate displayError:error];
}

#pragma mark - Data source management
// TODO: kill page if we refresh
- (void)refreshTilesWithAnimation:(BOOL)withAnimation
{
    self.shouldRefresh = NO;
    [self animateFooterSpinner:YES];
    CPTileDataManager *currentManager = self.tileDataManagers[self.currentFilter];
    BOOL didClearData = [currentManager refreshTiles:NO];
    
    if (didClearData) {
        // If our data manager cleared it's backing data, reload the table so we just show the loading spinner
        [self.tableView reloadData];
    }
}

- (void)pageMoreTilesWithAnimation:(BOOL)withAnimation
{
    [self animateFooterSpinner:YES];
    CPTileDataManager *currentManager = self.tileDataManagers[self.currentFilter];
    [currentManager pageMoreTiles];
}

- (void)animateFooterSpinner:(BOOL)animate
{
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        if (animate) {
            [self.footerSpinner startAnimating];
        } else {
            [self.footerSpinner stopAnimating];
        }
        self.footerIcon.hidden = animate;
    } completion:nil];
}

#pragma mark - CPTileUpdateDelegate methods
- (void)dealloc {
    [[CPFirebaseManager sharedInstance] unsubscribeFromHandle:self.tileUpdateHandle];
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
}

- (void)petInfoUpdated:(NSNotification*)notification
{
    for (CPMainTableSectionHeaderFilter *filter in [self.tileDataManagers allKeys]) {
        [self.tileDataManagers[filter] petInfoUpdated];
    }
}

@end