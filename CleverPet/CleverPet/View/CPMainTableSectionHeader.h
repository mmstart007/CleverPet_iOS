//
//  CPMainTableSectionHeader.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPMainTableSectionHeaderFilter : NSObject
+ (instancetype)filterWithName:(NSString *)filterName;
- (instancetype)initWithFilterName:(NSString *)filterName;

@property (strong, nonatomic) NSString *filterName;
@end

@class CPMainTableSectionHeader;
@protocol CPMainTableSectionHeaderDelegate <NSObject>
- (void)sectionHeader:(CPMainTableSectionHeader *)sectionHeader didChangeToFilter:(CPMainTableSectionHeaderFilter *)filter;
@end

@interface CPMainTableSectionHeader : UITableViewHeaderFooterView

@property (weak, nonatomic) id<CPMainTableSectionHeaderDelegate> delegate;

- (void)addFilter:(CPMainTableSectionHeaderFilter *)filter;

- (void)setCurrentFilterObject:(CPMainTableSectionHeaderFilter *)filterObject withAnimation:(BOOL)animate;

@property (assign, nonatomic) BOOL shouldShowFilters;
@property (assign, nonatomic) BOOL hasFiltersSetup;
@end
