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

+ (NSCalendar *)calendar {
    static NSCalendar *s_calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_calendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    return s_calendar;
}

- (instancetype)initWithDate:(NSDate *)date {
    if (self = [super init]) {
        NSDateComponents *dateComponents = [[[self class] calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
        self.day = dateComponents.day;
        self.month = dateComponents.month;
        self.year = dateComponents.year;
    }
    
    return self;
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