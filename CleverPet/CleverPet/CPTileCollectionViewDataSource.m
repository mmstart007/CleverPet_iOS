//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileCollectionViewDataSource.h"
#import "CPTileSection.h"
#import "CPTile.h"
#import "CPTileViewCell.h"


#define TILE_VIEW_CELL @"TILE_VIEW_CELL"

@interface CPTileCollectionViewDataSource ()
@property (strong, nonatomic) NSMutableArray<CPTile *> *tiles;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) CPTileViewCell *cell;
@end

@implementation CPTileCollectionViewDataSource {

}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (self) {
        self.collectionView = collectionView;

        [collectionView registerNib:[UINib nibWithNibName:@"CPTileViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:TILE_VIEW_CELL];
    }

    return self;
}

- (void)didSetLayout:(UICollectionViewFlowLayout *)layout
{
//    layout.estimatedItemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.cell) {
        self.cell = [[[NSBundle mainBundle] loadNibNamed:@"CPTileViewCell" owner:self options:nil] objectAtIndex:0];
//        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.cell
//                                                                      attribute:NSLayoutAttributeWidth
//                                                                      relatedBy:NSLayoutRelationEqual
//                                                                         toItem:nil
//                                                                      attribute:NSLayoutAttributeNotAnAttribute
//                                                                     multiplier:1.0
//                                                                       constant:collectionView.bounds.size.width];
//        [self.cell addConstraint:constraint];
    }
    
    CGRect frame = self.cell.frame;
    frame.size = CGSizeMake(collectionView.bounds.size.width, CGFLOAT_MAX);
    self.cell.frame = frame;
    
    CPTile *tile = self.tiles[indexPath.item];
    self.cell.tile = tile;
    
    [self.cell setNeedsLayout];
    [self.cell layoutIfNeeded];
    CGSize newSize = [self.cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return newSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPTileViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TILE_VIEW_CELL forIndexPath:indexPath];
    CPTile *tile = self.tiles[(NSUInteger) indexPath.item];
    cell.tile = tile;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tiles.count;
}

- (void)addTile:(CPTile *)tile {
    NSUInteger index = [self.tiles indexOfObject:tile inSortedRange:NSMakeRange(0, self.tiles.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(CPTile *a, CPTile *b) {
        return [a.date compare:b.date];
    }];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        [self.tiles insertObject:tile atIndex:index];
    } completion:nil];
}

- (NSMutableArray *)tiles {
    if (!_tiles) {
        _tiles = [[NSMutableArray alloc] init];
    }

    return _tiles;
}

@end