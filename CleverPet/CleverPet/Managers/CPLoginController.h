//
//  CPLoginController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITAccount;

@protocol CPLoginControllerDelegate <NSObject>

- (void)loginAttemptFailed:(NSString*)message;
- (void)loginAttemptCancelled;

@end

@interface CPLoginController : NSObject

+ (instancetype)sharedInstance;

- (void)startSigninWithDelegate:(id<CPLoginControllerDelegate>)delegate;
- (void)signInWithEmail:(NSString*)email;
- (void)verifyPassword:(NSString *)password forEmail:(NSString*)email failure:(void (^)(void))failure;
- (void)signUpWithEmail:(NSString*)email displayName:(NSString*)displayName andPassword:(NSString*)password;
- (void)signInWithFacebook;
- (void)signInWithGoogle;

- (void)loginViewPressedCancel:(UIViewController*)viewController;
- (void)cancelPetProfileCreation;

- (void)setPendingUserInfo:(NSDictionary *)userInfo;
- (void)completeSignUpWithPetImage:(UIImage*)image completion:(void (^)(NSError *error))completion;

- (BOOL)isValidEmail:(NSString*)email;

- (void)logout;

- (void)forgotPasswordForEmail:(NSString *)emailString withCompletion:(void (^)(NSError *))completion;
@end
