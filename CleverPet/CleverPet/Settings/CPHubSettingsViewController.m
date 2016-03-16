//
//  CPHubSettingsViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HubSetting) {HubSetting_On, HubSetting_Scheduled, HubSetting_Off};

#import "CPHubSettingsViewController.h"
#import "CPHubSettingsButton.h"
#import "NMRangeSlider.h"
#import "CPUserManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface CPHubSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;

// Header
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *headerLabel;

// Disconnected
@property (weak, nonatomic) IBOutlet UIView *disconnectedView;
@property (weak, nonatomic) IBOutlet UILabel *disconnectedHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *disconnectedBodyLabel;

// On
@property (weak, nonatomic) IBOutlet UIStackView *onView;
@property (weak, nonatomic) IBOutlet CPHubSettingsButton *onButton;
@property (weak, nonatomic) IBOutlet UILabel *onHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *onBodyLabel;

// Scheduled
@property (weak, nonatomic) IBOutlet UIView *scheduledView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scheduledHeaderSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIView *scheduledHeaderView;
@property (weak, nonatomic) IBOutlet CPHubSettingsButton *scheduledButton;
@property (weak, nonatomic) IBOutlet UILabel *scheduledHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduledBodyLabel;
@property (weak, nonatomic) IBOutlet UIView *scheduledActiveView;
@property (weak, nonatomic) IBOutlet UILabel *weekdaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayRangeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayRangeEndLabel;
@property (weak, nonatomic) IBOutlet NMRangeSlider *weekDaySlider;
@property (weak, nonatomic) IBOutlet UILabel *weekendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekendRangeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekendRangeEndLabel;
@property (weak, nonatomic) IBOutlet NMRangeSlider *weekendSlider;

// Off
@property (weak, nonatomic) IBOutlet UIStackView *offView;
@property (weak, nonatomic) IBOutlet CPHubSettingsButton *offButton;
@property (weak, nonatomic) IBOutlet UILabel *offHeader;
@property (weak, nonatomic) IBOutlet UILabel *offBodyLabel;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *headerLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *bodyLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *weekdayLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *timeRangeLabels;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *separators;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *backgroundViews;
@property (strong, nonatomic) IBOutletCollection(CPHubSettingsButton) NSArray *stateButtons;
@property (strong, nonatomic) IBOutletCollection(NMRangeSlider) NSArray *sliders;

@property (nonatomic, assign) HubSetting currentHubSetting;
@property (nonatomic, strong) NSDictionary *hubSettingToModeMap;
@property (nonatomic, strong) NSDictionary *modeToHubSettingMap;
@property (nonatomic, strong) CPDevice *currentDevice;
@property (nonatomic, weak) UIBarButtonItem *pseudoBackButton;

@end

@implementation CPHubSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hubSettingToModeMap = @{@(HubSetting_Off):kStandbyMode, @(HubSetting_On):kActiveMode, @(HubSetting_Scheduled):kSchedulerMode};
    self.modeToHubSettingMap = @{kStandbyMode:@(HubSetting_Off), kActiveMode:@(HubSetting_On), kSchedulerMode:@(HubSetting_Scheduled)};
    
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.stackView.backgroundColor = [UIColor clearColor];
    [self.separators makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:245.0/255.0 alpha:1.0]];
    self.headerView.backgroundColor = [UIColor appBackgroundColor];
    [self.backgroundViews makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor appWhiteColor]];
    
    [self setupFonts];
    
    self.currentDevice = [[CPUserManager sharedInstance] getCurrentUser].device;
    [self setupSliders];
    // TODO: Hub listener, etc so we can display disconnected or waiting for data as appropriate when the state changes
    // TODO: hub setting, scheduled settings from server
    self.currentHubSetting = [self.modeToHubSettingMap[self.currentDevice.mode] integerValue];
    switch (self.connectionState) {
        case HubConnectionState_Connected:
        {
            [self setupForHubSetting:self.currentHubSetting animated:NO];
            break;
        }
        case HubConnectionState_Unknown:
        case HubConnectionState_Disconnected:
        {
            [self hubDisconnected];
            break;
        }
        case HubConnectionState_Offline:
        {
            [self hubNoData];
            break;
        }
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // TODO: button image
    [button setTitle:@"Back" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont cpLightFontWithSize:12 italic:NO]];
    [button sizeToFit];
    [button setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barButton;
    self.pseudoBackButton = barButton;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupFonts
{
    [self.headerLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO]];
    [self.headerLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor appTitleTextColor]];
    [self.bodyLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont cpLightFontWithSize:kHubStatusSubCopyFontSize italic:NO]];
    [self.bodyLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor appSubCopyTextColor]];
    [self.weekdayLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont cpLightFontWithSize:12.0 italic:NO]];
    [self.weekdayLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor appTitleTextColor]];
    [self.timeRangeLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont cpLightFontWithSize:15.0 italic:NO]];
    [self.timeRangeLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor appTitleTextColor]];
}

- (void)setupSliders
{
    [self.sliders makeObjectsPerformSelector:@selector(setTintColor:) withObject:[UIColor appTealColor]];
    // TODO: Generate images for slider background track, foreground track, and thumbs if if the default is not sufficient
    self.weekDaySlider.minimumValue = 0;
    self.weekDaySlider.maximumValue = 24;
    self.weekDaySlider.stepValue = 1;
    self.weekDaySlider.upperValue = self.currentDevice.weekdaySchedule.endTime;
    self.weekDaySlider.lowerValue = self.currentDevice.weekdaySchedule.startTime;
    [self updateWeekdayRange];
    
    self.weekendSlider.minimumValue = 0;
    self.weekendSlider.maximumValue = 24;
    self.weekendSlider.stepValue = 1;
    self.weekendSlider.upperValue = self.currentDevice.weekendSchedule.endTime;
    self.weekendSlider.lowerValue = self.currentDevice.weekendSchedule.startTime;
    [self updateWeekendRange];
}

- (void)hubDisconnected
{
    [self animateChanges:^{
        // TODO: actual strings
        self.disconnectedHeaderLabel.text = NSLocalizedString(@"Status Pending", @"No data header for when the hub is not connected to data");
        self.disconnectedBodyLabel.text = NSLocalizedString(@"The Hub is not connected to the Internet.", @"No data message for when the hub is not connected to data");
        [self hideDisconnectedView:NO];
    } withDuration:.3];
}

- (void)hubNoData
{
    [self animateChanges:^{
        // TODO: actual strings
        self.disconnectedHeaderLabel.text = NSLocalizedString(@"Status Unknown", @"No data header for when the app is not connected to data");
        self.disconnectedBodyLabel.text = NSLocalizedString(@"This app is not connected to the Internet", @"No data message for when the app is not connected to data");
        [self hideDisconnectedView:NO];
    } withDuration:.3];
}

- (void)setupForHubSetting:(HubSetting)hubSetting animated:(BOOL)animated
{
    [self animateChanges:^{
        [self hideDisconnectedView:YES];
        self.onButton.selected = hubSetting == HubSetting_On;
        self.scheduledButton.selected = hubSetting == HubSetting_Scheduled;
        self.scheduledHeaderSpacingConstraint.constant = hubSetting == HubSetting_Scheduled ? self.scheduledActiveView.bounds.size.height : 0;
        self.offButton.selected = hubSetting == HubSetting_Off;
        [self.view layoutIfNeeded];
    } withDuration:(animated ? .3 : 0)];
}

// TODO: a more appropriate name
- (void)hideDisconnectedView:(BOOL)hidden
{
    self.disconnectedView.hidden = hidden;
    self.onView.hidden = !hidden;
    self.scheduledView.hidden = !hidden;
    self.offView.hidden = !hidden;
    [self hideButtonsAndSliders:!hidden];
}

- (void)hideButtonsAndSliders:(BOOL)hidden
{
    // I don't like this but was unable to get them hiding properly with constraints
    for (UIButton *button in self.stateButtons) {
        button.hidden = hidden;
    }
    for (NMRangeSlider *slider in self.sliders) {
        slider.hidden = hidden;
    }
}

- (void)animateChanges:(void (^)(void))animations withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:animations completion:nil];
}

- (void)updateWeekdayRange
{
    self.weekdayRangeStartLabel.text = [self timeFromSliderValue:self.weekDaySlider.lowerValue];
    self.weekdayRangeEndLabel.text = [self timeFromSliderValue:self.weekDaySlider.upperValue];
}

- (void)updateWeekendRange
{
    self.weekendRangeStartLabel.text = [self timeFromSliderValue:self.weekendSlider.lowerValue];
    self.weekendRangeEndLabel.text = [self timeFromSliderValue:self.weekendSlider.upperValue];
}

- (NSString *)timeFromSliderValue:(CGFloat)value
{
    CGFloat roundedValue = roundf(value);
    NSString *amPm = (roundedValue >= 12 && roundedValue < 24) ? NSLocalizedString(@"pm", nil) : NSLocalizedString(@"am", nil);
    
    if (roundedValue >= 13) {
        roundedValue -= 12;
    } else if (roundedValue < 1) {
        roundedValue = 12;
    }
    
    return [NSString stringWithFormat:@"%.0f %@", roundedValue, amPm];
}

#pragma mark - IBActions
- (IBAction)onButtonTapped:(id)sender
{
    if (self.currentHubSetting != HubSetting_On) {
        self.currentHubSetting = HubSetting_On;
        [self setupForHubSetting:self.currentHubSetting animated:YES];
        
        // TODO: Update hub
    }
}

- (IBAction)scheduledButtonTapped:(id)sender
{
    if (self.currentHubSetting != HubSetting_Scheduled) {
        self.currentHubSetting = HubSetting_Scheduled;
        [self setupForHubSetting:self.currentHubSetting animated:YES];
        
        // TODO: Update hub
    }
}

- (IBAction)offButtonTapped:(id)sender
{
    if (self.currentHubSetting != HubSetting_Off) {
        self.currentHubSetting = HubSetting_Off;
        [self setupForHubSetting:self.currentHubSetting animated:YES];
        
        // TODO: Update hub
    }
}

- (IBAction)weekdaySliderValueChanged:(id)sender
{
    [self updateWeekdayRange];
    
    // TODO: Update hub
}

- (IBAction)weekendSliderValueChanged:(id)sender
{
    [self updateWeekendRange];
    
    // TODO: Update hub
}

- (void)backButtonTapped:(id)sender
{
    NSDictionary *deviceInfo = @{kModeKey:self.hubSettingToModeMap[@(self.currentHubSetting)], kWeekdayKey:@{kStartTimeKey:@(self.weekDaySlider.lowerValue), kEndTimeKey:@(self.weekDaySlider.upperValue)}, kWeekendKey:@{kStartTimeKey:@(self.weekendSlider.lowerValue), kEndTimeKey:@(self.weekendSlider.upperValue)}};
    
    if ([[CPUserManager sharedInstance] hasDeviceInfoChanged:deviceInfo]) {
        // Verify we're online
        if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
            [[CPUserManager sharedInstance] updateDeviceInfo:deviceInfo];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection Offline" message:NSLocalizedString(@"The internet connection appears to be offline. Changes will not be save.", @"Error message displayed when trying to save changes while device is offline") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel (Stay Here)", @"Cancel text for confirmation when discarding settings changes due to no data connection") style:UIAlertActionStyleCancel handler:nil];
            
            BLOCK_SELF_REF_OUTSIDE();
            UIAlertAction *discardAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue (Discard my Changes)", @"Continue text for confirmation when discarding settings changes due to no data connection") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                BLOCK_SELF_REF_INSIDE();
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [alert addAction:cancelAction];
            [alert addAction:discardAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
