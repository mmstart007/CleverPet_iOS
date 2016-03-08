//
//  CPAppEngineCommunicationManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPBaseCommunicationManager.h"

@class GITAccount;
@class SparkDevice;
@class AFHTTPSessionManager;

typedef NS_ENUM(NSUInteger, CPLoginResult) {CPLoginResult_UserWithoutPetProfile, CPLoginResult_UserWithoutDevice, CPLoginResult_UserWithSetupCompleted, CPLoginResult_Failure};

@interface CPAppEngineCommunicationManager : CPBaseCommunicationManager

+ (instancetype)sharedInstance;

- (void)applyConfig:(NSDictionary*)configData;
- (AFHTTPSessionManager*)getSessionManager;

- (ASYNC)loginWithAuthToken:(NSString*)gitKitToken completion:(void (^)(CPLoginResult result, NSError *error))completion;
- (ASYNC)logoutWithCompletion:(void (^)(NSError *error))completion;
- (ASYNC)createPetProfileWithInfo:(NSDictionary *)petInfo completion:(void (^)(NSString *petId, NSError *))completion;
- (ASYNC)updatePet:(NSString*)petId withInfo:(NSDictionary*)petInfo completion:(void (^)(NSError *error))completion;

- (ASYNC)createDevice:(NSDictionary*)deviceInfo completion:(void (^)(NSError *error))completion;
- (ASYNC)updateDevice:(NSString*)deviceId mode:(NSString*)mode completion:(void (^)(NSError *error))completion;
- (ASYNC)updateDevice:(NSString*)deviceId schedule:(NSString*)scheduleId withInfo:(NSDictionary*)scheduleInfo completion:(void (^)(NSError *error))completion;

@end
