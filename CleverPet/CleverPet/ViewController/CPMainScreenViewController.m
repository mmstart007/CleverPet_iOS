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
#import "CPFirebaseManager.h"
#import "CPPlayerViewController.h"
@import AVFoundation;

@interface CPMainScreenViewController () <UICollectionViewDelegate, CPTileCollectionViewDataSourceDelegate, AVPlayerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CPTileCollectionViewDataSource *dataSource;
@property (strong, nonatomic) CPPetStatsView *petStatsView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) CPMainScreenHeaderView *mainScreenHeaderView;
@property (strong, nonatomic) CPMainScreenStatsHeaderView *mainScreenStatsHeaderView;

@property (nonatomic, strong) CPPet *currentPet;
@property (nonatomic, strong) CPTile *playingTile;
@property (nonatomic, strong) CPPlayerViewController *playerController;
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
    dataSource.delegate = self;

    self.dataSource = dataSource;
    self.tableView.delegate = dataSource;
    self.tableView.dataSource = dataSource;
    self.tableView.allowsSelection = NO;
    
    self.playerController = [[CPPlayerViewController alloc] init];
    
    [dataSource postInit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    // Update pet name/image
    // TODO: maybe a notification when pet info is updated so we don't always have to do this?
    [self.mainScreenHeaderView setupForPet:self.currentPet];
    if ([self.tableView.dataSource respondsToSelector:@selector(updatePetImage:)]) {
        [self.tableView.dataSource performSelector:@selector(updatePetImage:) withObject:[self.currentPet petPhoto]];
    }
    // Inform our data source we're going to become visible
    [self.dataSource viewBecomingVisible];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerController.player currentItem]];
    self.playingTile = nil;
}

#pragma mark - CPTileCollectionViewDataSourceDelegate
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

- (void)playVideoForTile:(CPTile *)tile
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerController.player currentItem]];
    if (tile != self.playingTile) {
        self.playingTile = tile;
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:tile.videoUrl];
        if (self.playerController.player) {
            [self.playerController.player replaceCurrentItemWithPlayerItem:item];
        } else {
            self.playerController.player = [AVPlayer playerWithPlayerItem:item];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayedToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerController.player currentItem]];
    self.playerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:self.playerController animated:YES completion:nil];
    [self.playerController.player play];
}

- (void)videoPlayedToEnd:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerController.player currentItem]];
    [self.dataSource videoPlaybackCompletedForTile:self.playingTile];
    self.playingTile = nil;
}

- (BOOL)isViewVisible
{
    // we have no window, we're not currently visible
    return self.view.window != nil;
}

@end