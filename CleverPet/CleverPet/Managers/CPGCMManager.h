//
//  CPGCMManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-10.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: convert to base communication manager after tiles branch is merged
@interface CPGCMManager : NSObject

+ (instancetype)sharedInstance;

- (void)userLoggedIn;
- (void)obtainedGCMToken:(NSString *)token;
- (NSString*)getToken;

@end
