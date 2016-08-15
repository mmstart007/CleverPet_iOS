//
//  CPLwaSigninViewController.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPLwaSigninViewController.h"
#import "UIView+CPShadowEffect.h"
#import "CPLabelUtils.h"
#import "CPFirebaseManager.h"
#import "OJFSegmentedProgressView.h"
#import "CPReplenishDashUtil.h"
#import "CPAmazonAPI.h"
#import "CPUserManager.h"
#import "CPUser.h"

@interface CPLwaSigninViewController () <AIAuthenticationDelegate>
{
    CPAmazonAPI *requestManager;
}

@property (weak, nonatomic) IBOutlet CPLoadingView *loadingView;
@property (strong, nonatomic) IBOutlet UIView *helpView;
@property (strong, nonatomic) IBOutlet UIView *cornerRadiusView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderdedLabel;
@property (strong, nonatomic) IBOutlet UILabel *reorderingLabel;
@property (strong, nonatomic) IBOutlet UILabel *helpTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;
@property (strong, nonatomic) IBOutlet UILabel *help1Label;
@property (strong, nonatomic) IBOutlet UIButton *gotButton;
@property (strong, nonatomic) IBOutlet UIButton *learnMoreButton;
@property (strong, nonatomic) IBOutlet UIButton *signButton;

- (IBAction)signinButtonTapped:(id)sender;
- (IBAction)learnMoreButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;

@end

@implementation CPLwaSigninViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:35 italic:NO],
                              [UIColor colorWithRed:44.0/255.0 green:175.0/255.0 blue:193.0/255.0 alpha:1.0],
                              @[self.titleLabel, self.helpTitleLabel]);
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:29 italic:NO],
                              [UIColor appTitleTextColor],
                              @[self.helpLabel, self.help1Label, self.orderdedLabel, self.reorderingLabel]);
    self.signButton.titleLabel.font = [UIFont cpLightFontWithSize:19 italic:NO];
    self.gotButton.titleLabel.font = [UIFont cpLightFontWithSize:19 italic:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
    self.loadingView.hidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.cornerRadiusView.layer.cornerRadius = 25.0f;
    self.cornerRadiusView.clipsToBounds = YES;
}

#pragma mark - IBActions
- (IBAction)signinButtonTapped:(id)sender {
    [AIMobileLib authorizeUserForScopes:[CPReplenishDashUtil appRequestScopes] delegate:self options:[CPReplenishDashUtil appRequestScopeOptions]];
}

- (IBAction)learnMoreButtonTapped:(id)sender {
    _helpView.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
}

- (IBAction)backButtonTapped:(id)sender {
    _helpView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Amazon Authentication Delegate
- (void)requestDidSucceed:(APIResult *)apiResult
{
    NSString *authCode = apiResult.result;

//    NSLog(@"Auth Code -> %@ \n ClientID -> %@ \n RedirctURI -> %@", apiResult.result, [AIMobileLib getClientId], [AIMobileLib getRedirectUri]);
    
    self.loadingView.hidden = NO;

    [[CPAmazonAPI manager] sendAuthCode : authCode
                             grant_type : @"authorization_code"
                               clientId : [AIMobileLib getClientId]
                           redirect_uri : [AIMobileLib getRedirectUri]
                          code_verifier : @"this_is_a_large_unique_string_or_hash_for_using_USER_ID_and_DEVICE_ID"
                                success : ^(NSDictionary *result) {
                                    
                                    NSString *f_refreshToken = [result objectForKey:@"refresh_token"];
                                    NSString *access_token = [result objectForKey:@"access_token"];

                                    [USERDEFAULT setObject:f_refreshToken forKey:REFRESH_TOKEN];
                                    [USERDEFAULT setObject:access_token forKey:ACCESS_TOKEN];

                                    [[CPAmazonAPI manager] sendRefreshToken:f_refreshToken
                                                                 grant_type:@"refresh_token"
                                                                  client_id:[AIMobileLib getClientId]
                                                                    success:^(NSDictionary *result) {
                                     
                                                                        CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
                                                                        NSString *currentUserDeviceID = currentUser.device.deviceId;  // Current User Device ID
                                                                        NSString *currentUserAuthToken = [USERDEFAULT objectForKey:CPUSER_AUTH_TOKEN];  // Current User AuthToken
                                                                        NSLog(@"Refresh Token ------- : %@ \n Current User DeviceID ------- %@ \n Current User Auth Token ----- %@", f_refreshToken, currentUserDeviceID, currentUserAuthToken); //[USERDEFAULT stringForKey:REFRESH_TOKEN]);
                                                                        
                                                                        [[CPAmazonAPI manager] setRefreshTokenInCP:f_refreshToken
                                                                                                         device_id:currentUserDeviceID
                                                                                                 cpuser_auth_token:currentUserAuthToken
                                                                                                           success:^(NSDictionary *result) {
                                                                                                               
                                                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                   self.loadingView.hidden = YES;
                                                                                                                   NSLog(@"Set Refresh Token Success!!!");
                                                                                                               });
                                                                                                               
                                                                                                           } failure:^(NSError *error) {
                                                                                                               self.loadingView.hidden = YES;
                                                                                                               NSLog(@"Set Refresh token failed !");
                                                                                                           }];
                                     } failure:^(NSError *error) {
                                         NSLog(@"failed getting Refresh token!");
                                     }];

                                } failure : ^(NSError *error) {
                                    NSLog(@"failed getting First Refresh token!");
                                }];

/*    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(loginWithAmazonDidSuccess)])
    {
        [self.delegate loginWithAmazonDidSuccess];
    }
 */
}

- (void)requestDidFail:(APIError *)errorResponse
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:[NSString stringWithFormat:@"User authorization failed with message: %@", errorResponse.error.message]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
