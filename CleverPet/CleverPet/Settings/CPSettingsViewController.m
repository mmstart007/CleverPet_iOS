//
//  CPSettingsViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSettingsViewController.h"
#import <Intercom/Intercom.h>
#import "CPAppEngineCommunicationManager.h"
#import "CPUserManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "CPHubSettingsViewController.h"

NSUInteger const kDeviceSection = 0;
NSUInteger const kHelpSection = 1;
NSUInteger const kAccountSection = 2;

NSUInteger const kHelpSectionChatWithUsRow = 0;
NSUInteger const kDeviceSectionHubSettingsRow = 0;

NSInteger const kLastSeenThreshhold = 120;

@interface CPSettingsBasicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@interface CPSettingsHubStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *indicatorDot;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (void)updateWithHubConnection:(HubConnectionState)connectionState;

@end

@interface CPSettingsViewController ()

@property (weak, nonatomic) IBOutlet CPSettingsHubStatusCell *hubCell;
@property (weak, nonatomic) UIBarButtonItem *pseudoBackButton;
@property (nonatomic, assign) BOOL checkingHubStatus;
@property (nonatomic, assign) HubConnectionState connectionState;

@end

@implementation CPSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.separatorColor = [UIColor appBackgroundColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // TODO: button image
    [button setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barButton;
    self.pseudoBackButton = barButton;
    self.connectionState = HubConnectionState_Unknown;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self updateHubStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setConnectionState:(HubConnectionState)connectionState
{
    _connectionState = connectionState;
    [self.hubCell updateWithHubConnection:_connectionState];
}

- (void)updateHubStatus
{
    if(!self.checkingHubStatus) {
        // Check if we're offline
        if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
            self.connectionState = HubConnectionState_Offline;
        } else {
            self.checkingHubStatus = YES;
            BLOCK_SELF_REF_OUTSIDE();
            [[CPAppEngineCommunicationManager sharedInstance] checkDeviceLastSeen:[[CPUserManager sharedInstance] getCurrentUser].device.deviceId completion:^(NSInteger delta, NSError *error) {
                BLOCK_SELF_REF_INSIDE();
                self.checkingHubStatus = NO;
                if (error || delta > kLastSeenThreshhold) {
                    self.connectionState = HubConnectionState_Disconnected;
                } else {
                    self.connectionState = HubConnectionState_Connected;
                }
            }];
        }
    }
}

#pragma mark - IBActions
- (void)menuButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO: check hub state
    if (section == kHelpSection && YES) {
        return 2;
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
    } else if (indexPath.section == kDeviceSection && indexPath.row == kDeviceSectionHubSettingsRow) {
        if (self.connectionState != HubConnectionState_Unknown) {
            [self performSegueWithIdentifier:@"hubSettings" sender:nil];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CPHubSettingsViewController class]]) {
        CPHubSettingsViewController *vc = segue.destinationViewController;
        vc.connectionState = self.connectionState;
    }
}

@end

#pragma mark - Basic Cell

@implementation CPSettingsBasicCell

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

- (void)updateWithHubConnection:(HubConnectionState)connectionState;
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
            self.statusLabel.text = NSLocalizedString(@"On", @"Hub status when the hub is reachable");
            break;
        }
        case HubConnectionState_Disconnected:
        {
            self.indicatorDot.backgroundColor = [UIColor appHubOfflineColor];
            self.statusLabel.text = NSLocalizedString(@"Disconnected", @"Hub status when the hub is not reachable");
            break;
        }
        case HubConnectionState_Offline:
        {
            self.indicatorDot.backgroundColor = [UIColor appHubOfflineColor];
            self.statusLabel.text = NSLocalizedString(@"No Data", @"Hub status when phone is offline");
            break;
        }
    }
    self.accessoryView.hidden = connectionState == HubConnectionState_Unknown;
}

@end
