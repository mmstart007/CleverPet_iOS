//
//  CPFirebaseManager.h
//  CleverPet
//
//  Created by Michelle Hillier on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FirebaseUpdateBlock)(NSError*, NSDictionary*);

@interface CPFirebaseManager : NSObject

@property (nonatomic, copy) FirebaseUpdateBlock headerStatsUpdateBlock;
@property (nonatomic, copy) FirebaseUpdateBlock viewStatsUpdateBlock;

+ (instancetype)sharedInstance;

- (void)applyConfig:(NSDictionary *)configData;
- (void)userLoggedIn:(NSDictionary *)response;
- (void)beginlisteningForUpdates;
- (void)stoplisteningForUpdates;
@end
