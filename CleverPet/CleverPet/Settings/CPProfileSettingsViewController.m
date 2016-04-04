//
//  CPProfileSettingsViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPProfileSettingsViewController.h"
#import "CPTextField.h"
#import "CPTextValidator.h"
#import "CPPickerViewController.h"
#import "CPBreedPickerViewController.h"
#import "CPPetPhotoViewController.h"
#import "CPUserManager.h"
#import "CPGenderUtils.h"
#import "CPLoadingView.h"

@interface CPProfileSettingsViewController ()<UITextFieldDelegate, CPPickerViewDelegate, CPBreedPickerDelegate, CPPetPhotoDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet UIImageView *petImage;
@property (weak, nonatomic) IBOutlet UIButton *editImageButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@property (weak, nonatomic) IBOutlet CPTextField *nameField;
@property (weak, nonatomic) IBOutlet CPTextField *familyNameField;
@property (weak, nonatomic) IBOutlet CPTextField *breedField;
@property (weak, nonatomic) IBOutlet CPTextField *weightField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weightUnitSelector;
@property (weak, nonatomic) IBOutlet CPTextField *genderField;
@property (weak, nonatomic) IBOutlet UILabel *alteredHeader;
@property (weak, nonatomic) IBOutlet CPTextField *neuteredField;

@property (weak, nonatomic) IBOutlet UIView *logoutContainer;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *headerViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *headerLabels;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *sectionViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sectionTitles;

@property (nonatomic, strong) NSString *weightDescriptor;
@property (nonatomic, strong) NSArray *textFields;
@property (nonatomic, strong) CPTextValidator *textValidator;

@property (nonatomic, strong) CPPickerViewController *genderPicker;
@property (nonatomic, strong) CPPickerViewController *neuteredPicker;
@property (nonatomic, strong) CPBreedPickerViewController *breedPicker;

@property (nonatomic, strong) CPPet *pet;
@property (nonatomic, weak) UIBarButtonItem *pseudoBackButton;
@property (nonatomic, weak) UIBarButtonItem *saveButton;
@property (nonatomic, weak) UITapGestureRecognizer *logoutRecognizer;
@property (weak, nonatomic) IBOutlet CPLoadingView *loadingView;

@end

@implementation CPProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // TODO: populate fields from pet profile object
    
    self.textFields = @[self.nameField, self.familyNameField, self.breedField, self.weightField, self.genderField, self.neuteredField];

    self.textValidator = [[CPTextValidator alloc] init];
    
    self.pet = [[CPUserManager sharedInstance] getCurrentUser].pet;
    self.petImage.image = [self.pet petPhoto];
    
    if ([self.pet.weightUnits isEqualToString:@"kg"]) {
        [self.weightUnitSelector setSelectedSegmentIndex:1];
    }
    
    self.weightDescriptor = [[self.weightUnitSelector titleForSegmentAtIndex:self.weightUnitSelector.selectedSegmentIndex] lowercaseString];
    
    self.nameField.text = self.pet.name;
    self.familyNameField.text = self.pet.familyName;
    self.breedField.text = self.pet.breed;
    self.weightField.text = [NSString stringWithFormat:@"%ld %@", (long)self.pet.weight, self.weightDescriptor];
    // Uppercase first letter of word, since it's all lower case coming from the server
    self.genderField.text = [self.pet.gender stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self.pet.gender substringToIndex:1] uppercaseString]];
    self.neuteredField.text = [CPGenderUtils stringForAlteredState:self.pet.altered withGender:self.pet.gender];
    
    [self updateAlteredHeaderForGender:self.pet.gender];
    [self setupStyling];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont cpLightFontWithSize:12 italic:NO]];
    [button setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor appTealColor]];
    button.frame = CGRectMake(0, 0, 50, 40);
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barButton;
    self.pseudoBackButton = barButton;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Save" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont cpLightFontWithSize:12 italic:NO]];
    [button setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor appTealColor]];
    [button sizeToFit];
    barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = barButton;
    self.saveButton = barButton;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutTapped:)];
    [self.logoutContainer addGestureRecognizer:recognizer];
    self.logoutRecognizer = recognizer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Mess with our title so we get the appropriate back button
    self.title = @"Profile";
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
}

- (void)setupStyling
{
    self.view.backgroundColor = [UIColor appBackgroundColor];
    [self.headerViews makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor appBackgroundColor]];
    [self.headerLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO]];
    [self.headerLabels makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor appTitleTextColor]];
    [self.sectionViews makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor appWhiteColor]];
    [self.sectionTitles makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont cpLightFontWithSize:12 italic:NO]];
    [self.sectionTitles makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor appSubCopyTextColor]];
    
    // TODO: background as an image if to get selected state
    self.editImageButton.backgroundColor = [UIColor appTealColor];
    self.editImageButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.editImageButton setTitleColor:[UIColor appWhiteColor] forState:UIControlStateNormal];
    
    self.weightUnitSelector.tintColor = [UIColor appTextFieldPlaceholderColor];
    [self.weightUnitSelector setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor appTitleTextColor], NSFontAttributeName:[UIFont cpLightFontWithSize:16.f italic:NO]} forState:UIControlStateNormal];
    [self.weightUnitSelector setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor appTitleTextColor], NSFontAttributeName:[UIFont cpLightFontWithSize:16.f italic:NO]} forState:UIControlStateNormal];
    
    // TODO: x as button/image
    self.logoutLabel.font = [UIFont cpLightFontWithSize:14 italic:NO];
    self.logoutLabel.textColor = [UIColor appRedColor];
}

- (void)updateAlteredHeaderForGender:(NSString*)gender
{
    self.alteredHeader.text = [CPGenderUtils alteredFieldHeaderForGender:gender];
}

- (void)moveToNextTextFieldFrom:(UITextField*)textField
{
    NSUInteger index = [self.textFields indexOfObject:textField];
    if (index+1 < [self.textFields count]) {
        [self.textFields[index+1] becomeFirstResponder];
    } else {
        // TODO: tap continue?
        [textField resignFirstResponder];
    }
}

#pragma mark - IBActions
- (IBAction)editImageTapped:(id)sender
{
    
}

- (IBAction)weightSwitchValueChanged:(id)sender
{
    NSString *newDescriptor = [[self.weightUnitSelector titleForSegmentAtIndex:self.weightUnitSelector.selectedSegmentIndex] lowercaseString];
    self.weightField.text = [self.weightField.text stringByReplacingOccurrencesOfString:self.weightDescriptor withString:newDescriptor];
    self.weightDescriptor = newDescriptor;
}

- (void)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    NSString *alteredString = [CPGenderUtils genderNeutralStringForAlteredState:self.neuteredField.text];
    if ([alteredString length] == 0) {
        alteredString = kGenderNeutralUnspecified;
    }
    NSDictionary *petInfo = @{kNameKey:self.nameField.text, kFamilyNameKey:self.familyNameField.text, kGenderKey:[self.genderField.text lowercaseString], kBreedKey:self.breedField.text, kWeightKey:[self.weightField.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@", self.weightDescriptor] withString:@""], kAlteredKey:alteredString, kWeightUnits : [self.weightDescriptor stringByReplacingOccurrencesOfString:@"s" withString:@""]};
    [CPPet validateInput:petInfo isInitialSetup:NO completion:^(BOOL isValidInput, NSString *errorMessage) {
        if (isValidInput) {
            if ([[CPUserManager sharedInstance] hasPetInfoChanged:petInfo]) {
                
                [self showLoading:YES];
                BLOCK_SELF_REF_OUTSIDE();
                [[CPUserManager sharedInstance] updatePetInfo:petInfo withCompletion:^(NSError *error) {
                    BLOCK_SELF_REF_INSIDE();
                    [self showLoading:NO];
                    if (error) {
                        // Verify we even have a network connection before this nonsense
                        if ([error isOfflineError]) {
                            [self displayErrorAlertWithTitle:ERROR_TEXT andMessage:OFFLINE_TEXT];
                        } else {
                            [self displayErrorAlertWithTitle:ERROR_TEXT andMessage:error.localizedDescription];
                        }
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [self displayErrorAlertWithTitle:NSLocalizedString(@"Invalid Input", nil) andMessage:errorMessage];
        }
    }];
}

- (void)logoutTapped:(UITapGestureRecognizer*)recognizer
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Are you sure you want to sign out?", @"Confirmation message displayed to user when logging out") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL_TEXT style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sign Out", @"Logout confirmation button text") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[CPUserManager sharedInstance] logout];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:logoutAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showLoading:(BOOL)loading
{
    self.loadingView.hidden = !loading;
    self.pseudoBackButton.enabled = !loading;
    self.saveButton.enabled = !loading;
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.weightField) {
        self.weightField.text = [self.weightField.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@", self.weightDescriptor] withString:@""];
    } else if (textField == self.genderField) {
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
    } else if (textField == self.neuteredField) {
        if (!self.neuteredPicker) {
            UIStoryboard *pickerStoryboard = [UIStoryboard storyboardWithName:@"Pickers" bundle:nil];
            CPPickerViewController *neuteredPicker = [pickerStoryboard instantiateViewControllerWithIdentifier:@"Picker"];
            [neuteredPicker setupForPickingNeuteredWithGender:[self.genderField.text lowercaseString]];
            // Update the picker height, allowing it to take up at most half the screen(we shouldn't ever have to be larger than the table content size with the current number of rows)
            [neuteredPicker updateHeightWithMaximum:self.view.bounds.size.height*.5f];
            neuteredPicker.delegate = self;
            textField.inputView = neuteredPicker.view;
            self.neuteredPicker = neuteredPicker;
        }
    } else if (textField == self.breedField) {
        UIStoryboard *pickerStoryboard = [UIStoryboard storyboardWithName:@"Pickers" bundle:nil];
        CPBreedPickerViewController *vc = [pickerStoryboard instantiateViewControllerWithIdentifier:@"BreedPicker"];
        vc.delegate = self;
        vc.selectedBreed = self.breedField.text;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.weightField) {
        self.weightField.text = [NSString stringWithFormat:@"%@ %@", self.weightField.text, self.weightDescriptor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self moveToNextTextFieldFrom:textField];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.nameField) {
        return [self.textValidator isValidPetNameText:newString];
    }
    
    if (textField == self.familyNameField) {
        return [self.textValidator isValidFamilyNameText:newString];
    }
    
    if (textField == self.weightField) {
        return [self.textValidator isValidPetWeightText:newString];
    }
    
    // Disable typing for gender/breed fields
    return NO;
}

#pragma mark - CPPickerDelegate methods
- (void)pickerViewController:(CPPickerViewController *)controller selectedString:(NSString *)string
{
    if (controller == self.genderPicker) {
        if (![string isEqualToString:self.genderField.text]) {
            [self updateAlteredHeaderForGender:string];
            self.neuteredField.text = [CPGenderUtils stringForAlteredState:[CPGenderUtils genderNeutralStringForAlteredState:self.neuteredField.text] withGender:string];
            // Need to rebuild this picker with the appropriate terminology
            self.neuteredPicker = nil;
        }
        self.genderField.text = string;
        [self.genderField resignFirstResponder];
    } else if (controller == self.neuteredPicker) {
        self.neuteredField.text = string;
        [self.neuteredField resignFirstResponder];
    }
}

#pragma mark - CPBreedPickerDelegate methods
- (void)selectedBreed:(NSString *)breedName
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.breedField.text = breedName;
}

#pragma mark - CPPetPhotoDelegate methods
- (void)selectedImage:(UIImage *)image
{
    [[CPUserManager sharedInstance] updatePetPhoto:image];
    self.petImage.image = [self.pet petPhoto];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CPPetPhotoViewController class]])
    {
        self.title = CANCEL_TEXT;
        CPPetPhotoViewController *photoPicker = segue.destinationViewController;
        photoPicker.delegate = self;
        photoPicker.selectedImage = [self.pet petPhotoForPicker];
    }
}

#pragma mark - Scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top);
    self.imageContainer.clipsToBounds = offsetY <= 0;
    
    CGFloat topConstant = MAX(offsetY + scrollView.contentInset.top, scrollView.contentInset.top);
    if (self.imageHeightConstraint.constant != topConstant) {
        self.imageHeightConstraint.constant = topConstant;
    }
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
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0);
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
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self.view layoutIfNeeded];
    } completion:nil];
}

@end
