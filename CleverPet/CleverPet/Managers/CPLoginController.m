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
#import "CPParticleConnectionHelper.h"
#import "CPAppEngineCommunicationManager.h"

NSString * const kLoginCompleteNotification = @"NOTE_LoginComplete";
NSString * const kLoginErrorKey = @"LoginError";

@interface CPLoginController()<GITInterfaceManagerDelegate, GITClientDelegate>

@property (nonatomic, strong) GITInterfaceManager *interfaceManager;
@property (nonatomic, strong) NSDataDetector *emailDetector;
@property (nonatomic, strong) NSDictionary *userInfo;

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

- (void)setPendingUserInfo:(NSDictionary *)userInfo
{
    self.userInfo = userInfo;
}

- (void)completeSignUpWithPetImage:(UIImage *)image completion:(void (^)(NSError *))completion
{
    // TODO: image storage
    // TODO: verification
    BLOCK_SELF_REF_OUTSIDE();
    [[CPAppEngineCommunicationManager sharedInstance] updatePetProfileWithInfo:self.userInfo completion:^(NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (error) {
            [[self getRootNavController] displayErrorAlertWithTitle:NSLocalizedString(@"Error", nil) andMessage:error.localizedDescription];
        } else {
            [self presentUIForLoginResult:CPLoginResult_UserWithoutDevice];
        }
    }];
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
        [[self getRootNavController] displayErrorAlertWithTitle:NSLocalizedString(@"Error", nil) andMessage:error.localizedDescription];
    } else {
        BLOCK_SELF_REF_OUTSIDE();
        [[CPAppEngineCommunicationManager sharedInstance] loginWithUser:account completion:^(CPLoginResult result, NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (result == CPLoginResult_Failure) {
                // TODO: nicer error handling
                [[self getRootNavController] displayErrorAlertWithTitle:NSLocalizedString(@"Error", nil) andMessage:error.localizedDescription];
            } else {
                [self presentUIForLoginResult:result];
            }
        }];
    }
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
            [[self getRootNavController] pushViewController:vc animated:YES];
            break;
        }
        case CPLoginResult_UserWithoutDevice:
        {
            [[CPParticleConnectionHelper sharedInstance] presentSetupControllerOnController:[self getRootNavController]];
            break;
        }
        case CPLoginResult_UserWithSetupCompleted:
        {
            // Swap our root controller for the main screen
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainScreen"];
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            [window setRootViewController:vc];
            [window makeKeyAndVisible];
            
            CATransition *animation = [CATransition animation];
            [animation setDuration:.3f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [animation setType:kCATransitionFade];
            [window.layer addAnimation:animation forKey:@"crossFade"];
            break;
        }
    }
}

- (UINavigationController*)getRootNavController
{
    // TODO: Need to get the actual top level controller navController = visibleViewController, viewController = probably presentedViewController
    // TODO: handle when our root is not a nav controller
    return (UINavigationController*)[[[UIApplication sharedApplication].delegate window] rootViewController];
}

@end
