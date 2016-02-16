//
//  CPLoginController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITAccount;

@interface CPLoginController : NSObject

+ (instancetype)sharedInstance;

- (void)startSignin;
- (void)signInWithEmail:(NSString*)email;
- (void)verifyPassword:(NSString *)password forEmail:(NSString*)email failure:(void (^)(void))failure;
- (void)signUpWithEmail:(NSString*)email displayName:(NSString*)displayName andPassword:(NSString*)password;
- (void)signInWithFacebook;
- (void)signInWithGoogle;

@end
