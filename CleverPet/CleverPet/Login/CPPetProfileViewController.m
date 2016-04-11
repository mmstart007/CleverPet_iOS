//
//  CPPetProfileViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPetProfileViewController.h"
#import "CPTextField.h"
#import "CPPickerViewController.h"
#import "CPBreedPickerViewController.h"
#import "CPLoginController.h"
#import "CPTextValidator.h"
#import "CPPet.h"
#import "CPUserManager.h"

@interface CPPetProfileViewController ()<UITextFieldDelegate, CPPickerViewDelegate, CPBreedPickerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet CPTextField *nameField;
@property (weak, nonatomic) IBOutlet CPTextField *familyField;
@property (weak, nonatomic) IBOutlet CPTextField *breedField;
@property (weak, nonatomic) IBOutlet CPTextField *genderField;
@property (weak, nonatomic) IBOutlet CPTextField *ageField;
@property (weak, nonatomic) IBOutlet CPTextField *weightField;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weightUnitSelector;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) NSArray *textFields;

@property (nonatomic, strong) NSString *weightDescriptor;
@property (nonatomic, strong) CPPickerViewController *genderPicker;
@property (nonatomic, strong) CPTextValidator *textValidator;
// TODO: pull this out somewhere
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL shouldUpdateNavBar;

@end

@implementation CPPetProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // TODO: switch for weight units, gender, auto complete for breeds, potentially switch for altered
    [self setupStyling];
    self.textFields = @[self.nameField, self.familyField, self.breedField, self.genderField, self.ageField, self.weightField];
    
    self.weightDescriptor = [[self.weightUnitSelector titleForSegmentAtIndex:self.weightUnitSelector.selectedSegmentIndex] lowercaseString];
    
    self.weightUnitSelector.tintColor = [UIColor appTextFieldPlaceholderColor];
    [self.weightUnitSelector setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor appTitleTextColor], NSFontAttributeName:[UIFont cpLightFontWithSize:16.f italic:NO]} forState:UIControlStateNormal];
    [self.weightUnitSelector setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor appTitleTextColor], NSFontAttributeName:[UIFont cpLightFontWithSize:16.f italic:NO]} forState:UIControlStateNormal];
    self.textValidator = [[CPTextValidator alloc] init];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"Y-M-d";
    self.dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    REG_SELF_FOR_NOTIFICATION(UIKeyboardWillShowNotification, keyboardWillShow:);
    REG_SELF_FOR_NOTIFICATION(UIKeyboardWillHideNotification, keyboardWillHide:);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    if (self.shouldUpdateNavBar) {
        self.shouldUpdateNavBar = NO;
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
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
    self.headerLabel.textColor = [UIColor appTitleTextColor];
    self.continueButton.backgroundColor = [UIColor appLightTealColor];
    self.continueButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.continueButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
}

- (void)moveToNextTextFieldFrom:(UITextField*)textField
{
    NSUInteger index = [self.textFields indexOfObject:textField];
    if (index+1 < [self.textFields count]) {
        [self.textFields[index+1] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self continueTapped:nil];
    }
}

#pragma mark - IBActions
- (IBAction)continueTapped:(id)sender
{
    // Validate pet age
    NSInteger ageValue = [self.ageField.text integerValue];
    if (ageValue < kMinAge || ageValue > kMaxAge) {
        [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", @"Error title for profile setup") andMessage:[NSString stringWithFormat:NSLocalizedString(@"Age must be between %d and %d", @"Error message when pet age is invalid. First %d is minimum age, second %d is maximum age"), kMinAge, kMaxAge]];
        return;
    }
    
    //Convert wieght to lbs to be saved on the server
    NSString *weight = [self.weightField.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@", self.weightDescriptor] withString:@""];
    
    NSString *weightUnit =  [self.weightDescriptor stringByReplacingOccurrencesOfString:@"s" withString:@""];
    [[CPUserManager sharedInstance] getCurrentUser].weightUnits = weightUnit;
    if ([weightUnit isEqualToString:@"kg"]) {
        CGFloat convertedWeight = [weight floatValue]*kLbsToKgs;
        weight = [NSString stringWithFormat:@"%.1f", convertedWeight];
    }
    
    NSDictionary *petInfo = @{kNameKey:self.nameField.text, kFamilyNameKey:self.familyField.text, kGenderKey:[self.genderField.text lowercaseString], kBreedKey:self.breedField.text, kWeightKey:weight, kDOBKey:[self getDOB], kWeightUnits : weightUnit};
    [CPPet validateInput:petInfo isInitialSetup:YES completion:^(BOOL isValidInput, NSString *errorMessage) {
        
        if (isValidInput) {
            [[CPLoginController sharedInstance] setPendingUserInfo:petInfo];
            self.shouldUpdateNavBar = YES;
            [self performSegueWithIdentifier:@"setPetPhoto" sender:nil];
        } else {
            [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", @"Error title for profile setup") andMessage:errorMessage];
        }
    }];
}

- (IBAction)weightSwitchValueChanged:(id)sender
{
    NSString *newDescriptor = [[self.weightUnitSelector titleForSegmentAtIndex:self.weightUnitSelector.selectedSegmentIndex] lowercaseString];
    self.weightField.text = [self.weightField.text stringByReplacingOccurrencesOfString:self.weightDescriptor withString:newDescriptor];
    self.weightDescriptor = newDescriptor;
}

- (IBAction)cancelTapped:(id)sender
{
    self.shouldUpdateNavBar = YES;
    [[CPLoginController sharedInstance] cancelPetProfileCreation];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.nameField) {
        return [self.textValidator isValidPetNameText:newString];
    }
    
    if (textField == self.familyField) {
        return [self.textValidator isValidFamilyNameText:newString];
    }
    
    if (textField == self.weightField) {
        return [self.textValidator isValidPetWeightText:newString];
    }
    
    if (textField == self.ageField) {
        return [self.textValidator isValidPetAgeText:newString];
    }
    
    // Disable typing for gender/breed fields
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self moveToNextTextFieldFrom:textField];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.genderField) {
        if (!self.genderPicker) {
            UIStoryboard *pickerStoryboard = [UIStoryboard storyboardWithName:@"Pickers" bundle:nil];
            CPPickerViewController *genderPicker = [pickerStoryboard instantiateViewControllerWithIdentifier:@"Picker"];
            [genderPicker setupForPickingGender];
            // Update the picker height, allowing it to take up at most half the screen(we shouldn't ever have to be larger than the table content size with the current number of rows)
            [genderPicker updateHeightWithMaximum:self.view.bounds.size.height*.5f];
            genderPicker.delegate = self;
            textField.inputView = genderPicker.view;
            self.genderPicker = genderPicker;
        }
    } else if (textField == self.breedField) {
        UIStoryboard *pickerStoryboard = [UIStoryboard storyboardWithName:@"Pickers" bundle:nil];
        CPBreedPickerViewController *vc = [pickerStoryboard instantiateViewControllerWithIdentifier:@"BreedPicker"];
        vc.delegate = self;
        vc.selectedBreed = self.breedField.text;
        [self presentViewController:vc animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.weightField) {
        self.weightField.text = [self.weightField.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@", self.weightDescriptor] withString:@""];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.weightField) {
        self.weightField.text = [NSString stringWithFormat:@"%@ %@", self.weightField.text, self.weightDescriptor];
    }
}

- (NSString*)getDOB
{
    if ([self.ageField.text length] > 0) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
        componentsToAdd.year = -[self.ageField.text integerValue];
        
        return [self.dateFormatter stringFromDate:[calendar dateByAddingComponents:componentsToAdd toDate:[NSDate date] options:kNilOptions]];
    }
    return @"";
}

#pragma mark - CPPickerDelegate methods
- (void)pickerViewController:(CPPickerViewController *)controller selectedString:(NSString *)string
{
    if (controller == self.genderPicker) {
        self.genderField.text = string;
        [self moveToNextTextFieldFrom:self.genderField];
    }
}

#pragma mark - CPBreedPickerDelegate methods
- (void)selectedBreed:(NSString *)breedName
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.breedField.text = breedName;
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