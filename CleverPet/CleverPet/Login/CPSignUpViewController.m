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

@interface CPSignUpViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *verifyField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpButtonBottomConstraint;

@end

@implementation CPSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStyling];
    self.emailField.text = self.email;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.signUpButton.backgroundColor = [UIColor appLightTealColor];
    [self.signUpButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.signUpButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
}

- (BOOL)validateInput
{
    NSString *emailString = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![[CPLoginController sharedInstance] isValidEmail:emailString]) {
        [self displayErrorAlertWithTitle:nil andMessage:NSLocalizedString(@"Please enter a valid email address", @"Error message when trying to sign in with an invalid email address")];
        return NO;
    }
    
    if ([[self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 1) {
        [self displayErrorAlertWithTitle:nil andMessage:NSLocalizedString(@"Please enter a display name", @"Error message when trying to sign up with an invalid display name")];
        return NO;
    }
    
    // TODO: Password verification before sending to identity toolkit
    
    if ([self.passwordField.text length] < 1 || self.verifyField.text.length < 1) {
        [self displayErrorAlertWithTitle:nil andMessage:NSLocalizedString(@"Please enter and verify your password", @"Error message when trying to sign up with missing password")];
        return NO;
    }
    
    if (![self.passwordField.text isEqualToString:self.verifyField.text]) {
        [self displayErrorAlertWithTitle:NSLocalizedString(@"The passwords entered do not match", @"Error title when trying to sign up with mismatched passwords") andMessage:NSLocalizedString(@"Please re-enter your password", @"Error message when trying to sign up with mismatched passwords")];
        return NO;
    }
    
    return YES;
}

#pragma mark - IBActions
- (IBAction)signUpTapped:(id)sender
{
    if ([self validateInput]) {
        [[CPLoginController sharedInstance] signUpWithEmail:[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] displayName:[self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] andPassword:self.passwordField.text];
    }
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailField) {
        [self.nameField becomeFirstResponder];
    } else if(textField == self.nameField) {
        [self.passwordField becomeFirstResponder];
    } else if(textField == self.passwordField) {
        [self.verifyField becomeFirstResponder];
    } else {
        // TODO: Proceed with sign in?
        [textField resignFirstResponder];
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
        self.signUpButtonBottomConstraint.constant = keyboardRect.size.height;
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
        self.signUpButtonBottomConstraint.constant = 0.f;
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
