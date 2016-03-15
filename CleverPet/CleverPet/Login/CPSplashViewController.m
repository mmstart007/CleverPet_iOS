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

@end

@implementation CPSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStyling];
    self.signInButton.hidden = YES;
    
    self.backgroundImage.image = [CPSplashImageUtils getSplashImage];
    
    BLOCK_SELF_REF_OUTSIDE();
    [[CPConfigManager sharedInstance] loadConfigWithCompletion:^(NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (error) {
            // TODO: ship off to the app store or something
            [self displayErrorAlertWithTitle:NSLocalizedString(@"App Version Out of Date", @"Title for alert shown when using out of date version of the app") andMessage:error.localizedDescription];
        } else {
            [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.signInButton.hidden = NO;
            } completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupStyling
{
    self.signInButton.backgroundColor = [UIColor appLightTealColor];
    [self.signInButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.signInButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:0];
}

- (void)showLoadingSpinner:(BOOL)show
{
    [UIView animateWithDuration:.3 animations:^{
        self.fadeView.hidden = !show;
        self.signInButton.hidden = show;
    }];
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
        [self displayErrorAlertWithTitle:NSLocalizedString(@"Error", @"Login error alert title") andMessage:message];
    }
}

- (void)loginAttemptCancelled
{
    [self showLoadingSpinner:NO];
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
