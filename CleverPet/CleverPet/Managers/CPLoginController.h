//
//  CPLoginController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITAccount;

extern NSString * const kLoginCompleteNotification;
extern NSString * const kLoginErrorKey;

@interface CPLoginController : NSObject

+ (instancetype)sharedInstance;

- (void)startSignin;
- (void)signInWithEmail:(NSString*)email;
- (void)verifyPassword:(NSString *)password forEmail:(NSString*)email failure:(void (^)(void))failure;
- (void)signUpWithEmail:(NSString*)email displayName:(NSString*)displayName andPassword:(NSString*)password;
- (void)signInWithFacebook;
- (void)signInWithGoogle;

- (void)setPendingUserInfo:(NSDictionary *)userInfo;
- (void)completeSignUpWithPetImage:(UIImage*)image completion:(void (^)(NSError *error))completion;

- (BOOL)isValidEmail:(NSString*)email;

- (void)logout;

@end
