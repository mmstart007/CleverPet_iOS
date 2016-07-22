//
//  CPReplenishDashViewController.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPReplenishDashViewController.h"
#import "CPReplenishDashUtil.h"

@interface CPReplenishDashViewController () <AIAuthenticationDelegate>

@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UILabel *lblAmountConsumed;
@property (strong, nonatomic) IBOutlet UILabel *lblReorder;
@property (strong, nonatomic) IBOutlet UILabel *lblPerReorder;
@property (strong, nonatomic) IBOutlet UILabel *lblLastDelivery;
@property (strong, nonatomic) IBOutlet UILabel *lblNextReorder;
@property (strong, nonatomic) IBOutlet UILabel *lblCups;


- (IBAction)replenishButtonTapped:(id)sender;

@end

@implementation CPReplenishDashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _progress.transform = CGAffineTransformScale(_progress.transform, 1, 10);
    _progress.clipsToBounds = YES;
    
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

- (IBAction)replenishButtonTapped:(id)sender {
    
}

- (IBAction)signoutButtonTapped:(id)sender {
    [AIMobileLib clearAuthorizationState:self];
}

#pragma mark - Amazon Authentication Delegate
- (void)requestDidSucceed:(APIResult *)apiResult
{
    if (apiResult.api == kAPIClearAuthorizationState) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(replenishDashDidSignout)])
        {
            [self.delegate replenishDashDidSignout];
        }
    } else if (apiResult.api == kAPIGetProfile) {
        NSLog(@"%@", apiResult.result);
//        self.accountIdLabel.text = [NSString stringWithFormat:@"You logged in as\n%@", apiResult.result[@"user_id"]];
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
                [self.delegate respondsToSelector:@selector(replenishDashUserNotAuthorized)])
            {
                [self.delegate replenishDashUserNotAuthorized];
            }
        }
        else {
//            self.accountIdLabel.text = [NSString stringWithFormat:@"Error occurred with message: %@", errorResponse.error.message];
        }
    }
}


@end
