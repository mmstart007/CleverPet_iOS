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

#define FIREBASE_LISTENER(Type, Field, Name) - (FirebaseManagerHandle)subscribeTo##Name##WithBlock:(Firebase##Type##UpdateBlock)block {\
return [self subscribeTo ## Type ## UpdatesForKey:Field withCallback:block];\
}

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
    self.rootRef = [[Firebase alloc] initWithUrl:@"https://blistering-torch-9343.firebaseio.com/"];
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

- (void)unsubscribeFromHandle:(FirebaseManagerHandle)handle
{
    [self.rootRef removeObserverWithHandle:handle.unsignedIntegerValue];
}

- (FirebaseManagerHandle)subscribeToNumberUpdatesForKey:(NSString *)updateKey withCallback:(FirebaseNumberUpdateBlock)callback
{
    return @([[[self.rootRef childByAppendingPath:self.userStatsPath] childByAppendingPath:updateKey] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value == [NSNull null]) {
            callback(nil);
        } else {
            callback(snapshot.value);
        }
    }]);
}

- (FirebaseManagerHandle)subscribeToStringUpdatesForKey:(NSString *)updateKey withCallback:(FirebaseStringUpdateBlock)callback
{
    return @([[[self.rootRef childByAppendingPath:self.userStatsPath] childByAppendingPath:updateKey] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value == [NSNull null]) {
            callback(nil);
        } else {
            callback(snapshot.value);
        }
    }]);
}

- (void)userLoggedOut
{
    self.userStatsPath = nil;
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
- (FirebaseManagerHandle)subscribeToTilesWithBlock:(FirebaseTileUpdateBlock)block
{
    Firebase *tileRoot = [self.rootRef childByAppendingPath:[NSString stringWithFormat:@"%@/%@", self.userStatsPath, kFirebaseTilePath]];
    NSString *childKey = [tileRoot childByAutoId].key;
    
    return @([[[tileRoot queryOrderedByKey] queryStartingAtValue:childKey] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSError *error = nil;
        CPTile *tile = [[CPTile alloc] initWithDictionary:snapshot.value error:&error];
        if (error) {
            block(error, nil);
        } else {
            block(nil, tile);
        }
    }]);
}

FIREBASE_LISTENER(String, @"challenge_name", ChallengeName);
FIREBASE_LISTENER(Number, @"challenge_number", ChallengeNumber);
FIREBASE_LISTENER(Number, @"lifetime_points", LifetimePoints);
FIREBASE_LISTENER(Number, @"stage_number", StageNumber);
FIREBASE_LISTENER(Number, @"total_stages", TotalStages);
FIREBASE_LISTENER(Number, @"kibbles", Kibbles);
FIREBASE_LISTENER(Number, @"plays", Plays);

@end
