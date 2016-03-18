//
//  CPLoginController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPLoginController.h"
#import <GoogleIdentityToolkit/GITkit.h>
#import "CPNascarViewController.h"
#import "CPSignInViewController.h"
#import "CPSignUpViewController.h"
#import "CPParticleConnectionHelper.h"
#import "CPAppEngineCommunicationManager.h"
#import "CPFileUtils.h"
#import "CPUserManager.h"
#import <Intercom/Intercom.h>
#import <SSKeychain/SSKeychain.h>
#import "CPHubPlaceholderViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>

#define DEFAULT_ERROR_MESSAGE NSLocalizedString(@"An unexpected error occurred. Please try again.", @"Error message displayed for unhandled login error codes")
NSString * const kAutoLogin = @"CPLoginControllerAutoLogin";

@interface CPLoginController()<GITInterfaceManagerDelegate, GITClientDelegate, CPParticleConnectionDelegate, CPHubPlaceholderDelegate>

@property (nonatomic, strong) GITInterfaceManager *interfaceManager;
@property (nonatomic, strong) NSDataDetector *emailDetector;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, weak) id<CPLoginControllerDelegate> delegate;
@property (nonatomic, strong) NSString *pendingAuthToken;
@property (nonatomic, strong) CPHubPlaceholderViewController *hubPlaceholderVc;

@end

@implementation CPLoginController

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPLoginController *s_Instance;
    dispatch_once(&onceToken, ^{
        s_Instance = [[CPLoginController alloc] init];
        s_Instance.emailDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    });
    return s_Instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.interfaceManager = [[GITInterfaceManager alloc] init];
        self.interfaceManager.delegate = self;
        [GITClient sharedInstance].delegate = self;
    }
    return self;
}

- (BOOL)isValidEmail:(NSString *)email
{
    // If we have any spaces, this is a bogus email
    NSRange spaceRange = [email rangeOfString:@" "];
    if (spaceRange.location != NSNotFound) {
        return NO;
    }
    
    NSArray *emailMatches = [self.emailDetector matchesInString:email options:kNilOptions range:NSMakeRange(0, [email length])];
    return [emailMatches count] == 1 && [[[emailMatches firstObject] URL].scheme isEqualToString:@"mailto"];
}

- (void)setPendingUserInfo:(NSDictionary *)userInfo
{
    self.userInfo = userInfo;
}

- (void)completeSignUpWithPetImage:(UIImage *)image completion:(void (^)(NSError *))completion
{
    // TODO: image storage
    // TODO: verification
    BLOCK_SELF_REF_OUTSIDE();
    [[CPAppEngineCommunicationManager sharedInstance] createPetProfileWithInfo:self.userInfo completion:^(NSString *petId, NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (completion) completion(error);
        if (!error) {
            [CPFileUtils saveImage:image forPet:petId];
            [self presentUIForLoginResult:CPLoginResult_UserWithoutDevice];
        }
    }];
}

#pragma mark - Flow control
- (void)startSigninWithDelegate:(id<CPLoginControllerDelegate>)delegate
{
    self.delegate = delegate;
    NSString *autoLoginToken = [SSKeychain passwordForService:kAutoLogin account:kAutoLogin];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoLogin] && autoLoginToken) {
        BLOCK_SELF_REF_OUTSIDE();
        [[CPAppEngineCommunicationManager sharedInstance] loginWithAuthToken:autoLoginToken completion:^(CPLoginResult result, NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (result == CPLoginResult_Failure) {
                // TODO: don't clear keychain on failure because device is offline
                // We don't need to display this error, as we'll just enter the regular sign in flow
                [self clearAutoLoginToken];
                [self startSigninWithDelegate:self.delegate];
            } else {
                [self presentUIForLoginResult:result];
            }
        }];
    } else {
        [self.interfaceManager startSignIn];
    }
}

- (void)signInWithEmail:(NSString *)email
{
    [[GITAuth sharedInstance] signInWithEmail:email];
}

- (void)verifyPassword:(NSString *)password forEmail:(NSString *)email failure:(void (^)(void))failure
{
    [[GITAuth sharedInstance] verifyPassword:password forEmail:email invalidCallback:failure];
}

- (void)signUpWithEmail:(NSString *)email displayName:(NSString *)displayName andPassword:(NSString *)password
{
    [[GITAuth sharedInstance] signUpWithEmail:email displayName:displayName password:password];
}

- (void)signInWithFacebook
{
    [[GITAuth sharedInstance] signInWithProviderID:kGITProviderFacebook];
}

- (void)signInWithGoogle
{
    [[GITAuth sharedInstance] signInWithProviderID:kGITProviderGoogle];
}

- (void)loginViewPressedCancel:(UIViewController *)viewController
{
    [self.delegate loginAttemptCancelled];
    [self.interfaceManager popViewController];
}

- (void)cancelPetProfileCreation
{
    self.userInfo = nil;
    // Logout of google identity so the user needs to enter their password if signing in with google
    [self logoutOfGit];
    [self.delegate loginAttemptCancelled];
    [[CPSharedUtils getRootNavController] popToRootViewControllerAnimated:YES];
}

#pragma mark - GITInterfaceManagerDelegate
- (UIViewController*)signInControllerWithAccount:(GITAccount *)account
{
    return [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"SignInStart"];
}

- (UIViewController *)legacySignInControllerWithEmail:(NSString *)email
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CPSignInViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
    vc.email = email;
    return vc;
}

- (UIViewController *)legacySignUpControllerWithEmail:(NSString *)email
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    CPSignUpViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SignUp"];
    vc.email = email;
    return vc;
}

//- (UIViewController *)accountLinkingControllerWithUnverifiedProvider:(NSString *)unverifiedProvider
//                                                    verifiedProvider:(NSString *)verifiedProvider
//{
//        return [[GKDCustomFederatedAccountLinkingViewController alloc]
//                initWithUnverifiedProvider:unverifiedProvider
//                verifiedProvider:verifiedProvider];
//}

//- (UIViewController *)accountLinkingControllerWithUnverifiedProvider:(NSString *)unverifiedProvider
//{
//        return [[GKDCustomLegacyAccountLinkingViewController alloc]
//                initWithUnverifiedProvider:unverifiedProvider];
//}

#pragma mark - GITClientDelegate
- (void)client:(GITClient *)client
didFinishSignInWithToken:(NSString *)token
       account:(GITAccount *)account
         error:(NSError *)error
{
    if (error) {
        // Check if the device is currently online
        NSString *errorMessage;
        if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
            errorMessage = NSLocalizedString(@"The internet connection appears to be offline.", @"Error message displayed when attempting to log in to Google Identity while the device is offline");
        } else if ([error.domain isEqualToString:@"com.google.gitkit"]) { // Not great, but I haven't been able to find a define for the domain
            if (error.code == kGITErrorCodeUserCancellation) {
                // No error message, we don't need to tell the user what they did
            } else if(error.code == kGITErrorCodeEmailMismatch) {
                // The login web form is presented by identity toolkit, and we can't force the user to enter the same email in the gmail web form as they did in the app, so it's possible to hit this error. Tell the user they need to use the same email they started the sign up flow with, and we also need to logout of GITAuth, as the user is actually logged in to Google Identity, despite receiving an error and no user account here
                errorMessage = NSLocalizedString(@"The email address signed in to does not match the address provided on the sign in page. Please try again with the correct email.", @"Error message displayed when user uses 2 different emails as part of google sign in");
                [self logoutOfGit];
            } else {
                errorMessage = DEFAULT_ERROR_MESSAGE;
            }
        } else if ([error.domain isEqualToString:kGIDSignInErrorDomain]) {
            if (error.code == kGIDSignInErrorCodeCanceled) {
                // User cancelation and denying access have the same error code, so we have to parse the description; ;
                // This potentially doesn't work if the user changes their locale
                NSString *message = error.localizedDescription;
                if ([message isEqualToString:@"access_denied"]) {
                    errorMessage = NSLocalizedString(@"This app require access to your email address and profile info. You cannot continue without allowing access.", @"Error message displayed when access to google account info is denied");
                }
            } else {
                errorMessage = DEFAULT_ERROR_MESSAGE;
            }
        }
        
        [self.delegate loginAttemptFailed:errorMessage];
    } else {
        self.pendingAuthToken = token;
        BLOCK_SELF_REF_OUTSIDE();
        [[CPAppEngineCommunicationManager sharedInstance] loginWithAuthToken:token completion:^(CPLoginResult result, NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (result == CPLoginResult_Failure) {
                // TODO: nicer error handling
                [self.delegate loginAttemptFailed:error.localizedDescription];
            } else {
                [Intercom registerUserWithUserId:account.localID email:account.email];
                
                [self presentUIForLoginResult:result];
            }
        }];
    }
}

#pragma mark - CPParticleConnectionDelegate methods
- (void)deviceClaimed:(NSDictionary *)deviceInfo
{
    BLOCK_SELF_REF_OUTSIDE();
    void (^completion)(NSError *) = ^(NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (error) {
            // TODO: display error to user and relaunch device claim flow
            [self deviceClaimFailed];
        } else {
            [self presentUIForLoginResult:CPLoginResult_UserWithSetupCompleted];
        }
    };
    
    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
    if (currentUser.device && !currentUser.device.particleId) {
        [[CPAppEngineCommunicationManager sharedInstance] updateDevice:currentUser.device.deviceId particle:deviceInfo completion:completion];
    } else {
        [[CPAppEngineCommunicationManager sharedInstance] createDevice:deviceInfo forAnimal:currentUser.pet.petId completion:completion];
    }
}

- (void)deviceClaimCanceled
{
    [self.hubPlaceholderVc displayMessage:NSLocalizedString(@"If you do not complete Hub WiFi Setup, the Hub won't adapt to your dog or offer your dog new challenges.\n\nYou also won't be able to see how your dog is doing through the CleverPet mobile app.", @"Message displayed to user when they cancel out of the particle device claim flow")];
}

- (void)deviceClaimFailed
{
    [self.hubPlaceholderVc displayMessage:NSLocalizedString(@"Uh oh! Your Hub didn't connect to WiFi. Is the WiFi signal where you put the Hub strong enough? Was the password entered correctly?\n\nLet's try connecting again. Make sure your phone is no longer connected to the Hub's network.\n\nUnplug the Hub from the wall, then plug back in. When the light on the Hub dome flashes blue, press Continue.", @"Message displayed to user when particle device claim fails")];
}

#pragma mark - CPHubPlaceholderDelegate methods
- (void)hubSetupCancelled
{
    [self logoutOfGit];
    [self.delegate loginAttemptCancelled];
    [[CPSharedUtils getRootNavController] popToRootViewControllerAnimated:YES];
    self.hubPlaceholderVc = nil;
}

- (void)hubSetupContinued
{
    [[CPParticleConnectionHelper sharedInstance] presentSetupControllerOnController:[CPSharedUtils getRootNavController] withDelegate:self];
}

#pragma mark - UI flow
- (void)presentUIForLoginResult:(CPLoginResult)result
{
    switch (result) {
        case CPLoginResult_Failure:
        {
            NSAssert(NO, @"Login failure should have been handled already");
            break;
        }
        case CPLoginResult_UserWithoutPetProfile:
        {
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"PetProfileSetup"];
            [[CPSharedUtils getRootNavController] pushViewController:vc animated:YES];
            break;
        }
        case CPLoginResult_UserWithoutParticle:
        {
            [self presentHubPlaceholderWithMessage:NSLocalizedString(@"We don't have a record of this Hub. Did anyone recently create a new account for this Hub? Log in to the last account which was set up to avoid losing data.\n\nIf this Hub has not been set up yet, let's set up your Hub!", @"Message displayed to user when hub has been claimed out from under them")];
            break;
        }
        case CPLoginResult_UserWithoutDevice:
        {
            [self presentHubPlaceholderWithMessage:nil];
            [[CPParticleConnectionHelper sharedInstance] presentSetupControllerOnController:[CPSharedUtils getRootNavController] withDelegate:self];
            break;
        }
        case CPLoginResult_UserWithSetupCompleted:
        {
            self.hubPlaceholderVc = nil;
            // We've made it completely through our signin/account setup flow. Store the users auth token in the keychain to support autologin.
            // Just storing by our auto login name, since the user id is irrelevant, we just want the last user
            [self setAutoLoginToken:self.pendingAuthToken];
            self.pendingAuthToken = nil;
            
            // Swap our root controller for the main screen
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainScreenNav"];
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            [window setRootViewController:vc];
            [window makeKeyAndVisible];
            
            CATransition *animation = [CATransition animation];
            [animation setDuration:.3f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [animation setType:kCATransitionFade];
            [window.layer addAnimation:animation forKey:@"crossFade"];
            // TODO: it's taking forever(~4 seconds) for the main screen to actually be presented after calling this code. Investigate with time profiler
            break;
        }
    }
}

- (void)presentHubPlaceholderWithMessage:(NSString *)message
{
    CPHubPlaceholderViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"HubPlaceholder"];
    self.hubPlaceholderVc = vc;
    vc.message = message;
    vc.delegate = self;
    vc.shouldConfirmCancellation = YES;
    
    UINavigationController *root = [CPSharedUtils getRootNavController];
    [root pushViewController:vc animated:YES];
}

- (void)logout
{
    [Intercom reset];
    [self logoutOfGit];
    
    // Clear auto login token from keychain
    [self clearAutoLoginToken];
    
    // Interface manager setup is tied into the root controller when it's instantiated, so reset it
    self.interfaceManager = [[GITInterfaceManager alloc] init];
    self.interfaceManager.delegate = self;
    [GITClient sharedInstance].delegate = self;
    
    // Swap root controller for splash
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window setRootViewController:vc];
    [window makeKeyAndVisible];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:.3f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setType:kCATransitionFade];
    [window.layer addAnimation:animation forKey:@"crossFade"];
}

- (void)logoutOfGit
{
    [[GITAuth sharedInstance] signOut];
}

- (void)setAutoLoginToken:(NSString*)authToken
{
    // We set true to user defaults so we can kill auto login across device installs, as the keychain is not cleared on app uninstall, but defaults are
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SSKeychain setPassword:self.pendingAuthToken forService:kAutoLogin account:kAutoLogin];
}

- (void)clearAutoLoginToken
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAutoLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SSKeychain deletePasswordForService:kAutoLogin account:kAutoLogin];
}

@end
