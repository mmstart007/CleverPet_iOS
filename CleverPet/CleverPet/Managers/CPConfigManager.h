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
- (void)loadConfigWithCompletion:(void (^)(NSError *error))completion;

@end
