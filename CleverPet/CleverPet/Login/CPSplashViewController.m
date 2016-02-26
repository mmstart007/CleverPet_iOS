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

@interface CPSplashViewController ()<CPLoginControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIView *fadeView;

@end

@implementation CPSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStyling];
    self.signInButton.hidden = YES;
    [[CPConfigManager sharedInstance] loadConfigWithCompletion:^(NSError *error) {
        // TODO: display error
        if (!error) {
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
    self.taglineLabel.font = [UIFont cpLightFontWithSize:16.0 italic:NO];
    self.taglineLabel.textColor = [UIColor appGreyColor];
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
    [self displayErrorAlertWithTitle:NSLocalizedString(@"Error", @"Login error alert title") andMessage:message];
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
