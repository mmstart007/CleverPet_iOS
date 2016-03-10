//
//  CPGCMManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-10.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPGCMManager.h"
#import "CPAppEngineCommunicationManager.h"
#import <AFNetworking/AFNetworking.h>
#import "CPUserManager.h"

@interface CPGCMManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSString *gcmToken;

@end

@implementation CPGCMManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPGCMManager *s_sharedInstance;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[CPGCMManager alloc] init];
    });
    return s_sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Borrow app engines session manager so we don't need to handle auth in multiple places
        self.sessionManager = [[CPAppEngineCommunicationManager sharedInstance] getSessionManager];
    }
    return self;
}

- (void)userLoggedIn
{
    [self sendTokenToServer];
}

- (void)obtainedGCMToken:(NSString *)token
{
    self.gcmToken = token;
    [self sendTokenToServer];
}

- (ASYNC)sendTokenToServer
{
    if (self.gcmToken && [[CPUserManager sharedInstance] getCurrentUser]) {
        [self.sessionManager POST:@"users/notificationgroup" parameters:@{kGCMTokenKey:self.gcmToken} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // TODO: probably nothing
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // TODO: attempt to resend?
        }];
    }
}

@end
