//
//  CPHubStatusManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HubConnectionState) {HubConnectionState_Connected, HubConnectionState_Disconnected, HubConnectionState_Offline, HubConnectionState_Unknown};

typedef void (^CPHubStatusUpdateBlock)(HubConnectionState status);
typedef NSNumber *CPHubStatusHandle;

@interface CPHubStatusManager : NSObject

+ (instancetype)sharedInstance;

- (CPHubStatusHandle)registerForHubStatusUpdates:(CPHubStatusUpdateBlock)updateBlock;
- (void)unregisterForHubStatusUpdates:(CPHubStatusHandle)handle;

@end
