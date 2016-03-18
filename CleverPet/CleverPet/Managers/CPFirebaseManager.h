//
//  CPFirebaseManager.h
//  CleverPet
//
//  Created by Michelle Hillier on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPTile.h"

typedef void(^FirebaseTileUpdateBlock)(NSError*, CPTile*);
typedef void(^FirebaseLoginBlock)(NSError *);

@interface CPFirebaseManager : NSObject

typedef void(^FirebaseNumberUpdateBlock)(NSNumber *value);
typedef void(^FirebaseStringUpdateBlock)(NSString *value);

typedef NSNumber *FirebaseManagerHandle;

+ (instancetype)sharedInstance;

- (void)applyConfig:(NSDictionary *)configData;
- (void)userLoggedIn:(NSDictionary *)response withCompletion:(FirebaseLoginBlock)completion;

- (FirebaseManagerHandle)subscribeToChallengeNameWithBlock:(FirebaseStringUpdateBlock)block;
- (FirebaseManagerHandle)subscribeToChallengeNumberWithBlock:(FirebaseNumberUpdateBlock)block;
- (FirebaseManagerHandle)subscribeToLifetimePointsWithBlock:(FirebaseNumberUpdateBlock)block;
- (FirebaseManagerHandle)subscribeToStageNumberWithBlock:(FirebaseNumberUpdateBlock)block;
- (FirebaseManagerHandle)subscribeToTotalStagesWithBlock:(FirebaseNumberUpdateBlock)block;
- (FirebaseManagerHandle)subscribeToKibblesWithBlock:(FirebaseNumberUpdateBlock)block;
- (FirebaseManagerHandle)subscribeToPlaysWithBlock:(FirebaseNumberUpdateBlock)block;
- (FirebaseManagerHandle)subscribeToTilesWithBlock:(FirebaseTileUpdateBlock)block;

- (void)unsubscribeFromHandle:(FirebaseManagerHandle)handle;
@end
