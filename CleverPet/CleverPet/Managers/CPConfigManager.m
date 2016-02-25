//
//  CPConfigManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPConfigManager.h"
#import "CPParticleConnectionHelper.h"
#import "CPAppEngineCommunicationManager.h"
#import <AFNetworking/AFNetworking.h>

NSString * const kConfigUrl = @"https://storage.googleapis.com/cleverpet-app/configs/config.json";

@interface CPConfigManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation CPConfigManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPConfigManager *s_sharedInstance;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[CPConfigManager alloc] init];
    });
    return s_sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc] init];
    }
    return self;
}

- (ASYNC)loadConfigWithCompletion:(void (^)(NSError *))completion
{
    BLOCK_SELF_REF_OUTSIDE();
    [self.sessionManager GET:kConfigUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_SELF_REF_INSIDE();
        // TODO: version check, deprecation message, etc
        [self applyConfig:responseObject];
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(error);
    }];
}

- (void)applyConfig:(NSDictionary *)configData
{
    [[CPParticleConnectionHelper sharedInstance] applyConfig:configData];
    [[CPAppEngineCommunicationManager sharedInstance] applyConfig:configData];
}

@end
