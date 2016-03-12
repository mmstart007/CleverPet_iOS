//
//  CPHubPlaceholderViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-10.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPHubPlaceholderDelegate <NSObject>

- (void)hubSetupCancelled;
- (void)hubSetupContinued;

@end

@interface CPHubPlaceholderViewController : UIViewController

@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) BOOL shouldConfirmCancellation;
@property (nonatomic, weak) id<CPHubPlaceholderDelegate> delegate;

- (void)displayMessage:(NSString *)message;

@end
