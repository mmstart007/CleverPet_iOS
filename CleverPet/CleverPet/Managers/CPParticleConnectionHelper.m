//
//  CPParticleConnectionHelper.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-22.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPParticleConnectionHelper.h"
#import <SparkSetup/SparkSetup.h>
#import <Spark-SDK/SparkCloud.h>

NSString * const kParticleOrganizationName = @"particle_organization_name";
NSString * const kParticleOrganizationSlug = @"particle_organization_slug";
NSString * const kParticleProductName = @"particle_product_name";
NSString * const kParticleProductSlug = @"particle_product_slug";

@interface CPParticleConnectionHelper()<SparkSetupMainControllerDelegate>

@property (nonatomic, strong) NSString *organizationName;
@property (nonatomic, strong) NSString *organizationSlug;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productSlug;
@property (nonatomic, weak) id<CPParticleConnectionDelegate> delegate;

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
    customization.organization = YES;
    
    customization.pageBackgroundColor = [UIColor appBackgroundColor];
    customization.normalTextColor = [UIColor appTitleTextColor];
    customization.linkTextColor = [UIColor appTealColor];
    customization.elementBackgroundColor = [UIColor appLightTealColor];
    customization.elementTextColor = [UIColor appTealColor];
    customization.normalTextFontName = @"Raleway Light";
    customization.boldTextFontName = @"Raleway Bold";
    customization.headerTextFontName = @"Raleway Light";
    customization.disableLogOutOption = YES;
//    customization.networkNamePrefix = @"Clever";
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
    // Massage the data we're getting back to avoid further modifying the pod
    NSMutableDictionary *newTokenInfo = [NSMutableDictionary dictionary];
    newTokenInfo[@"access_token"] = tokenInfo[@"access_token"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSS";
    NSDate *expiryDate = [dateFormatter dateFromString:tokenInfo[@"expires"]];
    NSTimeInterval timeUntilExpiry = [expiryDate timeIntervalSinceNow];
    newTokenInfo[@"expires_in"] = @(timeUntilExpiry);
    
    newTokenInfo[@"token_type"] = @"bearer";
    // TODO: Spark ignores the refresh_token, but pass it along anyways
    newTokenInfo[@"refresh_token"] = tokenInfo[@"refresh_token"];
    
    BOOL accessTokenResult = [[SparkCloud sharedInstance] injectSessionAccessToken:tokenInfo[@"access_token"] withExpiryDate:expiryDate andRefreshToken:tokenInfo[@"refresh_token"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(accessTokenResult ? nil : [NSError errorWithDomain:@"CPParticleConnectionHelper" code:-1 userInfo:nil]);
    });
}

- (void)presentSetupControllerOnController:(UINavigationController *)controller withDelegate:(id<CPParticleConnectionDelegate>)delegate
{
    self.delegate = delegate;
    [self setupCustomAppearance];
    SparkSetupMainController *setupController = [[SparkSetupMainController alloc] init];
    setupController.delegate = self;
    [controller presentViewController:setupController animated:YES completion:nil];
}

- (void)sparkSetupViewController:(SparkSetupMainController *)controller didFinishWithResult:(SparkSetupMainControllerResult)result device:(SparkDevice *)device
{
    if (result == SparkSetupMainControllerResultSuccess) {
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        [self.delegate deviceClaimed:@{kParticleIdKey:device.id, kNameKey:device.name, kTimeZoneKey:(timeZone ? @([timeZone secondsFromGMT]) : @(0))}];
    } else {
        if (result == SparkSetupMainControllerResultUserCancel) {
            [self.delegate deviceClaimCanceled];
        } else {
            [self.delegate deviceClaimFailed];
        }
    }
}

@end
