//
//  CPLoginController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPLoginController.h"
#import <GoogleIdentityToolkit/GITkit.h>
#import "CPSignInViewController.h"
#import "CPSignUpViewController.h"

NSString * const kLoginCompleteNotification = @"NOTE_LoginComplete";
NSString * const kLoginErrorKey = @"LoginError";

@interface CPLoginController()<GITInterfaceManagerDelegate, GITClientDelegate>

@property (nonatomic, strong) GITInterfaceManager *interfaceManager;
@property (nonatomic, strong) NSDataDetector *emailDetector;

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
    NSArray *emailMatches = [self.emailDetector matchesInString:email options:kNilOptions range:NSMakeRange(0, [email length])];
    return [emailMatches count] == 1 && [[[emailMatches firstObject] URL].scheme isEqualToString:@"mailto"];
}

#pragma mark - Flow control
- (void)startSignin
{
    [self.interfaceManager startSignIn];
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
//    [[GITAuth sharedInstance] signInWithProviderID:kGITProviderFacebook];
}

- (void)signInWithGoogle
{
    [[GITAuth sharedInstance] signInWithProviderID:kGITProviderGoogle];
}

#pragma mark - GITInterfaceManagerDelegate
- (UIViewController*)signInControllerWithAccount:(GITAccount *)account
{
    // TODO: auto sign in with cached user
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignInStart"];
}

- (UIViewController *)legacySignInControllerWithEmail:(NSString *)email
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPSignInViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
    vc.email = email;
    return vc;
}

- (UIViewController *)legacySignUpControllerWithEmail:(NSString *)email
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
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
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[kLoginErrorKey] = error;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleteNotification object:nil userInfo:userInfo];
}

@end