//
//  CPHubSettingsViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HubConnectionState) {HubConnectionState_Connected, HubConnectionState_Disconnected, HubConnectionState_Offline, HubConnectionState_Unknown};

@interface CPHubSettingsViewController : UIViewController

@property (nonatomic, assign) HubConnectionState connectionState;

@end
