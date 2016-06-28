//
//  CPReplDashboardViewController.h
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPBaseViewController.h"

@protocol CPReplenishDashboardDelegate <NSObject>

@required
- (void)replenishDashboardUserNotAuthorized;
- (void)replenishDashboardDidSignout;

@end

@interface CPReplDashboardViewController : CPBaseViewController

@property (weak) id<CPReplenishDashboardDelegate> delegate;

@end
