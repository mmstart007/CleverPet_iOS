//
//  CPHubPlaceholderViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-10.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPHubPlaceholderViewController : UIViewController

@property (nonatomic, strong) NSString *message;
- (void)displayMessage:(NSString *)message;

@end
