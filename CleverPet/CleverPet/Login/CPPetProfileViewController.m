//
//  CPPetProfileViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPetProfileViewController.h"
#import "CPTextField.h"

NSInteger const kNameFieldMinChars = 2;
NSInteger const kNameFieldMaxChars = 10;
NSInteger const kFamilyNameFieldMinChars = 1;
NSInteger const kFamilyNameFieldMaxChars = 35;

@interface CPPetProfileViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *subCopyLabel;
@property (weak, nonatomic) IBOutlet CPTextField *nameField;
@property (weak, nonatomic) IBOutlet CPTextField *familyField;
@property (weak, nonatomic) IBOutlet CPTextField *breedField;
@property (weak, nonatomic) IBOutlet CPTextField *genderField;
@property (weak, nonatomic) IBOutlet CPTextField *ageField;
@property (weak, nonatomic) IBOutlet CPTextField *weightField;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonBottomConstraint;

@property (nonatomic, strong) NSArray *textFields;
@property (nonatomic, strong) NSCharacterSet *invalidNameCharacters;
@property (nonatomic, strong) NSCharacterSet *invalidFamilyNameCharacters;
@property (nonatomic, strong) NSCharacterSet *invalidNumericalCharacters;

@property (nonatomic, strong) NSString *weightDescriptor;

@end

@implementation CPPetProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // TODO: switch for weight units, gender, auto complete for breeds, potentially switch for altered
    [self setupStyling];
    self.textFields = @[self.nameField, self.familyField, self.breedField, self.genderField, self.ageField, self.weightField];
    
    NSMutableCharacterSet *alphaSet = [NSMutableCharacterSet alphanumericCharacterSet];
    // alpha includes letter, numbers and marks, we want to remove marks
    [alphaSet formIntersectionWithCharacterSet:[[NSCharacterSet nonBaseCharacterSet] invertedSet]];
    self.invalidNameCharacters = [alphaSet invertedSet];
    
    // Family name additionally allows spaces
    [alphaSet addCharactersInString:@" "];
    [alphaSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    self.invalidFamilyNameCharacters = [alphaSet invertedSet];
    
    self.invalidNumericalCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"] invertedSet];
    self.weightDescriptor = @"lbs";
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
    self.headerLabel.text = NSLocalizedString(@"Pet's Profile", @"Title text for pets profile");
    self.headerLabel.font = [UIFont cpLightFontWithSize:kSignInHeaderFontSize italic:NO];
    self.headerLabel.textColor = [UIColor appSignUpHeaderTextColor];
    self.subCopyLabel.text = NSLocalizedString(@"Placeholder sub copy", @"Sub copy text for pets profile");
    self.subCopyLabel.font = [UIFont cpLightFontWithSize:kSubCopyFontSize italic:NO];
    self.subCopyLabel.textColor = [UIColor appSubCopyTextColor];
    self.continueButton.backgroundColor = [UIColor appLightTealColor];
    self.continueButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.continueButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
}

- (BOOL)validateInput
{
    if ([self.nameField.text length] < kNameFieldMinChars || [self.nameField.text length] > kNameFieldMaxChars) {
        [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", @"Error title for profile setup") andMessage:[NSString stringWithFormat:NSLocalizedString(@"Name must be between %d and %d characters long", @"Error message when name name does not fit requirements. First %d is minimum number of characters, second is maximum"), kNameFieldMinChars, kNameFieldMaxChars]];
        return NO;
    }
    
    if ([self.familyField.text length] < kFamilyNameFieldMinChars || [self.familyField.text length] > kFamilyNameFieldMaxChars) {
        [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", @"Error title for profile setup") andMessage:[NSString stringWithFormat:NSLocalizedString(@"Family name must be between %d and %d characters long", @"Error message when family name does not fit requirements. First %d is minimum number of characters, second is maximum"), kFamilyNameFieldMinChars, kFamilyNameFieldMaxChars]];
        return NO;
    }
    
    if ([self.breedField.text length] == 0) {
        [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", @"Error title for profile setup") andMessage:NSLocalizedString(@"Please enter the breed of your pet", @"Error message when pet breed is empty")];
        return NO;
    }
    
    if ([self.genderField.text length] == 0) {
        [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", @"Error title for profile setup") andMessage:NSLocalizedString(@"Please enter the gender of your pet", @"Error message when pet gender is empty")];
        return NO;
    }
    
    if ([self.ageField.text length] == 0) {
        [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", @"Error title for profile setup") andMessage:NSLocalizedString(@"Please enter your pets age", @"Error message when pet age is empty")];
        return NO;
    }
    
    NSString *weight = [self.weightField.text stringByReplacingOccurrencesOfString:self.weightDescriptor withString:@""];
    weight = [weight stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([weight length] == 0) {
        [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", @"Error title for profile setup") andMessage:NSLocalizedString(@"Please enter your pets weight", @"Error message when pet weight is empty")];
    }
    
    return YES;
}

#pragma mark - IBActions
- (IBAction)continueTapped:(id)sender
{
    if ([self validateInput]) {
        [self performSegueWithIdentifier:@"setPetPhoto" sender:nil];
    }
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.nameField) {
        return [newString rangeOfCharacterFromSet:self.invalidNameCharacters options:NSCaseInsensitiveSearch].location == NSNotFound && [newString length] <= 10;
    }
    
    if (textField == self.familyField) {
        return [newString rangeOfCharacterFromSet:self.invalidFamilyNameCharacters options:NSCaseInsensitiveSearch].location == NSNotFound && [newString length] <= 35;
    }
    
    if (textField == self.ageField || textField == self.weightField) {
        return [newString rangeOfCharacterFromSet:self.invalidNumericalCharacters options:NSCaseInsensitiveSearch].location == NSNotFound;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUInteger index = [self.textFields indexOfObject:textField];
    if (index < [self.textFields count]) {
        [self.textFields[index+1] becomeFirstResponder];
    } else {
        // TODO: tap continue?
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
        self.continueButtonBottomConstraint.constant = keyboardRect.size.height;
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
        self.continueButtonBottomConstraint.constant = 0.f;
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