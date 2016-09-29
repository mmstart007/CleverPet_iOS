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
#import "CPOnboardingNavigationController.h"

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
@property (strong, nonatomic) IBOutlet UIView *configureView;

@property (strong, nonatomic) NSString *access_token;


@end

@implementation CPReplenishDashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AIMobileLib getProfile:self];
    
    ApplyFontAndColorToLabels([UIFont cpBoldFontWithSize:35 italic:NO],
                              [UIColor appTitleTextColor],
                              @[self.titleLabel]);
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:29 italic:NO],
                              [UIColor appTitleTextColor],
                              @[self.explainLabel, self.detailLabel]);
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:29 italic:NO],
                              [UIColor appSubCopyTextColor],
                              @[self.estimatedReorderLabel, self.configLabel]);
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:29 italic:NO],
                              [UIColor appTitleTextColor],
                              @[self.bottomLabel]);

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkingAmazonLoginStatus];
    [self getRegistrationDetail];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    NSInteger kibbles               = [[data objectForKey:@"kibbles"]integerValue];
    NSInteger kibbles_per_day       = [[data objectForKey:@"kibbles_per_day"]integerValue];
    NSString *dateStr               = [data objectForKey:@"expectedReplenishmentDate"];
    
    NSDateFormatter *dateFormat  = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDate *changeDate=[dateFormat dateFromString:dateStr];
    NSString *str=[dateFormat stringFromDate:changeDate];
    
    //getting your local time
    NSTimeZone *tz=[NSTimeZone localTimeZone];
    //setting yourlocal time
    [dateFormat setTimeZone:tz];
    NSDate *date = [dateFormat dateFromString:str];
    //Setting your desired format
    [dateFormat setDateFormat:@"MMM dd"];
    NSString *newDate=[dateFormat stringFromDate:date];
    
//    subscribed = 1; order_inprogress =1;
    
    if (subscribed == 0) {
        
        _titleLabel.text = @"Reorder\nis OFF";
        _titleLabel.textColor = [UIColor grayColor];
        _bottomLabel.text = @"To resume, please\nset auto reorder to ON in\nAmazon's configuration.";
        
    } else {
        _explainLabel.text = @"Explain      >";
        _bottomLabel.text = @"Once an order is placed, you\nhave one day to cancel via the\nemail from Amazon.";
        
        if (order_inprogress == 1) {
            
            _titleLabel.text = @"Order\nPlaced";
            _detailLabel.numberOfLines = 7;
            NSString *redText = @"CleverPet counts how\nmuch your dog eats from the\nHub. Another bag will be\n reordered after your dog\nconsumes most of the kibble in\nthis order.";
            NSString *str = [NSString stringWithFormat:@"Amazon is processing your\norder. %@", redText];

            // Define general attributes for the entire text
            NSDictionary *attribs = @{
                                      NSForegroundColorAttributeName: self.detailLabel.textColor,
                                      NSFontAttributeName: self.detailLabel.font
                                      };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:str
                                                   attributes:attribs];
            
            // Red text attributes
            NSRange redTextRange = [str rangeOfString:redText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor appTitleTextColor]}
                                    range:redTextRange];
            
            _detailLabel.attributedText = attributedText;
            
        } else {
            
            if (newDate == nil || newDate.length == 0 || [newDate isEqualToString:@""] || [newDate isKindOfClass:[NSNull class]] || [newDate isEqualToString:@"(null)"])
                _titleLabel.text = @"Unknown";
            else
                _titleLabel.text = newDate;
            
            _estimatedReorderLabel.text = @"Estimated reorder date";
            _detailLabel.numberOfLines = 5;
            NSString *str = [NSString stringWithFormat:@"A bag of food will be reordered\nafter the Hub provides food\nanother %ld times. The\nreorder date is based on your\ndog eating %ld times per day.", (long)kibbles, (long)kibbles_per_day];
            
            // Define general attributes for the entire text
            NSDictionary *attribs = @{
                                      NSForegroundColorAttributeName: self.detailLabel.textColor,
                                      NSFontAttributeName: self.detailLabel.font
                                      };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:str
                                                   attributes:attribs];
            
            
            // Kibble text attributes
            UIColor *kibbleTextColor = [UIColor appTitleTextColor];
            UIFont *kibbleTextBoldFont = [UIFont boldSystemFontOfSize:self.detailLabel.font.pointSize];
            NSRange kibbleTextRange = [str rangeOfString:[NSString stringWithFormat: @"%ld", (long)kibbles]];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
            [attributedText setAttributes:@{NSForegroundColorAttributeName:kibbleTextColor,
                                            NSFontAttributeName:kibbleTextBoldFont}
                                    range:kibbleTextRange];

            // Per day text attributes
            UIColor *perDayTextColor = [UIColor appTitleTextColor];
            UIFont *perDayTextBoldFont = [UIFont boldSystemFontOfSize:self.detailLabel.font.pointSize];
            NSRange perDayTextRange = [str rangeOfString:[NSString stringWithFormat:@"%ld",  (long)kibbles_per_day]];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
            [attributedText setAttributes:@{NSForegroundColorAttributeName:perDayTextColor,
                                            NSFontAttributeName:perDayTextBoldFont}
                                    range:perDayTextRange];
            
            _detailLabel.attributedText = attributedText;
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
    
    NSString *replenishmentUrl = [NSString stringWithFormat:@"https://drs-web.amazon.com/settings?access_token=%@&exitUri=https://amazon.com", self.access_token];
    NSURL *url = [NSURL URLWithString:[replenishmentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"Replenishment URL ---- %@", url);
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void)checkingAmazonLoginStatus {
    self.loadingView.hidden = NO;
    
    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
    NSString *currentUserDeviceID = currentUser.device.deviceId;  // Current User Device ID
    NSString *cpuser_auth_token = [USERDEFAULT objectForKey:CPUSER_AUTH_TOKEN];  // Current User AuthToken
    
    [[CPAmazonAPI manager] checkAmazonLogin : currentUserDeviceID
                          cpuser_auth_token : (NSString *)cpuser_auth_token
                                    success : ^(NSDictionary *result, NSInteger responseCode) {
                                        
                                        NSLog(@"Amazon Login check ==== %ld", (long)responseCode);
                                        
                                        self.loadingView.hidden = YES;
                                        if (responseCode == 200) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                self.access_token = [result objectForKey:@"access_token"];
//                                                self.access_token = @"Atzr|IwEBIH1HVAHxd7w78Nqqi7qwchAsdVRpotglUWQs6_51lIF29wv9tcmwOzmGxgzceCOVNtWw3i3dyFS3Eyb-N70k2ZzFCnJYPbQO4Juqa1gda5XWjAlLBLf2x65NJL1VRRLaw-1pemzvkyzssugdMGQ1-byWAXXQTA-ZJcootJpAw8biXAwoB9kyJVgGs7Z2HMrmkLfCpMTuACqhEgOkWSrnYm-fXCZJ5EThOYT9E2kQy7L-ehOQ7qQoq5ipklmzclR0EPHvIMTGhujK5c2G0cC7z1L446P7NhsEp8oG5wrLKnKNIL6UrBKIX0HfCb-BLY765HGMAuUyCpUhNmkoN1zUg5izMpw0CTp3MVsVvlNBPYsFEzyR2-vSKsm8XHJezHPOp-1WsuDo4805Gx84E_wp2uKoriTC5CO1nA0yR4VOb-WXqQ";
                                                if (self.access_token == nil || self.access_token.length == 0 || [self.access_token isEqualToString:@""] || [self.access_token isKindOfClass:[NSNull class]] || [self.access_token isEqualToString:@"(null)"]) {
                                                    self.configureView.hidden = true;
                                                } else {
                                                    self.configureView.hidden = false;
                                                }
                                            });
                                        } else {
                                            CPOnboardingNavigationController *nav = [[UIStoryboard storyboardWithName:@"OnboardingFlow" bundle:nil] instantiateInitialViewController];
                                            
                                            [self.navigationController presentViewController:nav animated:YES completion:^{
                                                
                                            }];
                                        }
                                        
                                    } failure : ^(NSError *error) {
                                        
                                    }];
}

- (IBAction)explainButtonTapped:(id)sender {
    
    [_explainScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
}

- (IBAction)detailButtonTapped:(id)sender {

    [_explainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
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
