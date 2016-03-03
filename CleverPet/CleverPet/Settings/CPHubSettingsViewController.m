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
@property (weak, nonatomic) IBOutlet UILabel *disconnectedSubHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *disconnectedSubBodyLabel;

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
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *subHeaderLabels;
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
    [self setupSliders];
    
    self.currentDevice = [[CPUserManager sharedInstance] getCurrentUser].device;
    // TODO: Hub listener, etc so we can display disconnected or waiting for data as appropriate when the state changes
    // TODO: hub setting, scheduled settings from server
    self.currentHubSetting = [self.modeToHubSettingMap[self.currentDevice.mode] integerValue];
    [self setupForHubSetting:self.currentHubSetting animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // TODO: schedule nonsense
    // TODO: We shouldn't do this if we've disappeared because of the version check
    // TODO: should we save on moving to background?
    [[CPUserManager sharedInstance] updateDeviceInfo:@{kModeKey:self.hubSettingToModeMap[@(self.currentHubSetting)]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupFonts
{
    [self.headerLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO]];
    [self.headerLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor appTitleTextColor]];
    [self.subHeaderLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont cpLightFontWithSize:kSubCopyFontSize italic:NO]];
    [self.subHeaderLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor appTitleTextColor]];
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
        self.disconnectedHeaderLabel.text = NSLocalizedString(@"Disconnected", nil);
        self.disconnectedBodyLabel.text = @"This is some placeholder disconnected body text. Please update me";
        self.disconnectedSubHeaderLabel.text = @"This is a placeholder sub headline. Please update me";
        self.disconnectedSubBodyLabel.text = @"This is some placeholder disconnected sub body text. Please update me.";
        [self hideDisconnectedView:NO];
    } withDuration:.3];
}

- (void)hubNoData
{
    [self animateChanges:^{
        // TODO: actual strings
        self.disconnectedHeaderLabel.text = NSLocalizedString(@"No Data", nil);
        self.disconnectedBodyLabel.text = @"This is some placeholder no data body text. Please update me";
        self.disconnectedSubHeaderLabel.text = @"This is a placeholder sub headline. Please update me";
        self.disconnectedSubBodyLabel.text = @"This is some placeholder no data sub body text. Please update me.";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
