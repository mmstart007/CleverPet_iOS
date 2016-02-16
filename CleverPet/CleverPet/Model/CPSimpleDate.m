//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSimpleDate.h"

NSComparisonResult compareIntegers(NSInteger a, NSInteger b) {
    if (a < b) {
        return NSOrderedAscending;
    } else if (a > b) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

@implementation CPSimpleDate {

}

- (NSComparisonResult)compareToSimpleDate:(CPSimpleDate *)other {
    NSComparisonResult result = compareIntegers(self.year, other.year);
    if (result == NSOrderedSame) {
        result = compareIntegers(self.month, other.month);
        if (result == NSOrderedSame) {
            return compareIntegers(self.day, other.day);
        }
    }

    return result;
}

+ (NSComparisonResult(^)(CPSimpleDate *a, CPSimpleDate *b))comparator {
    return ^(CPSimpleDate *a, CPSimpleDate *b) {
        return [a compareToSimpleDate:b];
    };
}
@end