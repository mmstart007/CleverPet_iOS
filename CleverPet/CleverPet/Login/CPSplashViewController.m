//
//  CPSplashViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSplashViewController.h"
#import "CPLoginController.h"

@interface CPSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation CPSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStyling];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginComplete:) name:kLoginCompleteNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - IBActions
- (IBAction)signInTapped:(id)sender
{
    [[CPLoginController sharedInstance] startSignin];
}

- (void)loginComplete:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo[kLoginErrorKey]) {
        // TODO: display error
    } else {
        // TODO: skip profile set up if we've already done it
        [self performSegueWithIdentifier:@"setupPetProfile" sender:nil];
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
