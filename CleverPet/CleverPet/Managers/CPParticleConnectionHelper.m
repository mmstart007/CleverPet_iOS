//
//  CPParticleConnectionHelper.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-22.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPParticleConnectionHelper.h"
#import <SparkSetup/SparkSetup.h>

NSString const * kParticleOrganizationName = @"particle_organization_name";
NSString const * kParticleOrganizationSlug = @"particle_organization_slug";
NSString const * kParticleProductName = @"particle_product_name";
NSString const * kParticleProductSlug = @"particle_product_slug";

@interface CPParticleConnectionHelper()<SparkSetupMainControllerDelegate>

@property (nonatomic, strong) NSString *organizationName;
@property (nonatomic, strong) NSString *organizationSlug;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productSlug;

@end

@implementation CPParticleConnectionHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPParticleConnectionHelper *s_Instance;
    dispatch_once(&onceToken, ^{
        s_Instance = [[CPParticleConnectionHelper alloc] init];
    });
    return s_Instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // TODO: remove setup particle once the server is configured and vending oauth
        [self setupParticle];
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
    customization.productName = self.productName ? self.productName : @"CleverPet";
    customization.productSlug = self.productSlug;
    customization.organizationName = self.organizationName;
    customization.organizationSlug = self.organizationSlug;
    
    customization.pageBackgroundColor = [UIColor appBackgroundColor];
    customization.normalTextColor = [UIColor appSignUpHeaderTextColor];
    customization.linkTextColor = [UIColor appTealColor];
    customization.elementBackgroundColor = [UIColor appLightTealColor];
    customization.elementTextColor = [UIColor appTealColor];
    customization.normalTextFontName = @"Omnes-Light";
    customization.boldTextFontName = @"Omnes-Bold";
    customization.headerTextFontName = @"Omnes-Light";
}

- (void)applyConfig:(NSDictionary *)config
{
    self.productName = config[kParticleProductName];
    self.productSlug = config[kParticleProductSlug];
    self.organizationName = config[kParticleOrganizationName];
    self.organizationSlug = config[kParticleOrganizationSlug];
}

- (void)setAccessToken:(NSDictionary *)tokenInfo completion:(void (^)(NSError *))completion
{
    // Set access token on [SparkCloud sharedInstance] to simulate user login.
    [[SparkCloud sharedInstance] loginWithAccessToken:tokenInfo completion:completion];
}

- (void)presentSetupControllerOnController:(UIViewController *)controller
{
    [self setupCustomAppearance];
    SparkSetupMainController *setupController = [[SparkSetupMainController alloc] init];
    setupController.delegate = self;
    [controller presentViewController:setupController animated:YES completion:nil];
}

- (void)sparkSetupViewController:(SparkSetupMainController *)controller didFinishWithResult:(SparkSetupMainControllerResult)result device:(SparkDevice *)device
{
}

@end
