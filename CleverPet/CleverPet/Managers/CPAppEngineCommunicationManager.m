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

NSString * const kAppEngineBaseUrl = @"app_server_url";
NSString * const kNewUserPath = @"users/new";
NSString * const kUserLoginPath = @"users/login";
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

- (ASYNC)loginWithUser:(GITAccount*)userAccount completion:(void (^)(CPLoginResult, NSError *))completion
{
    NSParameterAssert(userAccount);
    NSParameterAssert(userAccount.localID);
    // TODO: address this once login/creation have been unified. For now, try to login, and if it fails with no user, go creation
    NSDictionary *params = @{kEmailKey:userAccount.localID};
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager PUT:kUserLoginPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        // If we failed because our account didn't exist, make the sign up call
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if ([errorMessage isEqualToString:kNoUserAccountError]) {
                [self createUser:userAccount completion:completion];
            } else {
                if (completion) completion(CPLoginResult_Failure, [self errorForMessage:errorMessage]);
            }
        } else {
            // Check for auth token
            if (jsonResponse[kAuthTokenKey]) {
                [self setAuthToken:jsonResponse[kAuthTokenKey]];
                [[CPUserManager sharedInstance] userLoggedIn:jsonResponse];
                [self fetchUserCompletion:completion];
                //                if (completion) completion(CPLoginResult_UserWithoutPetProfile, nil);
            } else {
                if (completion) completion(CPLoginResult_Failure, [self errorForMessage:NSLocalizedString(@"Missing auth token", nil)]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(CPLoginResult_Failure, error);
    }];
}

- (ASYNC)createUser:(GITAccount*)userAccount completion:(void (^)(CPLoginResult, NSError *))completion
{
    // TODO: make this more robust, or hopefully kill it
    NSArray *nameComponents = [userAccount.displayName componentsSeparatedByString:@" "];
    if ([nameComponents count] == 0) {
        nameComponents = @[@"Missing"];
    }
    
    NSDictionary *params = @{kEmailKey:userAccount.localID, kFirstNameKey:[nameComponents firstObject], kLastNameKey:[nameComponents lastObject], @"provider":(userAccount.providerID ? userAccount.providerID : @"email"), @"testing":@NO};
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager POST:kNewUserPath parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion(CPLoginResult_Failure, [self errorForMessage:errorMessage]);
        } else {
            // Check for auth token
            if (jsonResponse[kAuthTokenKey]) {
                [self setAuthToken:jsonResponse[kAuthTokenKey]];
                [[CPUserManager sharedInstance] userLoggedIn:jsonResponse];
                [self fetchUserCompletion:completion];
//                if (completion) completion(CPLoginResult_UserWithoutPetProfile, nil);
            } else {
                if (completion) completion(CPLoginResult_Failure, [self errorForMessage:NSLocalizedString(@"Missing auth token", nil)]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(CPLoginResult_Failure, error);
    }];
}

// TODO: remove. For now, this is where we have to check pet profile and device
- (ASYNC)fetchUserCompletion:(void (^)(CPLoginResult, NSError *))completion
{
    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
    if (completion) completion((currentUser.pet ? CPLoginResult_UserWithSetupCompleted : CPLoginResult_UserWithoutPetProfile), nil);
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

- (void)clearAuth
{
    [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
}

@end
