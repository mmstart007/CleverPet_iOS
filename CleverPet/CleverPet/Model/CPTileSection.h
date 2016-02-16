//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPTile;
@class CPSimpleDate;

@interface CPTileSection : NSObject
@property (assign, nonatomic) CPSimpleDate *simpleDate;
@property (strong, nonatomic) NSMutableArray<CPTile *> *tiles;
@end