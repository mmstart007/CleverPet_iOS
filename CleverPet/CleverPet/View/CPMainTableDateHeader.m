//
//  CPMainTableDateHeader.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-01.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainTableDateHeader.h"

@interface CPMainTableDateHeader ()

@end

@implementation CPMainTableDateHeader

- (void)awakeFromNib {
    self.mainLabel.font = [UIFont cpExtraLightFontWithSize:15 italic:NO];
    self.mainLabel.textColor = [UIColor appSubCopyTextColor];
    self.contentView.backgroundColor = [UIColor appBackgroundColor];
}
@end
