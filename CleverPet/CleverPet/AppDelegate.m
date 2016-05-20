//
//  AppDelegate.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleIdentityToolkit/GITkit.h>
#import <GoogleSignin/GoogleSignin.h>
#import "CPAppearance.h"
#import <Intercom/Intercom.h>
#import "CPConfigManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Google/CloudMessaging.h>
#import "CPGCMManager.h"
#import "CPUserManager.h"
#import "CPPlayerViewController.h"

typedef void (^gcmHandler)(NSString *token, NSError *error);

@interface AppDelegate ()<GGLInstanceIDDelegate>

@property (nonatomic, copy) gcmHandler gcmHandler;
@property (nonatomic, strong) NSDictionary *registrationOptions;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setupGoogleIdentityToolkit];
    [CPAppearance initCustomAppearance];
    
    // Initialize Intercom
    [Intercom setApiKey:@"ios_sdk-7acac94f6c642142e21fd6e6be0bbc7b4d38f7cc" forAppId:@"swragh2u"];
    // Register an unidentified user for use on the sign in page. On login, we'll update this with the appropriate user
    [Intercom registerUnidentifiedUser];
    
    // Have reachability manager start monitoring, for use in the settings
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [Fabric with:@[[Crashlytics class]]];
    
    // Register for notifications
    [self initializeGCM];
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[CPConfigManager sharedInstance] appEnteredForeground];
    [[CPUserManager sharedInstance] processPendingLogouts];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if([window.rootViewController isKindOfClass:[PresentVideoPlayerViewController class]]) {
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    self.registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@YES};
    [self obtainGCMToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Notification received: %@", userInfo);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    //let app handle redirect
    [[NSNotificationCenter defaultCenter] postNotificationName:kWaitForURLHandle object:nil];
    // Handle custom scheme redirect here.
    return [GITClient handleOpenURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)setupGoogleIdentityToolkit
{
    GITClient *gitkitClient = [GITClient sharedInstance];
    gitkitClient.apiKey = @MACRO_VALUE(GITKIT_API_KEY);
    gitkitClient.widgetURL = @"http://v2-dot-cleverpetcloud.appspot.com/users/login/widget";
    gitkitClient.providers = @[kGITProviderGoogle, kGITProviderFacebook];
    
    NSString *gidClientID = @MACRO_VALUE(GOOGLE_CLIENT_ID);
    [GIDSignIn sharedInstance].clientID = gidClientID;
    NSLog(@"Using google client id %@", gidClientID);
}

#pragma mark - GGLInstanceIDDelegate
- (void)onTokenRefresh
{
    [self obtainGCMToken];
}

- (void)initializeGCM
{
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    
    self.gcmHandler = ^(NSString *token, NSError *error) {
        if (!error) {
            NSLog(@"Token: %@", token);
            [[CPGCMManager sharedInstance] obtainedGCMToken:token];
        }
        // TODO: handle error
    };
}

- (void)obtainGCMToken
{
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:@"879679195763"
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:self.registrationOptions
                                                      handler:self.gcmHandler];
}

@end
