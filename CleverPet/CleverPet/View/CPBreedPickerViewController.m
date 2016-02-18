//
//  CPBreedPickerViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-17.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPBreedPickerViewController.h"
#import "CHCSVParser.h"
#import "CPTextField.h"
#import "CPSimpleTableViewCell.h"

@interface CPBreedPickerViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *breedsArray;
@property (nonatomic, strong) NSMutableArray *filteredBreeds;

@property (weak, nonatomic) IBOutlet CPTextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CPBreedPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *breedsArray = [NSArray arrayWithContentsOfCSVURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"breeds" ofType:@".csv"]]];
    // Flatten out the array(parser returns an array of arrays of strings)
    self.breedsArray = [breedsArray valueForKeyPath:@"@unionOfArrays.self"];
    self.textField.text = self.selectedBreed;
    [self filterBreedsByString:self.selectedBreed];
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"CPSimpleTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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

- (void)filterBreedsByString:(NSString*)string
{
    // TODO: Just going with a basic string search for now, there aren't any drop in fuzzy search solutions that I could find, so we can circle back later if we have time
//    NSMutableString *wildcardString = [@"*" mutableCopy];
//    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
//        [wildcardString appendFormat:@"%@*", substring];
//    }];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@", wildcardString];
    
    
    if ([string length] > 0) {
        self.filteredBreeds = [[self.breedsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", string]] mutableCopy];
    } else {
        self.filteredBreeds = [self.breedsArray mutableCopy];
    }
    // Ensure we always have Mixed Breed as an option
    NSString *mixed = NSLocalizedString(@"Mixed Breed", @"Default option for breed selector");
    // Naive, but lets assume we want it at the top instead of somewhere in the array
    if (![[self.filteredBreeds firstObject] isEqualToString:mixed]) {
        [self.filteredBreeds insertObject:mixed atIndex:0];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredBreeds count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPSimpleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setupWithString:self.filteredBreeds[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textField resignFirstResponder];
    [self.delegate selectedBreed:self.filteredBreeds[indexPath.row]];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self filterBreedsByString:newString];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self filterBreedsByString:nil];
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
    
    // TODO: If the view controller gets more complicated, this will need to be updated
    UIEdgeInsets tableInset = UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0);
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [UIView setAnimationCurve:curve];
        self.tableView.contentInset = tableInset;
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
        self.tableView.contentInset = UIEdgeInsetsZero;
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
