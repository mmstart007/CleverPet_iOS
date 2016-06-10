//
//  SparkUserSignupViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/15/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkUserSignupViewController.h"
#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Spark-SDK.h"
#endif
#import "SparkUserLoginViewController.h"
#import "SparkSetupWebViewController.h"
#import "SparkSetupCustomization.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupMainController.h"
#ifdef ANALYTICS
#import <Mixpanel.h>
#endif

@interface SparkUserSignupViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordVerifyTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *haveAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *createAccountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupButtonSpace;
@property (weak, nonatomic) IBOutlet SparkSetupUIButton *skipAuthButton;
@property (strong, nonatomic) UIAlertView *skipAuthAlertView;

@end

@implementation SparkUserSignupViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    // Add underlines to link buttons / bold to navigation buttons
//    [self makeLinkButton:self.termsButton withText:nil];
//    [self makeLinkButton:self.privacyButton withText:nil];
//    [self makeBoldButton:self.haveAccountButton withText:nil];
    
    // set brand logo
    self.logoImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.logoImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    // add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView1 = [[UIView alloc] initWithFrame:viewRect];
    UIView* emptyView2 = [[UIView alloc] initWithFrame:viewRect];
    UIView* emptyView3 = [[UIView alloc] initWithFrame:viewRect];
//    UIView* emptyView4 = [[UIView alloc] initWithFrame:viewRect];
    
    self.emailTextField.leftView = emptyView1;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];

    self.passwordTextField.leftView = emptyView2;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];

    self.passwordVerifyTextField.leftView = emptyView3;
    self.passwordVerifyTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordVerifyTextField.delegate = self;
    self.passwordVerifyTextField.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];

    /*
    if ([SparkSetupCustomization sharedInstance].organization)
    {
        self.passwordVerifyTextField.returnKeyType = UIReturnKeyNext;
        
        self.activationCodeTextField.leftView = emptyView4;
        self.activationCodeTextField.leftViewMode = UITextFieldViewModeAlways;
        self.activationCodeTextField.delegate = self;
        self.activationCodeTextField.hidden = NO;
        self.activationCodeTextField.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];
     self.activationCodeTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
     self.activationCodeTextField.delegate = self;
     
     else
     {*/
    // make sign up button be closer to verify password textfield (no activation code field)
    self.signupButtonSpace.constant = 16;
    self.skipAuthButton.hidden = !([SparkSetupCustomization sharedInstance].allowSkipAuthentication);
    
    
    /*
     if ((self.predefinedActivationCode) && (self.predefinedActivationCode.length >= 4))
     {
        // trim white space, set string max length to 4 chars and uppercase it
        NSString *code = self.predefinedActivationCode;
        NSString *codeWhiteSpaceTrimmed = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        codeWhiteSpaceTrimmed = [codeWhiteSpaceTrimmed stringByReplacingOccurrencesOfString:@" " withString:@""];
        codeWhiteSpaceTrimmed = [codeWhiteSpaceTrimmed stringByReplacingOccurrencesOfString:@"%20" withString:@""];
        NSRange stringRange = {0, 4};
        NSString *shortActCode = [codeWhiteSpaceTrimmed substringWithRange:stringRange];
        self.activationCodeTextField.text = [shortActCode uppercaseString];
    }

     */
   

}


// removed activation code
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == self.activationCodeTextField)
    {
        NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    
        // make activation code uppercase
        if (lowercaseCharRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                     withString:[string uppercaseString]];
            return NO;
        }
        
        // limit it to 4 chars
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 4) ? NO : YES;
    }
    
    return YES;
}
 */


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    if (textField == self.passwordTextField)
    {
        [self.passwordVerifyTextField becomeFirstResponder];
    }
    if (textField == self.passwordVerifyTextField)
    {
//        if ([SparkSetupCustomization sharedInstance].organization)
//            [self.activationCodeTextField becomeFirstResponder];
//        else
            [self signupButton:self];
    }
//    if (textField == self.activationCodeTextField)
//    {
//        [self signupButton:self];
//    }
    
    return YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[Mixpanel sharedInstance] track:@"Auth: Sign Up screen"];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)signupButton:(id)sender
{
    [self.view endEditing:YES];
    __block NSString *email = [self.emailTextField.text lowercaseString];
    
    if (![self.passwordTextField.text isEqualToString:self.passwordVerifyTextField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords do not match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self isValidEmail:email])
    {
        BOOL orgMode = [SparkSetupCustomization sharedInstance].organization;
        if (orgMode)
        {
            // org user sign up
            [self.spinner startAnimating];
            
            // Sign up and then login
            [[SparkCloud sharedInstance] signupWithCustomer:email password:self.passwordTextField.text orgSlug:[SparkSetupCustomization sharedInstance].organizationSlug completion:^(NSError *error) {
                if (!error)
                {
#ifdef ANALYTICS
                    [[Mixpanel sharedInstance] track:@"Auth: Signed Up New Customer"];
#endif
                    
                    [self.delegate didFinishUserAuthentication:self loggedIn:YES];

                }
                else
                {
                    [self.spinner stopAnimating];
                    NSLog(@"Error signing up: %@",error.localizedDescription);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not signup" message:@"Make sure your user email does not already exist and that you have entered the activation code correctly and that it was not already used"/*error.localizedDescription*/ delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
            }];
        }
        else
        {
            // normal user sign up
            [self.spinner startAnimating];
            
            // Sign up and then login
            [[SparkCloud sharedInstance] signupWithUser:email password:self.passwordTextField.text completion:^(NSError *error) {
                if (!error)
                {
#ifdef ANALYTICS
                    [[Mixpanel sharedInstance] track:@"Auth: Signed Up New User"];
#endif
                    
                    [[SparkCloud sharedInstance] loginWithUser:email password:self.passwordTextField.text completion:^(NSError *error) {
                        [self.spinner stopAnimating];
                        if (!error)
                        {
                            //                        [self performSegueWithIdentifier:@"discover" sender:self];
                            [self.delegate didFinishUserAuthentication:self loggedIn:YES];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                }
                else
                {
                    [self.spinner stopAnimating];
                    NSLog(@"Error signing up: %@",error.localizedDescription);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
            }];
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)privacyPolicyButton:(id)sender
{
    [self.view endEditing:YES];
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].privacyPolicyLinkURL;
//    webVC.htmlFilename = @"test";
    [self presentViewController:webVC animated:YES completion:nil];
}



- (IBAction)termOfServiceButton:(id)sender
{
    [self.view endEditing:YES];
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].termsOfServiceLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
}



- (IBAction)haveAnAccountButtonTouched:(id)sender
{
    [self.view endEditing:YES];
    [self.delegate didRequestUserLogin:self];
    
    /*
    SparkUserLoginViewController* loginVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"login"];
    loginVC.delegate = self.delegate;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;// //UIModalPresentationPageSheet;
    [self presentViewController:loginVC animated:YES completion:nil];
     */
}

- (IBAction)skipAuthButtonTapped:(id)sender {
    // that means device is claimed by somebody else - we want to check that with user (and set claimcode if user wants to change ownership)
    NSString *messageStr = [SparkSetupCustomization sharedInstance].skipAuthenticationMessage;
    self.skipAuthAlertView = [[UIAlertView alloc] initWithTitle:@"Skip authentication" message:messageStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No",nil];
    [self.skipAuthAlertView show];

}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.skipAuthAlertView)
    {
        if (buttonIndex == 0) //YES
        {
#ifdef ANALYTICS
            [[Mixpanel sharedInstance] track:@"Auth: Auth skipped"];
#endif
            [self.delegate didFinishUserAuthentication:self loggedIn:NO];
        }
    }
}


@end
