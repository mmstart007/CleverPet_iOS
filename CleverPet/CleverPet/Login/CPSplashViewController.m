//
//  CPSplashViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSplashViewController.h"
#import "CPLoginController.h"
#import "CPConfigManager.h"
#import "CPLoadingView.h"
#import "CPSplashImageUtils.h"

@interface CPSplashViewController ()<CPLoginControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIView *fadeView;
@property (nonatomic, assign) BOOL listeningForConfigUpdates;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideSignInButtonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showSignInButtonConstraint;
@end

@implementation CPSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStyling];
    
    self.fadeView.alpha = 0;
    self.fadeView.hidden = NO;

    [self makeSignInButtonVisible:NO animated:NO];
    
    self.backgroundImage.image = [CPSplashImageUtils getSplashImage];
    
    BLOCK_SELF_REF_OUTSIDE();
    [[CPConfigManager sharedInstance] loadConfig:NO completion:^(NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        [self finishConfigLoad:error];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
}

- (void)setupStyling
{
    self.signInButton.backgroundColor = [UIColor appLightTealColor];
    [self.signInButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.signInButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:0];
}

- (void)showLoadingSpinner:(BOOL)show
{
    self.fadeView.alpha = !show ? 1 : 0;
    [UIView animateWithDuration:.3 animations:^{
        self.fadeView.alpha = show ? 1 : 0;
    }];
    
    [self makeSignInButtonVisible:!show animated:YES];
}

#pragma mark - IBActions
- (IBAction)signInTapped:(id)sender
{
    [[CPLoginController sharedInstance] startSigninWithDelegate:self];
    [self showLoadingSpinner:YES];
}

#pragma mark - CPLoginControllerDelegate methods
- (void)loginAttemptFailed:(NSString *)message
{
    [self showLoadingSpinner:NO];
    if (message) {
        [self displayErrorAlertWithTitle:ERROR_TEXT andMessage:message];
    }
}

- (void)loginAttemptCancelled
{
    [self showLoadingSpinner:NO];
}

- (void)configUpdated:(NSNotification *)notification
{
    NSError *error = notification.userInfo[kConfigErrorKey];
    [self finishConfigLoad:error];
}

- (void)listenForConfigUpdates
{
    if (!self.listeningForConfigUpdates) {
        self.listeningForConfigUpdates = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configUpdated:) name:kConfigUpdatedNotification object:nil];
    }
}

- (void)stopListeningForConfigUpdates
{
    if (self.listeningForConfigUpdates) {
        self.listeningForConfigUpdates = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfigUpdatedNotification object:nil];
    }
}

- (void)finishConfigLoad:(NSError *)error
{
    if (error) {
        // TODO: ship off to the app store or something
        
        // Don't display error if we're not visible. May have to look at this again
        if (self.view.window != nil) {
            NSString *errorTitle = [error.domain isEqualToString:@"AppVersion"] ? NSLocalizedString(@"App Version Out of Date", @"Title for alert shown when using out of date version of the app") : NSLocalizedString(@"Unable to load app config", @"Title for error shown when unable to load app config");
            [self displayErrorAlertWithTitle:errorTitle andMessage:error.localizedDescription];
        }
        [self listenForConfigUpdates];
    } else {
        [self stopListeningForConfigUpdates];
        
        [self.signInButton layoutIfNeeded];
        
        [self makeSignInButtonVisible:YES animated:YES];
    }
}

- (void)makeSignInButtonVisible:(BOOL)visible animated:(BOOL)animated
{
    if (animated) {
        [self.signInButton layoutIfNeeded];
    }
    self.hideSignInButtonConstraint.priority = visible ? 998 : 999;
    self.showSignInButtonConstraint.priority = visible ? 999 : 998;

    if (animated) {
        [UIView animateWithDuration:.2 animations:^{
            [self.signInButton layoutIfNeeded];
        }];
    } else {
        [self.signInButton layoutIfNeeded];
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
