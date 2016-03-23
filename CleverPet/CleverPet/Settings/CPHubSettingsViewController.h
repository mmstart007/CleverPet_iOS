//
//  CPHubSettingsViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPHubStatusManager.h"

@interface CPHubSettingsViewController : UIViewController

@property (nonatomic, assign) HubConnectionState connectionState;

@end
