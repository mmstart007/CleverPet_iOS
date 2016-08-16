//
//  CPReplenishDashViewController.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPReplenishDashViewController.h"
#import "CPReplenishDashUtil.h"
#import "UIView+CPShadowEffect.h"
#import "CPLabelUtils.h"
#import "CPFirebaseManager.h"
#import "OJFSegmentedProgressView.h"

@interface CPReplenishDashViewController () <AIAuthenticationDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *explainScrollView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *estimatedReorderLabel;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UILabel *explainLabel;
@property (strong, nonatomic) IBOutlet UILabel *configLabel;
@property (weak, nonatomic) UIBarButtonItem *pseudoBackButton;


@property (weak, nonatomic) IBOutlet CPLoadingView *loadingView;


@end

@implementation CPReplenishDashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AIMobileLib getProfile:self];
    [self getRegistrationDetail];
    
    ApplyFontAndColorToLabels([UIFont cpBoldFontWithSize:35 italic:NO],
                              [UIColor appTitleTextColor],
                              @[self.titleLabel]);
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:29 italic:NO],
                              [UIColor appTitleTextColor],
                              @[self.explainLabel, self.detailLabel]);
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:29 italic:NO],
                              [UIColor appSubCopyTextColor],
                              @[self.estimatedReorderLabel, self.bottomLabel, self.configLabel]);

//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:NSLocalizedString(@"Settings", nil) forState:UIControlStateNormal];
//    [button.titleLabel setFont:[UIFont cpLightFontWithSize:12 italic:NO]];
//    [button setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
//    [button setTintColor:[UIColor appTealColor]];
//    [button sizeToFit];
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
//    [button addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = barButton;
//    self.pseudoBackButton = barButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
}

#pragma mark - Registration Detail
- (void)getRegistrationDetail
{
    self.loadingView.hidden = NO;
    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
    NSString *currentUserDeviceID = currentUser.device.deviceId;  // Current User Device ID
    NSString *currentUserAuthToken = [USERDEFAULT objectForKey:CPUSER_AUTH_TOKEN];  // Current User AuthToken
    NSLog(@"Current User DeviceID ------- %@ \n Current User Auth Token ----- %@", currentUserDeviceID, currentUserAuthToken);
    
        [[CPAmazonAPI manager] setDeviceIdInCP:currentUserDeviceID
                             cpuser_auth_token:currentUserAuthToken
                                       success:^(NSDictionary *result) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                self.loadingView.hidden = YES;
                                                
                                                // Display all Information
                                                [self displayInfo:result];
                                           });
                                       } failure:^(NSError *error) {
                                           self.loadingView.hidden = YES;
                                           NSLog(@"Get Registration Data failed ! -----");
                                           
                                       }];
    
}

- (void)displayInfo:(NSDictionary *)data {
    
    NSLog(@"Get Registration Data Success ! ----- %@", data);
    
    NSInteger subscribed            = [[data objectForKey:@"subscribed"]integerValue];
    NSInteger order_inprogress      = [[data objectForKey:@"order_inprogress"]integerValue];
    NSString *kibbles               = [[data objectForKey:@"kibbles"]stringValue];
//    NSString *replenish_threshold   = [[data objectForKey:@"replenish_threshold"]stringValue];
    
    subscribed = 1; order_inprogress = 1;
    
    if (subscribed == 0) {
        
        _titleLabel.text = @"Reorder\nis OFF";
        _titleLabel.textColor = [UIColor grayColor];
        _bottomLabel.text = @"To resume, please\nset auto reorder to ON in\nAmazon's configuration.";
        
    } else {
        _explainLabel.text = @"Explain      >";
        _bottomLabel.text = @"Once an order is placed, you\nmay cancel it via email\ninstructions from Amazon.";
        
        if (order_inprogress == 1) {
            
            _titleLabel.text = @"Order\nPlaced";
            _detailLabel.text = @"Amazon is processing your order. The Hub will tally how much your dog eats. The next bag will arrive after your dog has consumed most of the food from this order.";
            
        } else {
            
            _titleLabel.text = @"Jan 23";
            _estimatedReorderLabel.text = @"Estimated reorder date";
            NSString *str = [NSString stringWithFormat:@"A bag of food will be ordered after the Hub provides food another %@ times. The reorder date is based on today's estimate that your dog will eat 60 times per day.", kibbles];
            _detailLabel.text = str;
        }
    }
}

#pragma mark - IBActions
- (IBAction)menuButtonTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)configureButtonTapped:(id)sender {
    
    self.loadingView.hidden = NO;
    NSString *f_refreshToken = [USERDEFAULT objectForKey:REFRESH_TOKEN];
    [[CPAmazonAPI manager] sendRefreshToken:f_refreshToken
                                 grant_type:@"refresh_token"
                                  client_id:[AIMobileLib getClientId]
                                    success:^(NSDictionary *result) {
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            self.loadingView.hidden = YES;
                                            
                                            NSString *access_token = [result objectForKey:@"access_token"];
                                            NSString *replenishmentUrl = [NSString stringWithFormat:@"https://drs-web.amazon.com/settings?access_token=%@&exitUri=https://amazon.com", access_token];
                                            NSURL *url = [NSURL URLWithString:[replenishmentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                            NSLog(@"Replenishment URL ---- %@", url);
                                            
                                            [[UIApplication sharedApplication] openURL:url];
                                        });
                                    } failure:^(NSError *error) {
                                        NSLog(@"failed getting Refresh token!");
                                    }];
}

- (IBAction)explainButtonTapped:(id)sender {
    
    [_explainScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
    NSLog(@"%@",NSStringFromCGPoint(_explainScrollView.contentOffset));
}

- (IBAction)detailButtonTapped:(id)sender {

    [_explainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    NSLog(@"%@",NSStringFromCGPoint(_explainScrollView.contentOffset));
}

#pragma mark - Amazon Authentication Delegate
- (void)requestDidSucceed:(APIResult *)apiResult
{
    if (apiResult.api == kAPIClearAuthorizationState) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(replenishDashDidSignout)])
        {
            [self.delegate replenishDashDidSignout];
        }
    } else if (apiResult.api == kAPIGetProfile) {
        NSLog(@"%@", apiResult.result);
    }
}

- (void)requestDidFail:(APIError *)errorResponse
{
    if (errorResponse.api == kAPIClearAuthorizationState) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:[NSString stringWithFormat:@"User Logout failed with message: %@", errorResponse.error.message]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else if (errorResponse.api == kAPIGetProfile) {
        if(errorResponse.error.code == kAIApplicationNotAuthorized) {
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(replenishDashUserNotAuthorized)])
            {
                [self.delegate replenishDashUserNotAuthorized];
            }
        }
        else {
//            self.accountIdLabel.text = [NSString stringWithFormat:@"Error occurred with message: %@", errorResponse.error.message];
        }
    }
}

- (void)setReplenishThreshold:(NSString *)replenishThreshold
{
    
    self.loadingView.hidden = NO;
    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
    NSString *currentUserDeviceID = currentUser.device.deviceId;  // Current User Device ID
    NSString *currentUserAuthToken = [USERDEFAULT objectForKey:CPUSER_AUTH_TOKEN];  // Current User AuthToken
    NSLog(@"Current User DeviceID ------- %@ \n Current User Auth Token ----- %@", currentUserDeviceID, currentUserAuthToken);
    
    [[CPAmazonAPI manager] setReplenishThresholdInCP : replenishThreshold
                                           device_id : currentUserDeviceID
                                   cpuser_auth_token : currentUserAuthToken
                                             success : ^(NSDictionary *result) {
                                                 self.loadingView.hidden = YES;
                                                 NSLog(@"Get Registration Data Success ! ----- %@", result);
                                                 
                                             } failure : ^(NSError *error) {
                                                 self.loadingView.hidden = YES;
                                                 NSLog(@"Get Registration Data failed ! -----");
                                             }];
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
