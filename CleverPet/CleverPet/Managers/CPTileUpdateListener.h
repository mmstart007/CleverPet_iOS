//
//  CPTileUpdateListener.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-11.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPTileUpdateDelegate <NSObject>

- (void)queueTileUpdate;

@end

@interface CPTileUpdateListener : NSObject

+ (instancetype)tileUpdateListenerWithDelegate:(id<CPTileUpdateDelegate>)delegate;

@property (nonatomic, weak) id<CPTileUpdateDelegate> delegate;

@end
