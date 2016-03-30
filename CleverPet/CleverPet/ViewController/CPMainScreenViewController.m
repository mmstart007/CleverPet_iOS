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

@interface CPMainScreenViewController () <UICollectionViewDelegate, CPTileCollectionViewDataSourceDelegate, AVPlayerViewControllerDelegate, CPPlayerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CPTileCollectionViewDataSource *dataSource;
@property (strong, nonatomic) CPPetStatsView *petStatsView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) CPMainScreenHeaderView *mainScreenHeaderView;
@property (strong, nonatomic) CPMainScreenStatsHeaderView *mainScreenStatsHeaderView;

@property (nonatomic, strong) CPPet *currentPet;
@property (nonatomic, strong) CPTile *playingTile;
@property (nonatomic, weak) CPPlayerViewController *playerController;
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
    self.mainScreenStatsHeaderView.imageView.image = [self.currentPet petPhoto];
    
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
    
    [dataSource postInit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    // Update pet name/image
    // TODO: maybe a notification when pet info is updated so we don't always have to do this?
    [self.mainScreenHeaderView setupForPet:self.currentPet];
    self.mainScreenStatsHeaderView.imageView.image = [self.currentPet petPhoto];
    if ([self.tableView.dataSource respondsToSelector:@selector(updatePetImage:)]) {
        [self.tableView.dataSource performSelector:@selector(updatePetImage:) withObject:[self.currentPet petPhoto]];
    }
    // Inform our data source we're going to become visible
    [self.dataSource viewBecomingVisible];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerController playerItem]];
    self.playingTile = nil;
}

- (void)dealloc
{
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
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
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayedToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerController playerItem]];
    
    CPPlayerViewController *player = [[CPPlayerViewController alloc] initWithContentUrl:tile.videoUrl];
    player.delegate = self;
    [player presentInWindow];
    self.playerController = player;
}

- (void)videoPlayedToEnd:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.playerController playerItem]];
    [self.dataSource videoPlaybackCompletedForTile:self.playingTile];
    self.playingTile = nil;
}

- (void)videoPlayerWillDisappear
{
    [self.dataSource viewBecomingVisible];
}

- (BOOL)isViewVisible
{
    // we have no window, we're not currently visible
    return self.view.window != nil;
}

- (void)displayError:(NSError *)error
{
    if ([error isOfflineError]) {
        [self displayErrorAlertWithTitle:ERROR_TEXT andMessage:OFFLINE_TEXT];
    } else {
        [self displayErrorAlertWithTitle:ERROR_TEXT andMessage:error.localizedDescription];
    }
}

@end