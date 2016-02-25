//
//  CPMainTableSectionHeader.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainTableSectionHeader.h"

@interface CPMainTableSectionHeader ()
@end

@implementation CPMainTableSectionHeader
- (void)awakeFromNib
{   
    self.clipsToBounds = NO;
    
    self.contentView.backgroundColor = [UIColor appBackgroundColor];
    self.sectionHeaderLabel.font = [UIFont cpExtraLightFontWithSize:15 italic:NO];
    self.sectionHeaderLabel.textColor = [UIColor appSubCopyTextColor];
}
@end
