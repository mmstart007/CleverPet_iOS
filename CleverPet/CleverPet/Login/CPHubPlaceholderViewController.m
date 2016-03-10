//
//  CPHubPlaceholderViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-10.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPHubPlaceholderViewController.h"
#import "CPLoadingView.h"
#import "CPLoginController.h"

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
    [[CPLoginController sharedInstance] continueDeviceSetup];
    self.messageLabel.text = nil;
    self.fadeView.hidden = NO;
}

- (IBAction)cancelTapped:(id)sender
{
    [[CPLoginController sharedInstance] cancelDeviceSetup];
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
