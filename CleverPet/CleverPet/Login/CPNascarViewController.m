//
//  CPNascarViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPNascarViewController.h"
#import "CPLoginController.h"
#import "CPTextField.h"
#import "CPLoadingView.h"
#import <Intercom/Intercom.h>

@interface CPNascarViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet CPTextField *emailField;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet CPLoadingView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *intercomButton;

@end

@implementation CPNascarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStyling];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)setupStyling
{
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.headerLabel.font = [UIFont cpLightFontWithSize:17.0 italic:NO];
    self.headerLabel.textColor = [UIColor appTitleTextColor];
    self.orLabel.font = [UIFont cpLightFontWithSize:15.0 italic:NO];
    self.orLabel.textColor = [UIColor appTitleTextColor];
    
    self.facebookButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    self.facebookButton.backgroundColor = [UIColor colorWithRed:0.235 green:0.353 blue:0.584 alpha:1.00];
    [self.facebookButton setTitleColor:[UIColor appWhiteColor] forState:UIControlStateNormal];
    self.googleButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    self.googleButton.backgroundColor = [UIColor appWhiteColor];
    [self.googleButton setTitleColor:[UIColor appTitleTextColor] forState:UIControlStateNormal];
    self.signInButton.backgroundColor = [UIColor appLightTealColor];
    [self.signInButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.signInButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.cancelButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.intercomButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.intercomButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
}

- (BOOL)validateInput
{
    NSString *emailString = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *errorMessage;
    
    if ([emailString length] > kEmailMaxChars) {
        errorMessage = [NSString stringWithFormat:NSLocalizedString(@"Your email address must be less than %d characters", @"Error message displayed when email address exceeds max length"), kEmailMaxChars];
    } else if (![[CPLoginController sharedInstance] isValidEmail:emailString]) {
        NSLocalizedString(@"Please enter a valid email address", @"Error message when trying to sign in with an invalid email address");
    }
    
    if (errorMessage) {
        [self displayErrorAlertWithTitle:nil andMessage:errorMessage];
        return NO;
    }
    
    return YES;
}

#pragma mark - IBActions
- (IBAction)facebookTapped:(id)sender
{
    self.loadingView.hidden = NO;
    [[CPLoginController sharedInstance] signInWithFacebook];
}

- (IBAction)googleTapped:(id)sender
{
    self.loadingView.hidden = NO;
    [[CPLoginController sharedInstance] signInWithGoogle];
}

- (IBAction)signInTapped:(id)sender
{
    if ([self validateInput]) {
        self.loadingView.hidden = NO;
        [[CPLoginController sharedInstance] signInWithEmail:[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
}

- (IBAction)cancelTapped:(id)sender
{
    [[CPLoginController sharedInstance] loginViewPressedCancel:self];
}

- (IBAction)intercomTapped:(id)sender
{
    [Intercom presentConversationList];
}
#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self signInTapped:nil];
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
