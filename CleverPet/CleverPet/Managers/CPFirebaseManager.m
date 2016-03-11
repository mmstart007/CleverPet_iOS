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


 - (void)beginlisteningForUpdates
{
    [[self.rootRef childByAppendingPath:self.userStatsPath] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (self.headerStatsUpdateBlock) {
            self.headerStatsUpdateBlock(nil, snapshot.value);
        }
        if (self.viewStatsUpdateBlock) {
            self.viewStatsUpdateBlock(nil, snapshot.value);
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
             viewStatsUpdateBlock(nil, snapshot.value);
        }];
    }
}

- (void)setHeaderStatsUpdateBlock:(FirebaseUpdateBlock)headerStatsUpdateBlock
{
    _headerStatsUpdateBlock = headerStatsUpdateBlock;
    if (headerStatsUpdateBlock) {
        [[self.rootRef childByAppendingPath:self.userStatsPath] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            headerStatsUpdateBlock(nil, snapshot.value);
        }];
    }
}

- (void)stoplisteningForUpdates
{
    [self.rootRef removeAllObservers];
}

@end
