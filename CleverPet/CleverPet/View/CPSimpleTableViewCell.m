//
//  CPSimpleTableViewCell.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-17.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSimpleTableViewCell.h"

@interface CPSimpleTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *stripeView;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation CPSimpleTableViewCell

- (void)awakeFromNib
{
    self.stripeView.backgroundColor = [UIColor appTealColor];
    self.backgroundColor = [UIColor appWhiteColor];
    self.contentView.backgroundColor = [UIColor appWhiteColor];
    self.separatorView.backgroundColor = [UIColor appBackgroundColor];
    self.displayLabel.textColor = [UIColor appSignUpHeaderTextColor];
    self.displayLabel.font = [UIFont cpLightFontWithSize:kSignInHeaderFontSize italic:NO];
}

- (void)setupWithString:(NSString *)string
{
    self.displayLabel.text = string;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
