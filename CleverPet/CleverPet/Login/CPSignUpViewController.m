//
//  CPSignUpViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSignUpViewController.h"
#import "CPLoginController.h"
#import "CPTextField.h"

@interface CPSignUpViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *verifyField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CPSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStyling];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupStyling
{
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.headerLabel.font = [UIFont cpLightFontWithSize:kSignInHeaderFontSize italic:NO];
    self.headerLabel.textColor = [UIColor appSignUpHeaderTextColor];
    self.signUpButton.backgroundColor = [UIColor appLightTealColor];
    [self.signUpButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.signUpButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
}

#pragma mark - IBActions
- (IBAction)signUpTapped:(id)sender
{
    [[CPLoginController sharedInstance] signUpWithEmail:self.emailField.text displayName:self.nameField.text andPassword:self.passwordField.text];
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
