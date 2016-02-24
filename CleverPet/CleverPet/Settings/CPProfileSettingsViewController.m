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

@interface CPProfileSettingsViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *petImage;
@property (weak, nonatomic) IBOutlet UIButton *editImageButton;

@property (weak, nonatomic) IBOutlet CPTextField *nameField;
@property (weak, nonatomic) IBOutlet CPTextField *familyNameField;
@property (weak, nonatomic) IBOutlet CPTextField *breedField;
@property (weak, nonatomic) IBOutlet CPTextField *weightField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weightUnitSelector;
@property (weak, nonatomic) IBOutlet CPTextField *genderField;
@property (weak, nonatomic) IBOutlet CPTextField *neuteredField;

@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoutX;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *headerViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *headerLabels;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *sectionViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sectionTitles;

@property (nonatomic, strong) NSString *weightDescriptor;
@property (nonatomic, strong) NSArray *textFields;
@property (nonatomic, strong) CPTextValidator *textValidator;

@end

@implementation CPProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textFields = @[self.nameField, self.familyNameField, self.breedField, self.weightField, self.genderField, self.neuteredField];
    self.weightDescriptor = [[self.weightUnitSelector titleForSegmentAtIndex:self.weightUnitSelector.selectedSegmentIndex] lowercaseString];
    self.textValidator = [[CPTextValidator alloc] init];
    
    [self setupStyling];
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
    self.logoutX.textColor = [UIColor redColor];
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

#pragma mark - UITextFieldDelegate methods
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
