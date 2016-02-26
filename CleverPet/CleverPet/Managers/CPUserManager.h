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
- (void)updatePetInfo:(NSDictionary*)petInfo;
- (void)updatePetPhoto:(UIImage*)image;
- (CPUser*)getCurrentUser;

- (void)logout;

@end
