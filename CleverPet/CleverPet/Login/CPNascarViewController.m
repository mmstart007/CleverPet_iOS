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

@interface CPNascarViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet CPTextField *emailField;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInButtonBottomConstraint;

@property (nonatomic, strong) NSDataDetector *dataDetector;

@end

@implementation CPNascarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStyling];
    self.dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)setupStyling
{
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.headerLabel.font = [UIFont cpLightFontWithSize:17.0 italic:NO];
    self.headerLabel.textColor = [UIColor appSignUpHeaderTextColor];
    self.orLabel.font = [UIFont cpLightFontWithSize:15.0 italic:NO];
    self.orLabel.textColor = [UIColor appSignUpHeaderTextColor];
    
    self.facebookButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    self.googleButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    self.signInButton.backgroundColor = [UIColor appLightTealColor];
    [self.signInButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.signInButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
}

- (BOOL)validateInput
{
    NSString *emailString = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *emailMatches = [self.dataDetector matchesInString:emailString options:kNilOptions range:NSMakeRange(0, [emailString length])];
    
    if ([emailMatches count] == 1 && [[[emailMatches firstObject] URL].scheme isEqualToString:@"mailto"]) {
        return YES;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Please enter a valid email address", @"Error message when trying to sign in with an invalid email address") preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    return NO;
}

#pragma mark - IBActions
- (IBAction)facebookTapped:(id)sender
{
    [[CPLoginController sharedInstance] signInWithFacebook];
}

- (IBAction)googleTapped:(id)sender
{
    [[CPLoginController sharedInstance] signInWithGoogle];
}

- (IBAction)signInTapped:(id)sender
{
    if ([self validateInput]) {
        [[CPLoginController sharedInstance] signInWithEmail:self.emailField.text];
    }
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    // TODO: Proceed with sign in?
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
