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

- (NSString*)getToken
{
    return self.gcmToken;
}

- (ASYNC)sendTokenToServer
{
    if (self.gcmToken && [[CPUserManager sharedInstance] getCurrentUser]) {
        
        if (!self.sessionManager) {
            // Borrow app engines session manager so we don't need to handle auth in multiple places. Check just before we want to use it, since if we retrieve the gcm token before the app has loaded config, the session manager will not have been created
            self.sessionManager = [[CPAppEngineCommunicationManager sharedInstance] getSessionManager];
        }
            
        [self.sessionManager POST:@"users/notificationgroup" parameters:@{kGCMTokenKey:self.gcmToken} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // TODO: probably nothing
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // TODO: attempt to resend?
        }];
    }
}

@end
