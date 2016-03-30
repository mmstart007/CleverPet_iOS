//
//  CPHubStatusManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPHubStatusManager.h"
#import "CPAppEngineCommunicationManager.h"
#import "CPUserManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface CPHubStatusManager()

@property (nonatomic, strong) NSMutableDictionary *registeredBlocks;
@property (nonatomic, assign) NSUInteger handleCount;
@property (nonatomic, strong) NSTimer *requestTimer;
@property (nonatomic, assign) BOOL requestInProgress;
@property (nonatomic, assign) HubConnectionState lastKnownState;
@property (nonatomic, assign) AFNetworkReachabilityStatus lastConnectionStatus;

@end

NSInteger const kLastSeenThreshhold = 120;
NSTimeInterval const kHubStatusUpdateInterval = 60;

@implementation CPHubStatusManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPHubStatusManager *s_sharedInstance;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[CPHubStatusManager alloc] init];
    });
    return s_sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.registeredBlocks = [NSMutableDictionary dictionary];
        self.lastKnownState = HubConnectionState_Unknown;
        self.lastConnectionStatus = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
        REG_SELF_FOR_NOTIFICATION(AFNetworkingReachabilityDidChangeNotification, reachabilityChanged:);
    }
    return self;
}

- (void)dealloc
{
    UNREG_SELF_FOR_ALL_NOTIFICATIONS();
}

- (CPHubStatusHandle)registerForHubStatusUpdates:(CPHubStatusUpdateBlock)updateBlock
{
    CPHubStatusHandle handle = @(self.handleCount);
    self.handleCount++;
    
    self.registeredBlocks[handle] = [updateBlock copy];
    // Immediately call the block with our last known state
    updateBlock(self.lastKnownState);
    [self beginPollingHubStatus];
    
    return handle;
}

- (void)unregisterForHubStatusUpdates:(CPHubStatusHandle)handle
{
    self.registeredBlocks[handle] = nil;
    [self endPollingHubStatus];
}

- (void)beginPollingHubStatus
{
    if (!self.requestInProgress) {
        // If we don't have the polling timer running, make a request. If the timer is running, we don't need to do anything
        if (!self.requestTimer) {
            [self requestHubStatus];
        }
    }
}

- (void)endPollingHubStatus
{
    // Only kill polling if we have no more observers
    if ([[self.registeredBlocks allKeys] count] == 0) {
        // Reset to Unknown state
        self.lastKnownState = HubConnectionState_Unknown;
        [self.requestTimer invalidate];
        self.requestTimer = nil;
    }
}

- (ASYNC)requestHubStatus
{
    if (!self.requestInProgress) {
        self.requestInProgress = YES;
        [self.requestTimer invalidate];
        self.requestTimer = nil;
        
        BLOCK_SELF_REF_OUTSIDE();
        [[CPAppEngineCommunicationManager sharedInstance] checkDeviceLastSeen:[[CPUserManager sharedInstance] getCurrentUser].device.deviceId completion:^(NSInteger delta, NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            self.requestInProgress = NO;
            if (error && [error isOfflineError]) {
                self.lastKnownState = HubConnectionState_Offline;
            } else if (error || delta == NSNotFound || delta > kLastSeenThreshhold) {
                self.lastKnownState = HubConnectionState_Disconnected;
            } else {
                self.lastKnownState = HubConnectionState_Connected;
            }
            
            [self notifyOfStatusChange];
            [self startRequestTimer];
        }];
    }
}

- (void)startRequestTimer
{
    if ([[self.registeredBlocks allKeys] count] > 0 && !self.requestInProgress && !self.requestTimer && self.lastConnectionStatus != AFNetworkReachabilityStatusNotReachable) {
        self.requestTimer = [NSTimer scheduledTimerWithTimeInterval:kHubStatusUpdateInterval target:self selector:@selector(requestHubStatus) userInfo:nil repeats:NO];
    }
}

- (void)stopRequestTimer
{
    [self.requestTimer invalidate];
    self.requestTimer = nil;
}

- (void)notifyOfStatusChange
{
    for (CPHubStatusHandle handle in [self.registeredBlocks allKeys]) {
        CPHubStatusUpdateBlock block = self.registeredBlocks[handle];
        block(self.lastKnownState);
    }
}

#pragma mark - Reachability notification
- (void)reachabilityChanged:(NSNotification*)notification
{
    AFNetworkReachabilityStatus status = [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    
    // If we have no observers, skip status update
    if ([[self.registeredBlocks allKeys] count] > 0) {
        if ((status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) && status != self.lastConnectionStatus) {
            // Don't need to trigger a reload unless we were previously unreachable
            if (self.lastConnectionStatus == AFNetworkReachabilityStatusNotReachable) {
                [self requestHubStatus];
            } else {
                [self startRequestTimer];
            }
        } else if (status == AFNetworkReachabilityStatusNotReachable) {
            // If we went unreachable, cancel our timer and immediately inform our observers
            [self stopRequestTimer];
            self.lastKnownState = HubConnectionState_Offline;
            [self notifyOfStatusChange];
        }
    }
    
    self.lastConnectionStatus = status;
}

@end
