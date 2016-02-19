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
@property (weak, nonatomic) IBOutlet UIStackView *scheduledView;
@property (weak, nonatomic) IBOutlet CPHubSettingsButton *scheduledButton;
@property (weak, nonatomic) IBOutlet UILabel *scheduledHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduledBodyLabel;
@property (weak, nonatomic) IBOutlet UIView *scheduledActiveView;
@property (weak, nonatomic) IBOutlet UILabel *weekdaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayRangeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayRangeEndLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekendRangeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekendRangeEndLabel;

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

@property (nonatomic, assign) HubSetting currentHubSetting;

@end

@implementation CPHubSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.stackView.backgroundColor = [UIColor clearColor];
    [self.separators makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:245.0/255.0 alpha:1.0]];
    self.headerView.backgroundColor = [UIColor appBackgroundColor];
    [self.backgroundViews makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor appWhiteColor]];
    
    [self setupFonts];
    
    // TODO: Hub listener, etc so we can display disconnected or waiting for data as appropriate when the state changes
    // TODO: hub setting, scheduled settings from server
    self.currentHubSetting = HubSetting_Scheduled;
    [self setupForHubSetting:self.currentHubSetting];
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

- (void)hubDisconnected
{
    [self animateChanges:^{
        // TODO: actual strings
        self.disconnectedHeaderLabel.text = NSLocalizedString(@"Disconnected", nil);
        self.disconnectedBodyLabel.text = @"This is some placeholder disconnected body text. Please update me";
        self.disconnectedSubHeaderLabel.text = @"This is a placeholder sub headline. Please update me";
        self.disconnectedSubBodyLabel.text = @"This is some placeholder disconnected sub body text. Please update me.";
        self.disconnectedView.hidden = NO;
        self.onView.hidden = YES;
        self.scheduledView.hidden = YES;
        self.offView.hidden = YES;
        // I don't like this but was unable to get them hiding properly with constraints
        for (UIButton *button in self.stateButtons) {
            button.hidden = YES;
        }
    }];
}

- (void)hubNoData
{
    [self animateChanges:^{
        // TODO: actual strings
        self.disconnectedHeaderLabel.text = NSLocalizedString(@"No Data", nil);
        self.disconnectedBodyLabel.text = @"This is some placeholder no data body text. Please update me";
        self.disconnectedSubHeaderLabel.text = @"This is a placeholder sub headline. Please update me";
        self.disconnectedSubBodyLabel.text = @"This is some placeholder no data sub body text. Please update me.";
        self.disconnectedView.hidden = NO;
        self.onView.hidden = YES;
        self.scheduledView.hidden = YES;
        self.offView.hidden = YES;
        // I don't like this but was unable to get them hiding properly with constraints
        for (UIButton *button in self.stateButtons) {
            button.hidden = YES;
        }
    }];
}

- (void)setupForHubSetting:(HubSetting)hubSetting
{
    [self animateChanges:^{
        self.disconnectedView.hidden = YES;
        self.onView.hidden = NO;
        self.onButton.selected = hubSetting == HubSetting_On;
        self.scheduledView.hidden = NO;
        self.scheduledButton.selected = hubSetting == HubSetting_Scheduled;
        self.scheduledActiveView.hidden = hubSetting != HubSetting_Scheduled;
        self.offView.hidden = NO;
        self.offButton.selected = hubSetting == HubSetting_Off;
        // I don't like this but was unable to get them hiding properly with constraints
        for (UIButton *button in self.stateButtons) {
            button.hidden = NO;
        }
    }];
}

- (void)animateChanges:(void (^)(void))animations
{
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:animations completion:nil];
}

#pragma mark - IBActions
- (IBAction)onButtonTapped:(id)sender
{
    if (self.currentHubSetting != HubSetting_On) {
        self.currentHubSetting = HubSetting_On;
        [self setupForHubSetting:self.currentHubSetting];
    }
}

- (IBAction)scheduledButtonTapped:(id)sender
{
    if (self.currentHubSetting != HubSetting_Scheduled) {
        self.currentHubSetting = HubSetting_Scheduled;
        [self setupForHubSetting:self.currentHubSetting];
    }
}

- (IBAction)offButtonTapped:(id)sender
{
    if (self.currentHubSetting != HubSetting_Off) {
        self.currentHubSetting = HubSetting_Off;
        [self setupForHubSetting:self.currentHubSetting];
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
