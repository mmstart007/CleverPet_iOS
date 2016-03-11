//
//  CPConfigManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPConfigManager : NSObject

+ (instancetype)sharedInstance;
- (ASYNC)loadConfigWithCompletion:(void (^)(NSError *error))completion;
- (void)appEnteredForeground;
- (NSString*)getServerUrl;

@end
