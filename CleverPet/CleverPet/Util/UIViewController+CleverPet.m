//
//  UIViewController+CleverPet.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-17.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "UIViewController+CleverPet.h"

@implementation UIViewController(CleverPet)

- (void)displayErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
