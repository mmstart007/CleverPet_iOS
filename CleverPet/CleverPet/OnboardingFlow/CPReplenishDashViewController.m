//
//  CPReplenishDashViewController.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPReplenishDashViewController.h"
#import "CPReplenishDashUtil.h"

@interface CPReplenishDashViewController () <AIAuthenticationDelegate>


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *estimatedReorderLabel;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *explainScrollView;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UILabel *explainLabel;


@property (weak, nonatomic) IBOutlet CPLoadingView *loadingView;


@end

@implementation CPReplenishDashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AIMobileLib getProfile:self];
    [self getRegistrationDetail];
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
    NSString *replenish_threshold   = [[data objectForKey:@"replenish_threshold"]stringValue];
    
    subscribed = 1; order_inprogress = 0;
    
    if (subscribed == 0) {
        
        _titleLabel.text = @"Reorder\nis OFF";
        _titleLabel.textColor = [UIColor grayColor];
        _bottomLabel.text = @"To resume, please\nset auto reorder to ON in\nAmazon's configuration.";
        
    } else {
        _bottomLabel.text = @"Once an order is placed, you\nmay cancel it via email\ninstructions from Amazon.";
        
        if (order_inprogress == 1) {
            
            _titleLabel.text = @"Order\nPlaced";
            _explainLabel.text = @"Explain      >";
            _detailLabel.text = @"Amazon is processing your\norder. The Hub will tally how\nmuch your dog eats. The next\nbag will arrive after your dog has\nconsumed most of the food from\nthis order.";
            
        } else {
            
            _titleLabel.text = @"Jan 23";
            _estimatedReorderLabel.text = @"Estimated reorder date";
            _explainLabel.text = @"Explain      >";
            NSString *str = [NSString stringWithFormat:@"A bag of food will be ordered\noafter the Hub provides food\nanother %@ times. The\nreorder date is based on your\ndog eating %@ times per day.", kibbles, replenish_threshold];
            _detailLabel.text = str;

        }
    }
}

#pragma mark - IBActions

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

- (IBAction)signoutButtonTapped:(id)sender {
    [AIMobileLib clearAuthorizationState:self];
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
//        self.accountIdLabel.text = [NSString stringWithFormat:@"You logged in as\n%@", apiResult.result[@"user_id"]];
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
