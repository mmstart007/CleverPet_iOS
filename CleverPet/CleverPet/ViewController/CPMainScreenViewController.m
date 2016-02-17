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

    CPTileCollectionViewDataSource *dataSource = [[CPTileCollectionViewDataSource alloc] initWithCollectionView:self.tableView];

    self.dataSource = dataSource;
    self.tableView.delegate = dataSource;
    self.tableView.dataSource = dataSource;
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(addTile) userInfo:nil repeats:YES];
}

- (void)addTile
{
    CPTile *tile = [[CPTile alloc] init];
    tile.date = [NSDate date];
    tile.title = @"Hey it's a title.";
    if (arc4random_uniform(2)) {
    tile.body = [NSString stringWithFormat:@"%@ Hey this is my *message body*! *Bacon* ipsum dolor amet *spare ribs* drumstick short ribs ham, shank hamburger ham hock leberkas tri-tip pig doner kielbasa bresaola fatback. Spare ribs landjaeger shoulder venison, pork belly short ribs jerky pastrami pork hamburger pork loin. Alcatra beef ribeye prosciutto rump. Turducken drumstick salami capicola pork chop jerky beef bresaola biltong picanha shoulder hamburger pork short loin. Filet mignon pastrami meatloaf tongue. Shank sirloin salami biltong jerky shoulder chicken corned beef, pastrami tongue sausage beef ribs chuck pork kielbasa.", tile.date];
    } else {
        tile.body = [NSString stringWithFormat:@"Hey this is my *message body*! %@", tile.date];
    }
    tile.image = [UIImage imageNamed:@"vallhund"];
    
    [self.dataSource addTile:tile];
}
@end