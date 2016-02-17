//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileViewCell.h"
#import "CPTile.h"

@interface CPTileViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *tagTimeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIView *colorBarView;
@end

@implementation CPTileViewCell {
}

- (void)setTile:(CPTile *)tile {
    self.titleLabel.text = tile.title;
    self.bodyTextView.attributedText = tile.parsedBody;
    self.cellImageView.image = tile.image;
    self.colorBarView.backgroundColor = [UIColor appTealColor];
}

- (void)awakeFromNib
{
    self.titleLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    self.titleLabel.textColor = [UIColor appGreyColor];
    
    self.tagTimeStampLabel.font = [UIFont cpLightFontWithSize:10 italic:NO];
    self.tagTimeStampLabel.textColor = [UIColor appLightGreyColor];
    
//    for (UIView *view in @[self.titleLabel, self.bodyTextView, self.cellImageView]) {
//        view.layer.borderColor = [[UIColor redColor] CGColor];
//        view.layer.borderWidth = 3;
//    }
}
@end