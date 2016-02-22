//
//  CPParticleConnectionHelper.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-22.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPParticleConnectionHelper.h"
#import <SparkSetup/SparkSetup.h>

@interface CPParticleConnectionHelper()<SparkSetupMainControllerDelegate>

@property (nonatomic, strong) NSString *authToken;

@end

@implementation CPParticleConnectionHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPParticleConnectionHelper *s_Instance;
    dispatch_once(&onceToken, ^{
        s_Instance = [[CPParticleConnectionHelper alloc] init];
        [s_Instance setupCustomAppearance];
    });
    return s_Instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // TODO: remove setup particle once the server is configured and vending oauth
        [self setupParticle];
        [self setupCustomAppearance];
    }
    return self;
}

- (void)setupParticle
{
    // TODO: Once the server is vending oauth, we don't need a client id or secret.
    // An auth token for the client will have to be returned as part of the sign up process(Possibly login, although if the server is handling all interactions with the device, we only need it for the setup/device claim process)
    [[SparkCloud sharedInstance] setOAuthClientId:@"particle"];
    [[SparkCloud sharedInstance] setOAuthClientSecret:@"particle"];
}

- (void)setupCustomAppearance
{
    SparkSetupCustomization *customization = [SparkSetupCustomization sharedInstance];
    customization.productName = @"CleverPet";
    customization.pageBackgroundColor = [UIColor appBackgroundColor];
    customization.normalTextColor = [UIColor appSignUpHeaderTextColor];
    customization.linkTextColor = [UIColor appTealColor];
    customization.elementBackgroundColor = [UIColor appLightTealColor];
    customization.elementTextColor = [UIColor appTealColor];
    customization.normalTextFontName = @"Omnes-Light";
    customization.boldTextFontName = @"Omnes-Bold";
    customization.headerTextFontName = @"Omnes-Light";
}

- (void)setAuthToken:(NSString*)authToken
{
    // TODO: will need to modify SparkCloud to accept
    // Set access token on [SparkCloud sharedInstance] to simulate user login. We probably don't need to worry about token time outs
}

- (void)presentSetupControllerOnController:(UIViewController *)controller
{
    SparkSetupMainController *setupController = [[SparkSetupMainController alloc] init];
    [controller presentViewController:setupController animated:YES completion:nil];
}

- (void)sparkSetupViewController:(SparkSetupMainController *)controller didFinishWithResult:(SparkSetupMainControllerResult)result device:(SparkDevice *)device
{
    
}

@end
