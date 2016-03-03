//
// Created by Daryl at Finger Foods on 2016-03-02.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

@import Foundation;

@interface CPMainTableSectionHeaderFilter : NSObject<NSCopying>
+ (instancetype)filterWithName:(NSString *)filterName;
- (instancetype)initWithFilterName:(NSString *)filterName;

- (id)copyWithZone:(NSZone *)zone;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToFilter:(CPMainTableSectionHeaderFilter *)filter;

- (NSUInteger)hash;

@property (strong, nonatomic) NSString *filterName;
@end