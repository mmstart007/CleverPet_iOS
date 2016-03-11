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

@interface CPFirebaseManager()

@property (strong, nonatomic) Firebase* rootRef;
@property (strong, nonatomic) NSString* userStatsPath;

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

- (void)userLoggedIn:(NSDictionary *)response
{
    [self.rootRef authWithCustomToken:[response objectForKey:@"firebase_token"] withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSLog(@"Login Failed! %@", error);
        } else {
            self.userStatsPath = [NSString stringWithFormat:@"stats/%@", authData.uid];
        }
    }];
}

- (void)userLoggedOut
{
    [self stoplisteningForUpdates];
    self.userStatsPath = nil;
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
    [[self.rootRef childByAppendingPath:self.userStatsPath] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
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

- (void)stoplisteningForUpdates
{
    [self.rootRef removeAllObservers];
}

@end
