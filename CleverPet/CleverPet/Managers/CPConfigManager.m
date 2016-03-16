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
#import "CPFirebaseManager.h"
#import <AFNetworking/AFNetworking.h>
#import "CPConfigViewController.h"

NSString * const kConfigUrl = @"https://storage.googleapis.com/cleverpet-app/configs/config.json";
NSString * const kMinimumVersionKey = @"minimum_required_version";
NSString * const kDeprecationMessageKey = @"deprecation_message";
NSString * const kDefaultDeprecationMessage = @"Your app does not meet the minimum version. Do something about it.";
NSString * const kLastCheckedConfigKey = @"UserDefaults_LastCheckedConfig";

NSTimeInterval const kMinimumTimeBetweenChecks = 60 * 60; // 1 hour

@interface CPConfigManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) CPConfigViewController *configViewController;
@property (nonatomic, strong) NSDictionary *configData;

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
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.URLCache = nil;
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    }
    return self;
}

- (ASYNC)loadConfigWithCompletion:(void (^)(NSError *))completion
{
    NSDate *lastChecked = [[NSUserDefaults standardUserDefaults] objectForKey:kLastCheckedConfigKey];
    NSTimeInterval timeSinceCheck = [[NSDate date] timeIntervalSinceDate:lastChecked];
    
    if (timeSinceCheck > kMinimumTimeBetweenChecks) {
        BLOCK_SELF_REF_OUTSIDE();
        [self.sessionManager GET:kConfigUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            BLOCK_SELF_REF_INSIDE();
            // Update our last checked config date
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastCheckedConfigKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *minimumVersion = responseObject[kMinimumVersionKey];
            // Ignore the minimum version set on our test config
            if (minimumVersion && ![minimumVersion isEqualToString:@"test"]) {
                if ([version compare:minimumVersion options:NSNumericSearch] == NSOrderedAscending) {
                    NSString *deprecationMessage = responseObject[kDeprecationMessageKey];
                    if ([deprecationMessage length] == 0) {
                        deprecationMessage = kDefaultDeprecationMessage;
                    }
                    if (completion) completion([NSError errorWithDomain:@"AppVersion" code:1 userInfo:@{NSLocalizedDescriptionKey:deprecationMessage}]);
                    return;
                }
            }
            [self applyConfig:responseObject];
            if (completion) completion(nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // TODO: Perhaps ignore the timer the next time we see if we should check so the user isn't shut out of the app?
            // If we're offline, register for reachability notifications and update when appropriate
            if (completion) completion(error);
        }];
    } else {
        if (completion) completion(nil);
    }
}

- (void)applyConfig:(NSDictionary *)configData
{
    if (![configData isEqualToDictionary:self.configData])
    {
        self.configData = configData;
        [[CPParticleConnectionHelper sharedInstance] applyConfig:configData];
        [[CPAppEngineCommunicationManager sharedInstance] applyConfig:configData];
        [[CPFirebaseManager sharedInstance] applyConfig:configData];
    }
}

- (void)appEnteredForeground
{
    NSDate *lastChecked = [[NSUserDefaults standardUserDefaults] objectForKey:kLastCheckedConfigKey];
    NSTimeInterval timeSinceCheck = [[NSDate date] timeIntervalSinceDate:lastChecked];
    
    if (timeSinceCheck > kMinimumTimeBetweenChecks) {
        if (!self.configViewController) {
            // Find our currently displayed view controller
            // Again, this should really be updated to account for plain view controllers as the root, but currently(and for the conceivable future) we'll always have a nav controller as our root
            UINavigationController *rootView = (UINavigationController*)[[[UIApplication sharedApplication].delegate window] rootViewController];
            self.configViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ConfigView"];
            [rootView presentViewController:self.configViewController animated:YES completion:nil];
        }
        [self.configViewController setAnimating:YES];
        
        // TODO: Prevent multiple requests when hitting this frequently
        BLOCK_SELF_REF_OUTSIDE();
        [self loadConfigWithCompletion:^(NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (error) {
                NSString *errorTitle = [error.domain isEqualToString:@"AppVersion"] ? NSLocalizedString(@"App Version Out of Date", @"Title for alert shown when using out of date version of the app") : NSLocalizedString(@"Unable to load app config", @"Title for error shown when unable to load app config");
                [self.configViewController displayErrorAlertWithTitle:errorTitle andMessage:error.localizedDescription];
            } else {
                [self.configViewController dismiss];
                self.configViewController = nil;
            }
        }];
    }
}

@end
