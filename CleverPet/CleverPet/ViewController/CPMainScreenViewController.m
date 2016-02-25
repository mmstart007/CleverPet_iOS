//
// Created by Daryl at Finger Foods on 2016-02-16.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainScreenViewController.h"
#import "CPTileCollectionViewDataSource.h"
#import "CPTile.h"
#import "CPPetStatsView.h"
#import "CPMainScreenHeaderView.h"
#import "CPMainScreenStatsHeaderView.h"
#import "UIView+CPShadowEffect.h"

@interface CPMainScreenViewController () <UICollectionViewDelegate, CPTileCollectionViewDataSourceScrollDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CPTileCollectionViewDataSource *dataSource;
@property (strong, nonatomic) CPPetStatsView *petStatsView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) CPMainScreenHeaderView *mainScreenHeaderView;
@property (strong, nonatomic) CPMainScreenStatsHeaderView *mainScreenStatsHeaderView;
@end

@implementation CPMainScreenViewController {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.backgroundColor = [UIColor appBackgroundColor];

    self.mainScreenHeaderView = [CPMainScreenHeaderView loadFromNib];
    self.mainScreenStatsHeaderView = [CPMainScreenStatsHeaderView loadFromNib];
    self.mainScreenStatsHeaderView.imageView.image = [UIImage imageNamed:@"vallhund"];
    
    [self.headerView addSubview:self.mainScreenHeaderView];
    [self.headerView addSubview:self.mainScreenStatsHeaderView];
    self.headerView.clipsToBounds = NO;

    self.mainScreenStatsHeaderView.alpha = 0;
    
    CPTileCollectionViewDataSource *dataSource = [[CPTileCollectionViewDataSource alloc] initWithCollectionView:self.tableView];
    dataSource.scrollDelegate = self;

    self.dataSource = dataSource;
    self.tableView.delegate = dataSource;
    self.tableView.dataSource = dataSource;
    
    [dataSource postInit];
    
    NSDate *startDate = [NSDate date];
    for (NSUInteger i = 0; i < 100; i++) {
        NSDate *date = [startDate dateByAddingTimeInterval:-60.0 * i];
        [self addTileForDate:date index:i];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)dataSource:(CPTileCollectionViewDataSource *)dataSource headerPhotoVisible:(BOOL)headerPhotoVisible headerStatsFade:(CGFloat)headerStatsFade
{
    if (!headerPhotoVisible) {
        [self.headerView applyCleverPetShadow];
    } else {
        [self.headerView removeCleverPetShadow];
    }
    
    self.mainScreenStatsHeaderView.alpha = headerStatsFade;
    self.mainScreenHeaderView.alpha = pow((1 - headerStatsFade), 2);
}

- (void)addTileForDate:(NSDate *)date index:(NSUInteger)index
{
    CPTile *tile = [[CPTile alloc] init];
    tile.date = date;
    
    tile.tileType = index % CPTTMac;
    switch (tile.tileType) {
        case CPTTChallenge:
            tile.negativeButtonText = @"Restart";
            tile.title = @"Challenge 9: The Challenging";
            tile.body = @"Here's an example of a *Challenge* tile! Challenge your dog with this challenge!";
            break;
        case CPTTMessage:
            tile.title = @"Hands off, paws only!";
            tile.affirmativeButtonText = @"Got it.";
            tile.negativeButtonText = @"Explain.";
            tile.body = @"Do not touch the touchpads for Bagel as he is learning.";
            break;
        case CPTTReport:
            tile.affirmativeButtonText = @"Read";
            tile.body = @"Here's a report for your dog!\n\n- He ate 57 kibble!\n- He did 32 plays!\n- His lifetime score increased by 200!";
            break;
        case CPTTMac:
            break;
    }
    
    [self.dataSource addTile:tile];
}
@end