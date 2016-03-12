//
// Created by Daryl at Finger Foods on 2016-03-02.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainTableSectionHeader.h"
#include "CPMainTableSectionHeaderFilter.h"

@interface CPMainTableSectionHeaderFilter ()
@end

@implementation CPMainTableSectionHeaderFilter
+ (instancetype)filterWithName:(NSString *)filterName {
    return [[[self class] alloc] initWithFilterName:filterName];
}

- (instancetype)initWithFilterName:(NSString *)filterName {
    if (self = [super init]) {
        self.filterName = filterName;
        // TODO: clean this up
        if ([filterName isEqualToString:@"Reports"]) {
            self.color = [UIColor appRedColor];
        } else if ([filterName isEqualToString:@"Videos"]) {
            self.color = [UIColor appYellowColor];
        } else if ([filterName isEqualToString:@"Challenges"]) {
            self.color = [UIColor appTealColor];
        }
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CPMainTableSectionHeaderFilter *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.filterName = self.filterName;
    }

    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToFilter:other];
}

- (BOOL)isEqualToFilter:(CPMainTableSectionHeaderFilter *)filter {
    if (self == filter)
        return YES;
    if (filter == nil)
        return NO;
    if (self.filterName != filter.filterName && ![self.filterName isEqualToString:filter.filterName])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.filterName hash];
}


@end