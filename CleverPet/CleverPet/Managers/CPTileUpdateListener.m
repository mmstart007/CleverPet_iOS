//
//  CPTileUpdateListener.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-11.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileUpdateListener.h"
#import "CPFirebaseManager.h"

@implementation CPTileUpdateListener

+ (instancetype)tileUpdateListenerWithDelegate:(id<CPTileUpdateDelegate>)delegate
{
    CPTileUpdateListener *listener = [[CPTileUpdateListener alloc] init];
    listener.delegate = delegate;
    return listener;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        BLOCK_SELF_REF_OUTSIDE();
        [[CPFirebaseManager sharedInstance] listenForTileUpdatesWithBlock:^(NSError *error, NSDictionary *tileValue) {
            BLOCK_SELF_REF_INSIDE();
            [self.delegate queueTileUpdate];
        }];
    }
    return self;
}

- (void)dealloc
{
    [[CPFirebaseManager sharedInstance] stopListeningForTileUpdates];
}

@end
