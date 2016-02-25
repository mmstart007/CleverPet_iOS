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
        [self addTileForDate:date];
    }
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

- (void)addTileForDate:(NSDate *)date
{
    CPTile *tile = [[CPTile alloc] init];
    tile.date = date;
    
    switch (arc4random_uniform(3)) {
        case 0:
            tile.title = @"Let's try CleverPet!";
            break;
        case 1:
            tile.title = @"Get your dog ready!";
            break;
        case 2:
            tile.title = @"CleverPet is empty!";
            break;
    }
    
    switch (arc4random_uniform(3)) {
        case 0:
            tile.body = [NSString stringWithFormat:@"Hey this is my *message body*! *Bacon* ipsum dolor amet *spare ribs* drumstick short ribs ham, shank hamburger ham hock leberkas tri-tip pig doner kielbasa bresaola fatback. Spare ribs landjaeger shoulder venison, pork belly short ribs jerky pastrami pork hamburger pork loin. Alcatra beef ribeye prosciutto rump. Turducken drumstick salami capicola pork chop jerky beef bresaola biltong picanha shoulder hamburger pork short loin. Filet mignon pastrami meatloaf tongue. Shank sirloin salami biltong jerky shoulder chicken corned beef, pastrami tongue sausage beef ribs chuck pork kielbasa."];
            break;
        case 1:
            tile.body = [NSString stringWithFormat:@"Hey this is my *message body*!"];
            break;
        case 2:
            tile.body = [NSString stringWithFormat:@"- Make sure your dog is around\n- Make sure your dog is hungry\n- Get your dog to eat!"];
            break;
    }
    
    tile.tileType = arc4random_uniform(CPTTMac);
    
    if (arc4random_uniform(2)) {
//        tile.image = [UIImage imageNamed:@"vallhund"];
    }
    
    tile.hasLeftButton = arc4random_uniform(2) != 0;
    tile.hasRightButton = arc4random_uniform(2) != 0;
    
    [self.dataSource addTile:tile];
}
@end