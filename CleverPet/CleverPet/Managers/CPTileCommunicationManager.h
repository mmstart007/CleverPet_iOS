//
//  CPTileCommunicationManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-03.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPBaseCommunicationManager.h"

@interface CPTileCommunicationManager : CPBaseCommunicationManager

+ (instancetype)sharedInstance;

- (ASYNC)refreshTiles:(NSString*)filter completion:(void (^)(NSDictionary *tileInfo, NSError *error))completion;
- (ASYNC)getNextPage:(NSString*)filter withCursor:(NSString*)cursor completion:(void (^)(NSDictionary *tileInfo, NSError *error))completion;
- (ASYNC)handleButtonPressWithPath:(NSString *)buttonPath completion:(void (^)(NSError *error))completion;
- (ASYNC)handleTileSwipe:(NSString*)tileId completion:(void (^)(NSError *error))completion;

@end
