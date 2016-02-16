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

@interface CPNascarViewController ()<UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet CPTextField *emailField;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
    [[CPLoginController sharedInstance] signInWithEmail:self.emailField.text];
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
