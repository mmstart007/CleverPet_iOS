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
#import "CPUserManager.h"

#define USE_LOCAL_CONFIG 0
#if USE_LOCAL_CONFIG
#warning #### Local config is enabled! Please disable before checking in!
#endif

NSString * const kMinimumVersionKey = @"minimum_required_version";
NSString * const kDeprecationMessageKey = @"deprecation_message";
NSString * const kDefaultDeprecationMessage = @"Your app does not meet the minimum version. Do something about it.";
NSString * const kLastCheckedConfigKey = @"UserDefaults_LastCheckedConfig";
NSString * const kConfigUpdatedNotification = @"NOTE_ConfigUpdated";
NSString * const kConfigErrorKey = @"error";

NSTimeInterval const kMinimumTimeBetweenChecks = 60 * 60; // 1 hour

@interface CPConfigManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) CPConfigViewController *configViewController;
@property (nonatomic, strong) NSDictionary *configData;
@property (nonatomic, assign) BOOL listeningForReachability;
@property (nonatomic, assign) AFNetworkReachabilityStatus lastStatus;
@property (nonatomic, assign) BOOL hubClaimingInProgress;

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
        
        NSLog(@"Using gitkit project id (in plist file) %@", @MACRO_VALUE(GITKIT_PROJECT_ID));
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (ASYNC)loadConfig:(BOOL)forceLoad completion:(void (^)(NSError *))completion
{
    
    if (!self.hubClaimingInProgress && (!self.configData || forceLoad)) {
#if !USE_LOCAL_CONFIG
        BLOCK_SELF_REF_OUTSIDE();
        NSString *configURL = [NSString stringWithFormat:@"https://storage.googleapis.com/cleverpet-app/configs/%s/config.json", MACRO_VALUE(SERVER_CONFIG_URL)];
        NSLog(@"Using config url: %@", configURL);
        [self.sessionManager GET:configURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            BLOCK_SELF_REF_INSIDE();
#else
            NSString *localConfigPath = [[NSBundle mainBundle] pathForResource:@"localConfig" ofType:@"json"];
            NSData *localConfigData = [NSData dataWithContentsOfFile:localConfigPath];
            NSError *error = nil;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:localConfigData options:0 error:&error];
            if (error) {
                if (completion) completion(error);
                return;
            }
#endif
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
                    NSError *configError = [NSError errorWithDomain:@"AppVersion" code:1 userInfo:@{NSLocalizedDescriptionKey:deprecationMessage}];
                    if (completion) completion(configError);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kConfigUpdatedNotification object:nil userInfo:@{kConfigErrorKey:configError}];
                    return;
                }
            }
            [self applyConfig:responseObject];
        	[[CPUserManager sharedInstance] processPendingLogouts];
            [[NSNotificationCenter defaultCenter] postNotificationName:kConfigUpdatedNotification object:nil userInfo:@{}];
            if (completion) completion(nil);
#if !USE_LOCAL_CONFIG
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // TODO: Perhaps ignore the timer the next time we see if we should check so the user isn't shut out of the app?
            // If we're offline, register for reachability notifications and update when appropriate
            BLOCK_SELF_REF_INSIDE();
            if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
                [self listenForReachability];
            }
            if (completion) completion(error);
        }];
#endif
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
    
    if (timeSinceCheck > kMinimumTimeBetweenChecks && !self.hubClaimingInProgress) {
        if (!self.configViewController) {
            // Find our currently displayed view controller
            // Again, this should really be updated to account for plain view controllers as the root, but currently(and for the conceivable future) we'll always have a nav controller as our root
            UINavigationController *rootView = (UINavigationController*)[[[UIApplication sharedApplication].delegate window] rootViewController];
            self.configViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ConfigView"];
            [rootView presentViewController:self.configViewController animated:YES completion:nil];
        }
        [self.configViewController setAnimating:YES];
        
        [self performAppForegroundedCheck:YES];
    }
}

- (void)performAppForegroundedCheck:(BOOL)allowRetry
{
    // TODO: Prevent multiple requests when hitting this frequently
    BLOCK_SELF_REF_OUTSIDE();
    [self loadConfig:YES completion:^(NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (error) {
            // This request sometimes fails on iOS 9 when foregrounding the app immediately after unlocking the device. If we failed because the network connection was lost, we suspect this was the case. So, instead of displaying an error, perform a single retry
            if (allowRetry && [error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorNetworkConnectionLost) {
                [self performAppForegroundedCheck:NO];
            } else {
                NSString *errorTitle = [error.domain isEqualToString:@"AppVersion"] ? NSLocalizedString(@"App Version Out of Date", @"Title for alert shown when using out of date version of the app") : NSLocalizedString(@"Unable to load app config", @"Title for error shown when unable to load app config");
                [self.configViewController displayErrorAlertWithTitle:errorTitle andMessage:error.localizedDescription];
            }
        } else {
            if (self.configViewController) {
                [self.configViewController dismiss];
                self.configViewController = nil;
            }
        }
    }];
}

- (NSString*)getServerUrl
{
    return self.configData[@"app_server_url"];
}

// Using notifications so we don't have to worry about overriding reachability update blocks if somewhere else needs them as well
- (void)listenForReachability
{
    if (!self.listeningForReachability) {
        self.listeningForReachability = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
}

- (void)stopListeningForReachability
{
    if (self.listeningForReachability) {
        self.listeningForReachability = NO;
        self.lastStatus = AFNetworkReachabilityStatusUnknown;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    AFNetworkReachabilityStatus status = [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if ((status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) && status != self.lastStatus) {
        BLOCK_SELF_REF_OUTSIDE();
        [self loadConfig:YES completion:^(NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (!error) {
                [self stopListeningForReachability];
                if (self.configViewController) {
                    [self.configViewController dismiss];
                    self.configViewController = nil;
                }
            }
        }];
    }
    self.lastStatus = status;
}

- (void)hubClaimingBegan
{
    self.hubClaimingInProgress = YES;
}

- (void)hubClaimingEnded
{
    self.hubClaimingInProgress = NO;
}

@end
