//
//  CPMainScreenHeaderView.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainScreenHeaderView.h"

@interface CPMainScreenHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@end

@implementation CPMainScreenHeaderView
+ (instancetype)loadFromNib {
    return [[NSBundle mainBundle] loadNibNamed:@"CPMainScreenHeaderView" owner:nil options:nil][0];
}

- (void)awakeFromNib {
    self.centerLabel.font = [UIFont cpLightFontWithSize:18 italic:NO];
    self.centerLabel.textColor = [UIColor appTealColor];
}

@end
