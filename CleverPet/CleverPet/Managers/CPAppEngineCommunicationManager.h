//
//  CPAppEngineCommunicationManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITAccount;

typedef NS_ENUM(NSUInteger, CPLoginResult) {CPLoginResult_UserWithoutPetProfile, CPLoginResult_UserWithoutDevice, CPLoginResult_UserWithSetupCompleted, CPLoginResult_Failure};

@interface CPAppEngineCommunicationManager : NSObject

+ (instancetype)sharedInstance;

- (void)applyConfig:(NSDictionary*)configData;

- (ASYNC)loginWithUser:(GITAccount*)userAccount completion:(void (^)(CPLoginResult result, NSError *error))completion;

@end
