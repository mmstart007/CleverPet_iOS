//
//  CPConfigManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kConfigUpdatedNotification;
extern NSString * const kConfigErrorKey;

@interface CPConfigManager : NSObject

+ (instancetype)sharedInstance;
- (ASYNC)loadConfig:(BOOL)forceLoad completion:(void (^)(NSError *))completion;
- (void)appEnteredForeground;

@end
