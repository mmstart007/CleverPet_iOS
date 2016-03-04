//
//  CPSignInViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSignInViewController.h"
#import "CPLoginController.h"
#import "CPTextField.h"
#import "CPLoadingView.h"

@interface CPSignInViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet CPTextField *emailField;
@property (weak, nonatomic) IBOutlet CPTextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet CPLoadingView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation CPSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.emailField.text = self.email;
    [self setupStyling];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    REG_SELF_FOR_NOTIFICATION(UIKeyboardWillShowNotification, keyboardWillShow:);
    REG_SELF_FOR_NOTIFICATION(UIKeyboardWillHideNotification, keyboardWillHide:);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
    self.loadingView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupStyling
{
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.headerLabel.font = [UIFont cpLightFontWithSize:kSignInHeaderFontSize italic:NO];
    self.headerLabel.textColor = [UIColor appTitleTextColor];
    self.forgotPasswordButton.titleLabel.font = [UIFont cpLightFontWithSize:12.f italic:NO];
    [self.forgotPasswordButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.signInButton.backgroundColor = [UIColor appLightTealColor];
    [self.signInButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.signInButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.cancelButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
}

- (BOOL)validateInput
{
    NSString *emailString = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![[CPLoginController sharedInstance] isValidEmail:emailString]) {
        [self displayErrorAlertWithTitle:nil andMessage:NSLocalizedString(@"Please enter a valid email address", @"Error message when trying to sign in with an invalid email address")];
        return NO;
    }
    
    return YES;
}

#pragma mark - IBActions
- (IBAction)forgotPasswordTapped:(id)sender
{
    
}

- (IBAction)signInTapped:(id)sender
{
    if ([self validateInput]) {
        self.loadingView.hidden = NO;
        [[CPLoginController sharedInstance] verifyPassword:self.passwordField.text forEmail:self.emailField.text failure:^{
            self.loadingView.hidden = YES;
            [self displayErrorAlertWithTitle:NSLocalizedString(@"Incorrect Password", @"Alert title when password sign in fails") andMessage:NSLocalizedString(@"Please check your password and try again", @"Alert message when password sign in fails")];
        }];
    }
}

- (IBAction)cancelTapped:(id)sender
{
    [[CPLoginController sharedInstance] loginViewPressedCancel:self];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self signInTapped:nil];
    }
    return YES;
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)note
{
    NSDictionary *info = [note userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [UIView setAnimationCurve:curve];
        self.signInButtonBottomConstraint.constant = keyboardRect.size.height;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    NSDictionary *info = [note userInfo];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [UIView setAnimationCurve:curve];
        self.signInButtonBottomConstraint.constant = 0.f;
        [self.view layoutIfNeeded];
    } completion:nil];
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
