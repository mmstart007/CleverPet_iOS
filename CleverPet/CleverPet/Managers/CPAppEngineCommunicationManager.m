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
#import <Spark-SDK/SparkDevice.h>

NSString * const kAppEngineBaseUrl = @"app_server_url";
NSString * const kNewUserPath = @"users/new";
NSString * const kUserLoginPath = @"users/login";
NSString * const kUserLogoutPath = @"users/logout";
NSString * const kUserInfoPath = @"users/info";
NSString * const kPetProfilePath = @"animals";
#define SPECIFIC_PET_PROFILE(petId) [NSString stringWithFormat:@"%@/%@", kPetProfilePath, petId]

#define CREATE_DEVICE_FOR_ANIMAL(animalId) [NSString stringWithFormat:@"animals/%@/devices", animalId]
NSString * const kDevicePath = @"devices";
NSString * const kSchedulesPathFragment = @"schedules";
NSString * const kModePathFragment = @"mode";
#define SPECIFIC_DEVICE(deviceId) [NSString stringWithFormat:@"%@/%@", kDevicePath, deviceId]
#define SPECIFIC_DEVICE_SCHEDULES(deviceId) [NSString stringWithFormat:@"%@/%@/%@", kDevicePath, deviceId, kSchedulesPathFragment]
#define SPECIFIC_DEVICE_MODE(deviceId) [NSString stringWithFormat:@"%@/%@/%@", kDevicePath, deviceId, kModePathFragment]
#define SPECIFIC_SCHEDULE(deviceId, scheduleId) [NSString stringWithFormat:@"%@/%@/%@/%@", kDevicePath, deviceId, kSchedulesPathFragment, scheduleId]

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
    [self setAuthToken:gitKitToken];
    
    [self.sessionManager POST:kUserLoginPath parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion(CPLoginResult_Failure, [self errorForMessage:errorMessage]);
        } else {
            // Check for required auth tokens
            // TODO: bring back particle and firebase auth
            if (jsonResponse[kAuthTokenKey] && jsonResponse[kParticleAuthKey]) {
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
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager PUT:kUserLogoutPath parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErroToServerError:error]);
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
            } else if (!currentUser.device) {
                result = CPLoginResult_UserWithoutDevice;
            }
            
            if (currentUser.device && (!currentUser.device.weekdaySchedule || !currentUser.device.weekendSchedule)) {
                [self lookupDeviceSchedules:currentUser.device.deviceId completion:^(NSError *error) {
                    if (error) {
                        if (completion) completion(CPLoginResult_Failure, error);
                    } else {
                        if (completion) completion(result, nil);
                    }
                }];
            } else {
                if (completion) completion(result, nil);
            }
        }
    };
    
    if (!currentUser.device) {
        // If we have no device, we need to set the auth token for particle
        [[CPParticleConnectionHelper sharedInstance] setAccessToken:userInfo[kParticleAuthKey] completion:particleAuthSet];
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
            [self lookupPetInfo:jsonResponse[kPetIdKey] completion:completion];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion(nil, [self convertAFNetworkingErroToServerError:error]);
    }];
}

- (ASYNC)updatePet:(NSString *)petId withInfo:(NSDictionary *)petInfo completion:(void (^)(NSError *))completion
{
    NSParameterAssert(petId);
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
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErroToServerError:error]);
    }];
}

- (ASYNC)lookupPetInfo:(NSString *)petId completion:(void (^)(NSString *, NSError *))completion
{
    NSParameterAssert(petId);
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager GET:SPECIFIC_PET_PROFILE(petId) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion(nil, [self errorForMessage:errorMessage]);
        } else {
            [[CPUserManager sharedInstance] userCreatedPet:jsonResponse];
            if (completion) completion(jsonResponse[kPetIdKey], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion(nil, [self convertAFNetworkingErroToServerError:error]);
    }];
}

#pragma mark - Device
- (ASYNC)createDevice:(NSDictionary *)deviceInfo forAnimal:(NSString*)animalId completion:(void (^)(NSError *))completion
{
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager POST:CREATE_DEVICE_FOR_ANIMAL(animalId) parameters:deviceInfo progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion([self errorForMessage:errorMessage]);
        } else {
            [self lookupDeviceInfo:jsonResponse[kDeviceIdKey] completion:completion];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErroToServerError:error]);
    }];
}

- (ASYNC)updateDevice:(NSString *)deviceId mode:(NSString *)mode completion:(void (^)(NSError *))completion
{
    NSParameterAssert(deviceId);
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager PUT:SPECIFIC_DEVICE_MODE(deviceId) parameters:@{kModeKey:mode} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion([self errorForMessage:errorMessage]);
        } else {
            if (completion) completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErroToServerError:error]);
    }];
}

- (ASYNC)updateDevice:(NSString *)deviceId schedule:(NSString *)scheduleId withInfo:(NSDictionary *)scheduleInfo completion:(void (^)(NSError *))completion
{
    NSParameterAssert(scheduleId);
    NSParameterAssert(scheduleInfo);
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager PUT:SPECIFIC_SCHEDULE(deviceId, scheduleId) parameters:scheduleInfo success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion([self errorForMessage:errorMessage]);
        } else {
            if (completion) completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErroToServerError:error]);
    }];
}

- (ASYNC)lookupDeviceInfo:(NSString *)deviceId completion:(void (^)(NSError *error))completion
{
    NSParameterAssert(deviceId);
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager GET:SPECIFIC_DEVICE(deviceId) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion([self errorForMessage:errorMessage]);
        } else {
            [[CPUserManager sharedInstance] userCreatedDevice:jsonResponse];
            [self lookupDeviceSchedules:deviceId completion:completion];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErroToServerError:error]);
    }];
}

- (ASYNC)lookupDeviceSchedules:(NSString *)deviceId completion:(void (^)(NSError *error))completion
{
    NSParameterAssert(deviceId);
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager GET:SPECIFIC_DEVICE_SCHEDULES(deviceId) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion([self errorForMessage:errorMessage]);
        } else {
            [[CPUserManager sharedInstance] fetchedDeviceSchedules:jsonResponse];
            if (completion) completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErroToServerError:error]);
    }];
}

#pragma mark - Util
- (void)setAuthToken:(NSString *)authToken
{
    [self.sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", authToken] forHTTPHeaderField:@"Authorization"];
}

- (NSError *)convertAFNetworkingErroToServerError:(NSError*)error
{
    NSInteger errorCode = [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:nil];
    NSString *errorMessage = responseDict[kErrorKey] ? responseDict[kErrorKey] : [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    NSError *newError = [NSError errorWithDomain:NSStringFromClass([self class]) code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
    return newError;
}

- (NSError*)errorForMessage:(NSString *)message
{
    // TODO: error codes
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey:message}];
}

@end
