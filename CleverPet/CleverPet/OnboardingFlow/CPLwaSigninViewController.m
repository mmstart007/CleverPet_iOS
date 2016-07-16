//
//  CPLwaSigninViewController.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPLwaSigninViewController.h"
#import "CPReplenishDashUtil.h"
#import "CPAmazonAPI.h"

@interface CPLwaSigninViewController () <AIAuthenticationDelegate>
{
    CPAmazonAPI *requestManager;
}

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
    [AIMobileLib authorizeUserForScopes:[CPReplenishDashUtil appRequestScopes] delegate:self options:[CPReplenishDashUtil appRequestScopeOptions]];
}

#pragma mark - Amazon Authentication Delegate
- (void)requestDidSucceed:(APIResult *)apiResult
{
    NSString *authCode = apiResult.result;

    NSLog(@"Auth Code -> %@ \n ClientID -> %@ \n RedirctURI -> %@", apiResult.result, [AIMobileLib getClientId], [AIMobileLib getRedirectUri]);
    
    [[CPAmazonAPI manager] sendAuthCode : authCode
                      grant_type : @"authorization_code"
                        clientId : [AIMobileLib getClientId]
                    redirect_uri : [AIMobileLib getRedirectUri]
                         success : ^(NSDictionary *result) {
                                NSLog(@"success getting device token!");
                         } failure : ^(NSError *error) {
                             NSLog(@"failed getting device token!");
                        }];

/*    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(loginWithAmazonDidSuccess)])
    {
        [self.delegate loginWithAmazonDidSuccess];
    }
 */
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
