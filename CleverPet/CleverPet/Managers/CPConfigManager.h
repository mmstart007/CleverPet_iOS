//
//  CPConfigManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MACRO_NAME(f) #f
#define MACRO_VALUE(f)  MACRO_NAME(f)

extern NSString * const kConfigUpdatedNotification;
extern NSString * const kConfigErrorKey;

@interface CPConfigManager : NSObject

+ (instancetype)sharedInstance;
- (ASYNC)loadConfig:(BOOL)forceLoad completion:(void (^)(NSError *))completion;
- (void)appEnteredForeground;
- (NSString*)getServerUrl;
- (void)hubClaimingBegan;
- (void)hubClaimingEnded;

@end
