//
//  CPConfigManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPConfigManager.h"
#import "CPParticleConnectionHelper.h"
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

- (void)loadConfigWithCompletion:(void (^)(NSError *))completion
{
    [self.sessionManager GET:kConfigUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // Apply config
        // TODO: version check, deprecation message, etc
        [[CPParticleConnectionHelper sharedInstance] applyConfig:responseObject];
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(error);
    }];
}

@end
