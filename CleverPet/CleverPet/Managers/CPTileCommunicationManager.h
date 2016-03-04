//
//  CPTileCommunicationManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-03.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPTileCommunicationManager : NSObject

+ (instancetype)sharedInstance;

- (ASYNC)refreshTiles:(NSString*)filter completion:(void (^)(NSDictionary *tileInfo, NSError *error))completion;
- (ASYNC)getNextPage:(NSString*)filter withCursor:(NSString*)cursor completion:(void (^)(NSDictionary *tileInfo, NSError *error))completion;

@end
