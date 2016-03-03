//
//  CPAppEngineCommunicationManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPAppEngineCommunicationManager.h"
#import <AFNetworking/AFNetworking.h>
#import "GITAccount.h"
#import "CPUserManager.h"
#import "CPParticleConnectionHelper.h"

NSString * const kAppEngineBaseUrl = @"app_server_url";
NSString * const kNewUserPath = @"users/new";
NSString * const kUserLoginPath = @"users/login";
NSString * const kUserLogoutPath = @"users/logout";
NSString * const kUserInfoPath = @"users/info";
NSString * const kPetProfilePath = @"animals";
#define SPECIFIC_PET_PROFILE(petId) [NSString stringWithFormat:@"%@/%@", kPetProfilePath, petId]

// TODO: error codes or something so this isn't string matching
NSString * const kNoUserAccountError = @"No account exists for the given email address";

@interface CPAppEngineCommunicationManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation CPAppEngineCommunicationManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPAppEngineCommunicationManager *s_sharedInstance;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[CPAppEngineCommunicationManager alloc] init];
    });
    return s_sharedInstance;
}

- (void)applyConfig:(NSDictionary *)configData
{
    // TODO: handle missing config
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:configData[kAppEngineBaseUrl]]];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

- (ASYNC)loginWithAuthToken:(NSString *)gitKitToken completion:(void (^)(CPLoginResult, NSError *))completion
{
    NSParameterAssert(gitKitToken);
    BLOCK_SELF_REF_OUTSIDE();
    // Set our auth token
    // TODO: No cookie, bring back auth header
//    [self setAuthToken:gitKitToken];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"gtoken"]) {
            [cookieStorage deleteCookie:cookie];
        }
    }
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieDomain:@"dev-erpetcloud.appspot.com", NSHTTPCookiePath:@"/", NSHTTPCookieName:@"gtoken", NSHTTPCookieValue:gitKitToken}];
    [cookieStorage setCookie:cookie];
    
    [self.sessionManager POST:kUserLoginPath parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion(CPLoginResult_Failure, [self errorForMessage:errorMessage]);
        } else {
            // Check for required auth tokens
            if (jsonResponse[kAuthTokenKey] && jsonResponse[kParticleAuthTokenKey] && jsonResponse[kFirebaseAuthTokenKey]) {
                [self setAuthToken:jsonResponse[kAuthTokenKey]];
                [[CPUserManager sharedInstance] userLoggedIn:jsonResponse];
                [self userLoggedIn:jsonResponse completion:completion];
            } else {
                // TODO: update message with specific token missing
                if (completion) completion(CPLoginResult_Failure, [self errorForMessage:NSLocalizedString(@"Missing auth token", nil)]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        // Clear the auth header as we will now be in a fresh login state
        [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
        if (completion) completion(CPLoginResult_Failure, error);
    }];
}

- (ASYNC)logoutWithCompletion:(void (^)(NSError *))completion
{
    [self.sessionManager PUT:kUserLogoutPath parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(error);
    }];
    // Clear our auth header regardless of if the call is successful or not, as we've already dumped the user back to login
    [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
}

- (ASYNC)userLoggedIn:(NSDictionary *)userInfo completion:(void (^)(CPLoginResult, NSError *))completion
{
    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
    
    void (^particleAuthSet)(NSError *) = ^(NSError *error){
        if (error) {
            [[CPUserManager sharedInstance] clearCurrentUser];
            if (completion) completion(CPLoginResult_Failure, error);
        } else {
            CPLoginResult result = CPLoginResult_UserWithSetupCompleted;
            if (!currentUser.pet) {
                result = CPLoginResult_UserWithoutPetProfile;
            } else if (!userInfo[@"device"]) {
                result = CPLoginResult_UserWithoutDevice;
            }
            if (completion) completion(result, nil);
        }
    };
    
    // TODO: Update with the proper keys/etc from feature/hub-settings-networking
    if (!userInfo[@"device"]) {
        // If we have no device, we need to set the auth token for particle
        [[CPParticleConnectionHelper sharedInstance] setAccessToken:userInfo[kParticleAuthTokenKey] completion:particleAuthSet];
    } else {
        particleAuthSet(nil);
    }
}

#pragma mark - Pet profile
- (ASYNC)createPetProfileWithInfo:(NSDictionary *)petInfo completion:(void (^)(NSString *, NSError *))completion
{
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager POST:kPetProfilePath parameters:petInfo progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion(nil, [self errorForMessage:errorMessage]);
        } else {
            // TODO: is this still necessary?
            [self lookupPetInfo:jsonResponse[@"animal_ID"] completion:completion];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(nil, error);
    }];
}

- (ASYNC)updatePet:(NSString *)petId withInfo:(NSDictionary *)petInfo completion:(void (^)(NSError *))completion
{
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager PUT:SPECIFIC_PET_PROFILE(petId) parameters:petInfo success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion([self errorForMessage:errorMessage]);
        } else {
            if (completion) completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(error);
    }];
}

- (ASYNC)lookupPetInfo:(NSString *)petId completion:(void (^)(NSString *, NSError *))completion
{
    [self.sessionManager GET:SPECIFIC_PET_PROFILE(petId) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion(nil, [self errorForMessage:errorMessage]);
        } else {
            [[CPUserManager sharedInstance] userCreatedPet:jsonResponse];
            if (completion) completion(jsonResponse[@"animal_ID"], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(nil, error);
    }];
}

#pragma mark - Util
- (void)setAuthToken:(NSString *)authToken
{
    [self.sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", authToken] forHTTPHeaderField:@"Authorization"];
}

- (NSError*)errorForMessage:(NSString *)message
{
    // TODO: error codes
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey:message}];
}

@end
