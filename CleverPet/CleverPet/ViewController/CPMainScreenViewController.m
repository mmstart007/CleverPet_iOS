//
// Created by Daryl at Finger Foods on 2016-02-16.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainScreenViewController.h"
#import "CPTileCollectionViewDataSource.h"
#import "CPTile.h"

@interface CPMainScreenViewController () <UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) CPTileCollectionViewDataSource *dataSource;
@end

@implementation CPMainScreenViewController {

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CPTileCollectionViewDataSource *dataSource = [[CPTileCollectionViewDataSource alloc] initWithCollectionView:self.collectionView];

    self.dataSource = dataSource;
    self.collectionView.dataSource = dataSource;
    self.collectionView.delegate = dataSource;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(200, 100);
    self.collectionView.collectionViewLayout = layout;
    [dataSource didSetLayout:layout];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(addTile) userInfo:nil repeats:YES];
}

- (void)addTile
{
    CPTile *tile = [[CPTile alloc] init];
    tile.date = [NSDate date];
    tile.title = @"Hey it's a title.";
    tile.body = @"Hey this is my *body*! Check out all the cool types of wrapping I support!\nWasn't that *fun*?";
    tile.image = [UIImage imageNamed:@"vallhund"];
    
    [self.dataSource addTile:tile];
}
@end