//
//  CPMainTableSectionHeader.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPMainTableSectionHeader;
@protocol CPMainTableSectionHeaderDelegate <NSObject>
- (void)sectionHeader:(CPMainTableSectionHeader *)sectionHeader didChangeToFilter:(id)filter;
@end

@interface CPMainTableSectionHeader : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *sectionHeaderLabel;

@property (assign, nonatomic) BOOL hasFilterAction;
@end
