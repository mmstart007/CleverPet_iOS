//
//  CPUserManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPUser.h"

@interface CPUserManager : NSObject

+ (instancetype)sharedInstance;

- (void)userLoggedIn:(NSDictionary*)userInfo;
- (void)userCreatedPet:(NSDictionary*)petInfo;
- (void)updatePetInfo:(NSDictionary*)petInfo withCompletion:(void (^)(NSError *))completion;
- (void)updatePetPhoto:(UIImage*)image;

- (void)userCreatedDevice:(NSDictionary*)deviceInfo;
- (void)updateDeviceInfo:(NSDictionary*)deviceInfo;
- (void)fetchedDeviceSchedules:(NSDictionary*)scheduleInfo;

- (CPUser*)getCurrentUser;

- (void)logout;
// Used to clear the current user if our login flow fails after the call to login was successful. Currently should only happen if something goes wrong setting the particle auth token
- (void)clearCurrentUser;

@end
