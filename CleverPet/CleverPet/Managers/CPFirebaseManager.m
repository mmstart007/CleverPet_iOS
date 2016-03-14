//
//  CPFirebaseManager.m
//  CleverPet
//
//  Created by Michelle Hillier on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>
#import "CPUserManager.h"
#import "CPFirebaseManager.h"

NSString * const kFirebaseTilePath = @"tile";

@interface CPFirebaseManager()

@property (strong, nonatomic) Firebase* rootRef;
@property (strong, nonatomic) NSString* userStatsPath;
@property (nonatomic, assign) FirebaseHandle statsHandle;
@property (nonatomic, assign) BOOL hasStatsHandle;
@property (nonatomic, assign) FirebaseHandle tilesHandle;
@property (nonatomic, assign) BOOL hasTilesHandle;

@end

@implementation CPFirebaseManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPFirebaseManager *s_sharedInstance;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[CPFirebaseManager alloc] init];
    });
    return s_sharedInstance;
}

- (void)applyConfig:(NSDictionary *)configData
{
    self.rootRef = [[Firebase alloc] initWithUrl:[configData objectForKey:@"firebase_url"]];
}

- (void)userLoggedIn:(NSDictionary *)response withCompletion:(FirebaseLoginBlock)completion
{
    [self.rootRef authWithCustomToken:[response objectForKey:@"firebase_token"] withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSLog(@"Login Failed! %@", error);
        } else {
            self.userStatsPath = [NSString stringWithFormat:@"stats/%@", authData.uid];
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

- (void)userLoggedOut
{
    [self stoplisteningForStatsUpdates];
    self.userStatsPath = nil;
    [self stopListeningForTileUpdates];
}

- (CPPetStats*)petStats:(NSDictionary*)values
{
    CPPetStats *petStats = nil;
    if (![values isEqual:[NSNull null]]) {
        NSError *error;
        petStats = [[CPPetStats alloc] initWithDictionary:values error:&error];
    }
    return petStats;
}

 - (void)beginlisteningForUpdates
{
    FirebaseHandle statsHandle = [[self.rootRef childByAppendingPath:self.userStatsPath] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
		CPPetStats *petStats = [self petStats:snapshot.value];
        if (self.headerStatsUpdateBlock) {
            self.headerStatsUpdateBlock(nil, petStats);
        }
        if (self.viewStatsUpdateBlock) {
            self.viewStatsUpdateBlock(nil, petStats);
        }
    } withCancelBlock:^(NSError *error) {
        if (self.headerStatsUpdateBlock) {
            self.headerStatsUpdateBlock(error, nil);
        }
        if (self.viewStatsUpdateBlock) {
            self.viewStatsUpdateBlock(error, nil);
        }
    }];
    self.statsHandle = statsHandle;
    self.hasStatsHandle = YES;
}


- (void)setViewStatsUpdateBlock:(FirebaseUpdateBlock)viewStatsUpdateBlock
{
    _viewStatsUpdateBlock = viewStatsUpdateBlock;
    if (viewStatsUpdateBlock) {
        [[self.rootRef childByAppendingPath:self.userStatsPath] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
             viewStatsUpdateBlock(nil, [self petStats:snapshot.value]);
        }];
    }
}

- (void)setHeaderStatsUpdateBlock:(FirebaseUpdateBlock)headerStatsUpdateBlock
{
    _headerStatsUpdateBlock = headerStatsUpdateBlock;
    if (headerStatsUpdateBlock) {
        [[self.rootRef childByAppendingPath:self.userStatsPath] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            headerStatsUpdateBlock(nil, [self petStats:snapshot.value]);
        }];
    }
}

- (void)stoplisteningForStatsUpdates
{
    // Controlling this with a boolean, since it's not clear from the documentation what the range of integers can be, so I don't feel confidant using say -1 to represent no handle
    if (self.hasStatsHandle) {
        [self.rootRef removeObserverWithHandle:self.statsHandle];
        self.hasStatsHandle = NO;
        self.statsHandle = 0;
    }
    
}

#pragma mark - Tile updates
- (void)listenForTileUpdatesWithBlock:(FirebaseUpdateBlock)block
{
    self.tilesHandle = [[self.rootRef childByAppendingPath:[NSString stringWithFormat:@"%@/%@", self.userStatsPath, kFirebaseTilePath]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        block(nil, [self petStats:snapshot.value]);
    }];
    self.hasTilesHandle = YES;
}

- (void)stopListeningForTileUpdates
{
    if (self.hasTilesHandle) {
        [self.rootRef removeObserverWithHandle:self.tilesHandle];
        self.hasTilesHandle = NO;
        self.statsHandle = 0;
    }
}

@end
