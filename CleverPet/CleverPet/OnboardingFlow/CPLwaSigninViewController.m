//
//  CPLwaSigninViewController.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPLwaSigninViewController.h"
#import "CPLoginWithAmazon.h"

@interface CPLwaSigninViewController () <AIAuthenticationDelegate>

- (IBAction)signinButtonTapped:(id)sender;

@end

@implementation CPLwaSigninViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)signinButtonTapped:(id)sender {
    [AIMobileLib authorizeUserForScopes:[CPLoginWithAmazon appRequestScopes] delegate:self];
}

#pragma mark - Amazon Authentication Delegate
- (void)requestDidSucceed:(APIResult *)apiResult
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(loginWithAmazonDidSuccess)])
    {
        [self.delegate loginWithAmazonDidSuccess];
    }
}

- (void)requestDidFail:(APIError *)errorResponse
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:[NSString stringWithFormat:@"User authorization failed with message: %@", errorResponse.error.message]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
