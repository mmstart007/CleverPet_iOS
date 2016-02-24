//
// Created by Daryl at Finger Foods on 2016-02-16.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainScreenViewController.h"
#import "CPTileCollectionViewDataSource.h"
#import "CPTile.h"

@interface CPMainScreenViewController () <UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CPTileCollectionViewDataSource *dataSource;
@end

@implementation CPMainScreenViewController {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.backgroundColor = [UIColor appBackgroundColor];

    CPTileCollectionViewDataSource *dataSource = [[CPTileCollectionViewDataSource alloc] initWithCollectionView:self.tableView];

    self.dataSource = dataSource;
    self.tableView.delegate = dataSource;
    self.tableView.dataSource = dataSource;
    
    NSDate *startDate = [NSDate date];
    for (NSUInteger i = 0; i < 1000; i++) {
        NSDate *date = [startDate dateByAddingTimeInterval:-60.0 * i];
        [self addTileForDate:date];
    }
}

- (void)addTileForDate:(NSDate *)date
{
    CPTile *tile = [[CPTile alloc] init];
    tile.date = date;
    tile.title = @"Hey it's a title.";
    
    switch (arc4random_uniform(3)) {
        case 0:
            tile.body = [NSString stringWithFormat:@"%@ Hey this is my *message body*! *Bacon* ipsum dolor amet *spare ribs* drumstick short ribs ham, shank hamburger ham hock leberkas tri-tip pig doner kielbasa bresaola fatback. Spare ribs landjaeger shoulder venison, pork belly short ribs jerky pastrami pork hamburger pork loin. Alcatra beef ribeye prosciutto rump. Turducken drumstick salami capicola pork chop jerky beef bresaola biltong picanha shoulder hamburger pork short loin. Filet mignon pastrami meatloaf tongue. Shank sirloin salami biltong jerky shoulder chicken corned beef, pastrami tongue sausage beef ribs chuck pork kielbasa.", tile.date];
            break;
        case 1:
            tile.body = [NSString stringWithFormat:@"Hey this is my *message body*! %@", tile.date];
            break;
        case 2:
            tile.body = [NSString stringWithFormat:@"- Make sure your dog is around\n- Make sure your dog is hungry\n- Get your dog to eat!\n\n\n\n%@", tile.date];
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