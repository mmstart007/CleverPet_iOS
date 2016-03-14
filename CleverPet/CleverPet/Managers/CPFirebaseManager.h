//
//  CPFirebaseManager.h
//  CleverPet
//
//  Created by Michelle Hillier on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPPetStats.h"

typedef void(^FirebaseUpdateBlock)(NSError*, CPPetStats*);
typedef void(^FirebaseLoginBlock)(NSError *);

@interface CPFirebaseManager : NSObject

@property (nonatomic, copy) FirebaseUpdateBlock headerStatsUpdateBlock;
@property (nonatomic, copy) FirebaseUpdateBlock viewStatsUpdateBlock;

+ (instancetype)sharedInstance;

- (void)applyConfig:(NSDictionary *)configData;
- (void)userLoggedIn:(NSDictionary *)response withCompletion:(FirebaseLoginBlock)completion;
// TODO: rename to stats
- (void)beginlisteningForUpdates;
- (void)stoplisteningForStatsUpdates;

//Tile updates
- (void)listenForTileUpdatesWithBlock:(FirebaseUpdateBlock)block;
- (void)stopListeningForTileUpdates;

@end
