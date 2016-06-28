//
//  CPReplDashboardViewController.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPReplDashboardViewController.h"
#import "CPLoginWithAmazon.h"

@interface CPReplDashboardViewController () <AIAuthenticationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *accountIdLabel;

- (IBAction)signoutButtonTapped:(id)sender;

@end

@implementation CPReplDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AIMobileLib getProfile:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions
- (IBAction)signoutButtonTapped:(id)sender {
    [AIMobileLib clearAuthorizationState:self];
}

#pragma mark - Amazon Authentication Delegate
- (void)requestDidSucceed:(APIResult *)apiResult
{
    if (apiResult.api == kAPIClearAuthorizationState) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(replenishDashboardDidSignout)])
        {
            [self.delegate replenishDashboardDidSignout];
        }
    } else if (apiResult.api == kAPIGetProfile) {
        self.accountIdLabel.text = [NSString stringWithFormat:@"You logged in as\n%@", apiResult.result[@"name"]];
    }
}

- (void)requestDidFail:(APIError *)errorResponse
{
    if (errorResponse.api == kAPIClearAuthorizationState) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:[NSString stringWithFormat:@"User Logout failed with message: %@", errorResponse.error.message]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (errorResponse.api == kAPIGetProfile) {
        if(errorResponse.error.code == kAIApplicationNotAuthorized) {
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(replenishDashboardUserNotAuthorized)])
            {
                [self.delegate replenishDashboardUserNotAuthorized];
            }
        }
        else {
            self.accountIdLabel.text = [NSString stringWithFormat:@"Error occurred with message: %@", errorResponse.error.message];
        }
    }
}

@end
