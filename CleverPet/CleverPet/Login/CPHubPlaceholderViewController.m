//
//  CPHubPlaceholderViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-10.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPHubPlaceholderViewController.h"
#import "CPLoadingView.h"

@interface CPHubPlaceholderViewController ()

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet CPLoadingView *fadeView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation CPHubPlaceholderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.continueButton.backgroundColor = [UIColor appLightTealColor];
    [self.continueButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.continueButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.cancelButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    self.fadeView.hidden = NO;
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.messageLabel.textColor = [UIColor appTitleTextColor];
    self.messageLabel.font = [UIFont cpLightFontWithSize:kSignInHeaderFontSize italic:NO];
    
    if (self.message) {
        [self displayMessage:self.message];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayMessage:(NSString *)message
{
    self.fadeView.hidden = YES;
    self.messageLabel.text = message;
}

#pragma mark - IBActions
- (IBAction)continueTapped:(id)sender
{
    [self.delegate hubSetupContinued];
    self.messageLabel.text = nil;
    self.fadeView.hidden = NO;
}

- (IBAction)cancelTapped:(id)sender
{
    if (self.shouldConfirmCancellation) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancelling Hub Setup", @"Alert title when user attempts to back out of hub setup") message:NSLocalizedString(@"If you do not complete Hub WiFi Setup, the Hub won't adapt to your dog or offer your dog new challenges.\n\nYou also won't be able to see how your dog is doing through the CleverPet mobile app.\n\nAre you sure you want to cancel?", @"Alert body when user attempts to back out of hub setup") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes, I want to cancel", @"Alert action message to confirm backing out of hub setup") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.delegate hubSetupCancelled];
        }];
        
        UIAlertAction *continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No, Let me try again", @"Alert action message to continue with hub setup") style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:cancelAction];
        [alert addAction:continueAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.delegate hubSetupCancelled];
    }
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
