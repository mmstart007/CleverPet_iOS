//
//  CPReplenishDashViewController.h
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPBaseViewController.h"

@protocol CPReplenishDashDelegate <NSObject>

@required
- (void)replenishDashUserNotAuthorized;
- (void)replenishDashDidSignout;

@end

@interface CPReplenishDashViewController : CPBaseViewController

@property (weak) id<CPReplenishDashDelegate> delegate;

@end
