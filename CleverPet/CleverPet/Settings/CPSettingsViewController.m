//
//  CPSettingsViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSettingsViewController.h"
#import <Intercom/Intercom.h>
#import "CPUserManager.h"
#import "CPHubSettingsViewController.h"
#import "CPHubPlaceholderViewController.h"
#import "CPParticleConnectionHelper.h"
#import "CPHubStatusManager.h"
#import "CPAppEngineCommunicationManager.h"
#import "CPReplenishDashUtil.h"
#import "CPReplenishDashViewController.h"
#import "CPLwaSigninViewController.h"

NSUInteger const kDeviceSection = 0;
NSUInteger const kHelpSection = 1;
NSUInteger const kAccountSection = 2;

NSUInteger const kHelpSectionChatWithUsRow = 0;
NSUInteger const kDeviceSectionHubSettingsRow = 0;
NSUInteger const kDeviceSectionHubSetupRow = 1;
NSUInteger const kDeviceSectionAutoOrderRow = 2;

@interface CPSettingsAutoOrderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@interface CPSettingsBasicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@interface CPSettingsHubStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *indicatorDot;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (void)updateWithHubConnection:(HubConnectionState)connectionState withTimestamp:(NSString*)updateTime;

@end

@interface CPSettingsViewController () <CPHubPlaceholderDelegate, CPParticleConnectionDelegate, AIAuthenticationDelegate, CPLoginWithAmazonDelegate, CPReplenishDashDelegate>

@property (weak, nonatomic) IBOutlet CPSettingsHubStatusCell *hubCell;
@property (weak, nonatomic) UIBarButtonItem *pseudoBackButton;
@property (nonatomic, assign) BOOL checkingHubStatus;
@property (nonatomic, assign) HubConnectionState connectionState;
@property (nonatomic, strong) CPHubPlaceholderViewController *hubPlaceholder;
@property (nonatomic, strong) CPHubStatusHandle updateHandle;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation CPSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.separatorColor = [UIColor appBackgroundColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont cpLightFontWithSize:12 italic:NO]];
    [button setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor appTealColor]];
    [button sizeToFit];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barButton;
    self.pseudoBackButton = barButton;
    self.connectionState = HubConnectionState_Unknown;
    
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.timeStyle = NSDateFormatterShortStyle;
    
    // Listen for hub status updates
    BLOCK_SELF_REF_OUTSIDE();
    self.updateHandle = [[CPHubStatusManager sharedInstance] registerForHubStatusUpdates:^(HubConnectionState status) {
        BLOCK_SELF_REF_INSIDE();
        self.connectionState = status;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[CPHubStatusManager sharedInstance] unregisterForHubStatusUpdates:self.updateHandle];
}

- (void)setConnectionState:(HubConnectionState)connectionState
{
    if (_connectionState != connectionState) {
        _connectionState = connectionState;
    }
    [self.hubCell updateWithHubConnection:_connectionState withTimestamp:[self.formatter stringFromDate:[NSDate date]]];
}

#pragma mark - IBActions
- (void)menuButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kHelpSection) {
        return 2;
    } else if (section == kDeviceSection) {
        return 3;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDeviceSection) {
        return 70.f;
    }
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title;
    switch (section) {
        case kDeviceSection:
        {
            title = NSLocalizedString(@"Device", @"Settings device section header");
            break;
        }
        case kHelpSection:
        {
            title = NSLocalizedString(@"Help", @"Settings help section header");
            break;
        }
        case kAccountSection:
        {
            title = NSLocalizedString(@"Account", @"Settings account section header");
            break;
        }
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50.f)];
    headerView.backgroundColor = [UIColor appBackgroundColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = title;
    titleLabel.font = [UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO];
    titleLabel.textColor = [UIColor appTitleTextColor];
    [headerView addSubview:titleLabel];
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(15.f, 0.f, titleLabel.bounds.size.width, headerView.bounds.size.height);
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Check hub status
    if (indexPath.section == kHelpSection && NO) {
        // Offset our index path to account for the hidden chat with us cell
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        return [super tableView:tableView cellForRowAtIndexPath:newIndexPath];
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kHelpSection && indexPath.row == kHelpSectionChatWithUsRow) {
        [Intercom presentConversationList];
    } else if (indexPath.section == kDeviceSection) {
        if (indexPath.row == kDeviceSectionHubSettingsRow && self.connectionState != HubConnectionState_Unknown) {
            [self performSegueWithIdentifier:@"hubSettings" sender:nil];
        } else if (indexPath.row == kDeviceSectionHubSetupRow) {
            CPHubPlaceholderViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"HubPlaceholder"];
            vc.message = NSLocalizedString(@"Press Continue to begin Hub setup.\n\nIf you connect to a new Hub, this will result in your current Hub being unlinked from your account.", @"Message displayed to user when performing hub setup from the settings");
            vc.delegate = self;
            vc.shouldConfirmCancellation = NO;
            self.hubPlaceholder = vc;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == kDeviceSectionAutoOrderRow) {

            NSString *refreshToken = [USERDEFAULT stringForKey:REFRESH_TOKEN];
            if (refreshToken.length > 0 || refreshToken != nil) {

                // Go to ReplenishmentDashboard Controller
                [self openReplenishmentDashboard];
                
/*                [[CPAmazonAPI manager] sendRefreshToken:refreshToken
                                             grant_type:@"refresh_token"
                                              client_id:[AIMobileLib getClientId]
                                                success:^(NSDictionary *result) {
                                                    
                                                    NSString *accessToken = [result objectForKey:@"access_token"];
                                                    NSString *f_refreshToken = [result objectForKey:@"refresh_token"];
                                                    [USERDEFAULT setObject:accessToken forKey:ACCESS_TOKEN];

//                                                    NSLog(@"Reply Refresh Token ------- : %@", result);

                                                    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
                                                    NSString *currentUserDeviceID = currentUser.device.deviceId;  // Current User Device ID
                                                    NSString *currentUserAuthToken = [USERDEFAULT objectForKey:CPUSER_AUTH_TOKEN];  // Current User AuthToken
                                                    NSLog(@"Refresh Token ------- : %@ \n Current User DeviceID ------- %@ \n Current User Auth Token ----- %@", f_refreshToken, currentUserDeviceID, currentUserAuthToken); //[USERDEFAULT stringForKey:REFRESH_TOKEN]);
                                                    
                                                    [[CPAmazonAPI manager] setRefreshTokenInCP:f_refreshToken
                                                                                     device_id:currentUserDeviceID
                                                                             cpuser_auth_token:currentUserAuthToken
                                                                                       success:^(NSDictionary *result) {
                                                                                           NSLog(@"Set Refresh Token Success!!!");
                                                                                           
                                                                                           // Go to ReplenishmentDashboard Controller
                                                                                           [self openReplenishmentDashboard];
                                                                                       } failure:^(NSError *error) {
                                                                                           NSLog(@"Set Refresh token failed !");
                                                                                       }];
                                                    
                                                } failure:^(NSError *error) {
                                                    NSLog(@"failed getting Refresh token!");
                                                }];
 */

            } else
                [self openLoginWithAmazon];
        }
    }
}

#pragma mark - CPHubPlaceholderDelegate methods
- (void)hubSetupCancelled
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hubSetupContinued
{
    [[CPParticleConnectionHelper sharedInstance] presentSetupControllerOnController:self.navigationController withDelegate:self];
}

#pragma mark - CPParticleConnectionDelegate methods
- (void)deviceClaimed:(NSDictionary *)deviceInfo
{
    BLOCK_SELF_REF_OUTSIDE();
    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
    [[CPAppEngineCommunicationManager sharedInstance] updateDevice:currentUser.device.deviceId particle:deviceInfo completion:^(NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (error) {
            // TODO: display error to user and relaunch device claim flow
            [self deviceClaimFailed];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)deviceClaimCanceled
{
    [self.hubPlaceholder displayMessage:NSLocalizedString(@"If you do not complete Hub WiFi Setup, the Hub won't adapt to your dog or offer your dog new challenges.\n\nYou also won't be able to see how your dog is doing through the CleverPet mobile app.", @"Message displayed to user when they cancel out of the particle device claim flow")];
}

- (void)deviceClaimFailed
{
    [self.hubPlaceholder displayMessage:NSLocalizedString(@"Uh oh! Your Hub didn't connect to WiFi. Is the WiFi signal where you put the Hub strong enough? Was the password entered correctly?\n\nLet's try connecting again. Make sure your phone is no longer connected to the Hub's network.\n\nUnplug the Hub from the wall, then plug back in. When the light on the Hub dome flashes blue, press Continue.", @"Message displayed to user when particle device claim fails")];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - Amazon Authentication Delegate
- (void)requestDidSucceed:(APIResult *)apiResult
{
    [self openReplenishmentDashboard];
}

- (void)requestDidFail:(APIError *)errorResponse
{
    if(errorResponse.error.code == kAIApplicationNotAuthorized) {
        [self openLoginWithAmazon];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:[NSString stringWithFormat:@"Error occurred with message: %@", errorResponse.error.message]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - LoginWithAmazon Delegate
- (void)loginWithAmazonDidSuccess
{
    [self.navigationController popToViewController:self animated:YES];
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC);
    dispatch_after(after, dispatch_get_main_queue(), ^{
        [self openReplenishmentDashboard];
    });
}

- (void)loginWithAmazonDidCancel
{
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - ReplenishDashboard Delegate
- (void)replenishDashUserNotAuthorized
{
    [self.navigationController popToViewController:self animated:YES];
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC);
    dispatch_after(after, dispatch_get_main_queue(), ^{
        [self openLoginWithAmazon];
    });
}

- (void)replenishDashDidSignout
{
    [self.navigationController popToViewController:self animated:YES];
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC);
    dispatch_after(after, dispatch_get_main_queue(), ^{
        [self openLoginWithAmazon];
    });
}

#pragma mark - Helpers for onboarding flow
- (void)openReplenishmentDashboard
{
    CPReplenishDashViewController *vc = [[UIStoryboard storyboardWithName:@"OnboardingFlow" bundle:nil] instantiateViewControllerWithIdentifier:@"replenishdash"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openLoginWithAmazon
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CPLwaSigninViewController *vc = [[UIStoryboard storyboardWithName:@"OnboardingFlow" bundle:nil] instantiateViewControllerWithIdentifier:@"lwasignin"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

@end

#pragma mark - Auto-order Cell

@implementation CPSettingsAutoOrderCell

- (void)awakeFromNib
{
    self.titleLabel.font = [UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO];
    self.titleLabel.textColor = [UIColor appTitleTextColor];
    self.separator.backgroundColor = [UIColor appBackgroundColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    self.accessoryView = imageView;
}

- (void)setupWithTitle:(NSString*)title
{
    self.titleLabel.text = title;
}

@end

#pragma mark - Basic Cell

@implementation CPSettingsBasicCell

- (void)awakeFromNib
{
    self.titleLabel.font = [UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO];
    self.titleLabel.textColor = [UIColor appTitleTextColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    self.accessoryView = imageView;
}

- (void)setupWithTitle:(NSString*)title
{
    self.titleLabel.text = title;
}

@end

#pragma mark - Hub Status Cell

@implementation CPSettingsHubStatusCell

- (void)awakeFromNib
{
    self.indicatorDot.layer.cornerRadius = self.indicatorDot.bounds.size.width*.5f;
    self.titleLabel.font = [UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO];
    self.titleLabel.textColor = [UIColor appTitleTextColor];
    self.statusLabel.font = [UIFont cpLightFontWithSize:kTableCellSubTextSize italic:NO];
    self.statusLabel.textColor = [UIColor appTitleTextColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    self.accessoryView = imageView;
}

- (void)updateWithHubConnection:(HubConnectionState)connectionState withTimestamp:(NSString*)updateTime
{
    switch (connectionState) {
        case HubConnectionState_Unknown:
        {
            self.indicatorDot.backgroundColor = [UIColor appHubWaitingColor];
            self.statusLabel.text = NSLocalizedString(@"Waiting For Connection", @"Hub status while checking online state");
            break;
        }
        case HubConnectionState_Connected:
        {
            self.indicatorDot.backgroundColor = [UIColor appHubOnlineColor];
            self.statusLabel.text =[NSString stringWithFormat: NSLocalizedString(@"On. Last updated %@", @"Hub status when the hub is reachable"), updateTime];
            break;
        }
        case HubConnectionState_Disconnected:
        {
            self.indicatorDot.backgroundColor = [UIColor appHubOfflineColor];
            self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Disconnected. Last updated %@", @"Hub status when the hub is not reachable, %@ = last updated time"), updateTime];
            break;
        }
        case HubConnectionState_Offline:
        {
            self.indicatorDot.backgroundColor = [UIColor appHubOfflineColor];
            self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"No Data. Last updated %@", @"Hub status when phone is offline"), updateTime];;
            break;
        }
    }
    self.accessoryView.hidden = connectionState == HubConnectionState_Unknown;
}

@end
