//
//  CPAppEngineCommunicationManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPAppEngineCommunicationManager.h"
#import "GITAccount.h"
#import "CPUserManager.h"
#import "CPParticleConnectionHelper.h"
#import <Spark-SDK/SparkDevice.h>
#import "CPFirebaseManager.h"
#import "CPConfigManager.h"

NSString * const kAppEngineBaseUrl = @"app_server_url";
NSString * const kNewUserPath = @"users/new";
NSString * const kUserLoginPath = @"users/login";
NSString * const kUserLogoutPath = @"users/logout";
NSString * const kUserEmailPath = @"users/email";
NSString * const kUserInfoPath = @"users/info";
NSString * const kPetProfilePath = @"animals";
#define SPECIFIC_PET_PROFILE(petId) [NSString stringWithFormat:@"%@/%@", kPetProfilePath, petId]

#define CREATE_DEVICE_FOR_ANIMAL(animalId) [NSString stringWithFormat:@"animals/%@/devices", animalId]
NSString * const kDevicePath = @"devices";
NSString * const kSchedulesPathFragment = @"schedules";
NSString * const kParticlePathFragment = @"particle";
NSString * const kLastSeenPathFragment = @"lastseen";
#define SPECIFIC_DEVICE(deviceId) [NSString stringWithFormat:@"%@/%@", kDevicePath, deviceId]
#define SPECIFIC_DEVICE_SCHEDULES(deviceId) [NSString stringWithFormat:@"%@/%@/%@", kDevicePath, deviceId, kSchedulesPathFragment]
#define SPECIFIC_DEVICE_PARTICLE(deviceId) [NSString stringWithFormat:@"%@/%@/%@", kDevicePath, deviceId, kParticlePathFragment]
#define DEVICE_LAST_SEEN(deviceId) [NSString stringWithFormat:@"%@/%@/%@", kDevicePath, deviceId, kLastSeenPathFragment]
#define SPECIFIC_SCHEDULE(deviceId, scheduleId) [NSString stringWithFormat:@"%@/%@/%@/%@", kDevicePath, deviceId, kSchedulesPathFragment, scheduleId]

#define PARTICLES_FAILEDPAIRING(deviceId) [NSString stringWithFormat:@"particles/%@/failedpairing", deviceId]

#define PARTICLE_ENABLED 1

#if !PARTICLE_ENABLED
#warning #### Particle is not enabled! Please enable before checking in!
#endif

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
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    if (self.sessionManager) {
        // If we already have a session manager, we want to transfer our request serializer across so we don't lose our auth header
        requestSerializer = self.sessionManager.requestSerializer;
        responseSerializer = self.sessionManager.responseSerializer;
    }
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:configData[kAppEngineBaseUrl]]];
    self.sessionManager.requestSerializer = requestSerializer;
    self.sessionManager.responseSerializer = responseSerializer;
}

- (AFHTTPSessionManager*)getSessionManager
{
    return self.sessionManager;
}

- (NSString*)currentAuthHeader
{
    return [self.sessionManager.requestSerializer valueForHTTPHeaderField:@"Authorization"];
}

#pragma mark - Login and user calls
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
                [[CPFirebaseManager sharedInstance] userLoggedIn:jsonResponse withCompletion:^(NSError *error) {
                    if (!error) {
                        [self setAuthToken:jsonResponse[kAuthTokenKey]];
                        [[CPUserManager sharedInstance] userLoggedIn:jsonResponse];
                        [self userLoggedIn:jsonResponse completion:completion];
                    } else if (completion) {
                        completion(CPLoginResult_Failure, error);
                    }
                }];
            } else {
                // TODO: update message with specific token missing
                if (completion) completion(CPLoginResult_Failure, [self errorForMessage:NSLocalizedString(@"Missing auth token", nil)]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        // Clear the auth header as we will now be in a fresh login state
        [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
        if (completion) completion(CPLoginResult_Failure, [self convertAFNetworkingErrorToServerError:error]);
    }];
}

- (ASYNC)logoutWithCompletion:(void (^)(NSError *))completion
{
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager PUT:kUserLogoutPath parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
    }];
    // Clear our auth header regardless of if the call is successful or not, as we've already dumped the user back to login
    [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
}

- (ASYNC)forgotPasswordForEmail:(NSString *)email completion:(void (^)(NSError *error))completion {
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager POST:kUserEmailPath parameters:@{@"email":email, @"action":@"resetPassword"}
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                          if (completion) completion(nil);
                      }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          BLOCK_SELF_REF_INSIDE();
                          if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
                      }];
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
#if PARTICLE_ENABLED
                result = CPLoginResult_UserWithoutDevice;
#endif
            } else if (!currentUser.device.particleId) {
#if PARTICLE_ENABLED
                result = CPLoginResult_UserWithoutParticle;
#endif
            }
            
#if PARTICLE_ENABLED
            if ((currentUser.device && currentUser.device.particleId) && (!currentUser.device.weekdaySchedule || !currentUser.device.weekendSchedule)) {
                [self lookupDeviceSchedules:currentUser.device.deviceId completion:^(NSError *error) {
                    if (error) {
                        if (completion) completion(CPLoginResult_Failure, error);
                    } else {
                        if (completion) completion(result, nil);
                    }
                }];
            } else {
#endif
                if (completion) completion(result, nil);
#if PARTICLE_ENABLED
            }
#endif
        }
    };
    
    if (!currentUser.device || !currentUser.device.particleId) {
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
        if (completion) completion(nil, [self convertAFNetworkingErrorToServerError:error]);
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
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
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
        if (completion) completion(nil, [self convertAFNetworkingErrorToServerError:error]);
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
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
    }];
}

- (ASYNC)updateDevice:(NSString *)deviceId mode:(NSDictionary*)deviceInfo completion:(void (^)(NSError *))completion
{
    NSParameterAssert(deviceId);
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager PUT:SPECIFIC_DEVICE(deviceId) parameters:deviceInfo success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
    }];
}

- (ASYNC)updateDevice:(NSString *)deviceId particle:(NSDictionary *)particleInfo completion:(void (^)(NSError *))completion
{
    NSParameterAssert(deviceId);
    NSParameterAssert(particleInfo);
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager PUT:SPECIFIC_DEVICE_PARTICLE(deviceId) parameters:particleInfo success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion([self errorForMessage:errorMessage]);
        } else {
            [self lookupDeviceInfo:deviceId completion:completion];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
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
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
    }];
}

- (ASYNC)checkDeviceLastSeen:(NSString *)deviceId completion:(void (^)(NSInteger, NSError *))completion
{
    NSParameterAssert(deviceId);
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager GET:DEVICE_LAST_SEEN(deviceId) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (jsonResponse[kErrorKey]) {
            NSString *errorMessage = jsonResponse[kErrorKey];
            if (completion) completion(NSNotFound, [self errorForMessage:errorMessage]);
        } else {
            NSInteger delta = (jsonResponse[kLastSeenKey] && ![jsonResponse[kLastSeenKey] isKindOfClass:[NSNull class]]) ? [jsonResponse[kLastSeenKey] integerValue] : NSNotFound;
            if (completion) completion(delta, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion(NSNotFound, [self convertAFNetworkingErrorToServerError:error]);
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
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
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
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
    }];
}

#pragma mark - Util
- (void)setAuthToken:(NSString *)authToken
{
    [self.sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", authToken] forHTTPHeaderField:@"Authorization"];
}

- (ASYNC)performLogoutWithAuthHeader:(NSString *)authHeader completion:(void (^)(NSError *))completion
{
    NSString *serverUrl = [[CPConfigManager sharedInstance] getServerUrl];
    if (serverUrl) {
        
        // Spin up a session manager so we don't mess with our regular auth
        AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:serverUrl]];
        sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [sessionManager.requestSerializer setValue:authHeader forHTTPHeaderField:@"Authorization"];
                                                
        BLOCK_SELF_REF_OUTSIDE();
        [sessionManager PUT:kUserLogoutPath parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completion) completion(nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BLOCK_SELF_REF_INSIDE();
            if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
        }];
    } else {
        if (completion) completion([self errorForMessage:@"Config not set up"]);
    }
}

- (ASYNC)reportParticleDeviceConnectionFailure:(NSString *)failureReason deviceId:(NSString *)deviceId
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (failureReason) {
        parameters[@"error_code"] = failureReason;
    }
    
    if (!deviceId.length) {
        deviceId = @"unknown";
    }
    
    [self.sessionManager POST:PARTICLES_FAILEDPAIRING(deviceId) parameters:parameters progress:nil success:nil failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to report pairing error: %@", error);
    }];
}

@end
