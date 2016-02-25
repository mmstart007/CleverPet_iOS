//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPSimpleDate : NSObject <NSObject>
@property (assign, nonatomic) NSInteger year, month, day;

- (instancetype)initWithDate:(NSDate *)date;

- (NSComparisonResult)compareToSimpleDate:(CPSimpleDate *)other;
+ (NSComparisonResult(^)(CPSimpleDate *a, CPSimpleDate *b))comparator;
@end