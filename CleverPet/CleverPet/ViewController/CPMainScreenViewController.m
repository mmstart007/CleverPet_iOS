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
#import "CPUserManager.h"

@interface CPMainScreenViewController () <UICollectionViewDelegate, CPTileCollectionViewDataSourceScrollDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CPTileCollectionViewDataSource *dataSource;
@property (strong, nonatomic) CPPetStatsView *petStatsView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) CPMainScreenHeaderView *mainScreenHeaderView;
@property (strong, nonatomic) CPMainScreenStatsHeaderView *mainScreenStatsHeaderView;

@property (nonatomic, strong) CPPet *currentPet;
@end

@implementation CPMainScreenViewController {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentPet = [[CPUserManager sharedInstance] getCurrentUser].pet;
    
    self.tableView.backgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    
    self.mainScreenHeaderView = [CPMainScreenHeaderView loadFromNib];
    [self.mainScreenHeaderView setupForPet:self.currentPet];
    self.mainScreenStatsHeaderView = [CPMainScreenStatsHeaderView loadFromNib];
    self.mainScreenStatsHeaderView.imageView.image = [self.currentPet petPhoto];;
    
    [self.headerView addSubview:self.mainScreenHeaderView];
    [self.headerView addSubview:self.mainScreenStatsHeaderView];
    self.headerView.clipsToBounds = NO;

    self.mainScreenStatsHeaderView.alpha = 0;
    
    CPTileCollectionViewDataSource *dataSource = [[CPTileCollectionViewDataSource alloc] initWithCollectionView:self.tableView andPetImage:[self.currentPet petPhoto]];
    dataSource.scrollDelegate = self;

    self.dataSource = dataSource;
    self.tableView.delegate = dataSource;
    self.tableView.dataSource = dataSource;
    
    [dataSource postInit];
    
    NSDate *startDate = [NSDate date];
    for (NSUInteger i = 0; i < 100; i++) {
        NSDate *date = [startDate dateByAddingTimeInterval:-60.0 * 60.0 * 4 * i];
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
    
    if (self.mainScreenHeaderView.alpha != headerStatsFade) {
        self.mainScreenStatsHeaderView.alpha = headerStatsFade;
    }
    
    double alphaValue = pow((1 - headerStatsFade), 2);
    if (self.mainScreenHeaderView.alpha != alphaValue) {
        self.mainScreenHeaderView.alpha = alphaValue;
    }
}

- (void)addTileForDate:(NSDate *)date index:(NSUInteger)index
{
    CPTile *tile = [[CPTile alloc] init];
    tile.date = date;
    
    switch (index % 4) {
        case 0:
            tile.tileType = CPTTChallenge;
            tile.negativeButtonText = @"Restart";
            tile.title = @"Challenge 9: Learning double sequence";
            tile.body = @"Your pup is learning a sequence of lights -- s/he'll need to trigger the touchpads in the order the lights come on.";
            break;
        case 1:
            tile.tileType = CPTTMessage;
            tile.title = @"Hands off, paws only!";
            tile.affirmativeButtonText = @"Got it.";
            tile.negativeButtonText = @"Explain.";
            tile.body = @"Do not touch the touchpads for your dog as he is learning.";
            break;
        case 2:
            tile.tileType = CPTTMessage;
            tile.title = @"Challenge Met!";
            tile.affirmativeButtonText = @"Ok";
            tile.body = @"Your pup solved multiple puzzles made from sequences of three lighted touchpads! Give your dog extra scritches!";
            tile.image = [UIImage imageNamed:@"award"];
            break;
        case 3:
            tile.tileType = CPTTMessage;
            tile.title = @"Silly human, touchpads are for dogs!";
            tile.body = @"From now on, the Hub is set to respond to your dog's actions. If you touch the touchpads, it may impact the accuracy of your dog's progress, and slow your dog's learning.";
            break;
    }
    
    [self.dataSource addTile:tile withAnimation:NO];
}
@end