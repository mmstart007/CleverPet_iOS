//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileViewCell.h"
#import "CPTile.h"
#import "CPTileTextFormatter.h"

@interface CPTileViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *tagTimeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIView *colorBarView;
@property (weak, nonatomic) IBOutlet UIView *cellImageViewHolder;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIStackView *buttonHolder;
@property (weak, nonatomic) IBOutlet UIView *backingView;
@end

@implementation CPTileViewCell {
}

- (void)setTile:(CPTile *)tile {
    _tile = tile;
    self.titleLabel.text = tile.title;
    
    self.bodyTextView.attributedText = tile.parsedBody;
    
    self.cellImageViewHolder.hidden = !tile.image;
    self.cellImageView.image = tile.image;
    
    self.leftButton.hidden = !tile.hasLeftButton;
    self.rightButton.hidden = !tile.hasRightButton;
    
    self.buttonHolder.hidden = !tile.hasLeftButton && !tile.hasRightButton;
    
    UIColor *tileColor = [UIColor blackColor];
    UIColor *tileLightColor = [UIColor blackColor];
    switch (tile.tileType) {
        case CPTTGame:
            tileColor = [UIColor appGreenColor];
            tileLightColor = [UIColor appLightGreenColor];
            break;
        case CPTTMessage:
            tileColor = [UIColor appTealColor];
            tileLightColor = [UIColor appLightTealColor];
            break;
        case CPTTReport:
            tileColor = [UIColor appRedColor];
            tileLightColor = [UIColor appLightRedColor];
            break;
        case CPTTVideo:
            tileColor = [UIColor appYellowColor];
            tileLightColor = [UIColor appLightYellowColor];
            break;
        case CPTTMac:
            break;
    }
    
    self.colorBarView.backgroundColor = tileColor;
    self.leftButton.backgroundColor = tileLightColor;
    self.rightButton.backgroundColor = tileColor;
    
    [self setTextColor:[UIColor whiteColor] onButton:self.rightButton];
    [self setTextColor:tileColor onButton:self.leftButton];
    
    self.tagTimeStampLabel.text = [[CPTileTextFormatter instance].relativeDateFormatter stringFromDate:tile.date];
}

- (void)setTextColor:(UIColor *)color onButton:(UIButton *)button
{
    for (NSNumber *controlState in @[
                                     @(UIControlStateNormal),
                                     @(UIControlStateSelected),
                                     @(UIControlStateHighlighted)
                                     ]) {
        [button setTitleColor:color forState:controlState.unsignedIntegerValue];
    }
}

- (void)awakeFromNib
{    
    self.titleLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    self.titleLabel.textColor = [UIColor appGreyColor];
    
    self.tagTimeStampLabel.font = [UIFont cpLightFontWithSize:10 italic:NO];
    self.tagTimeStampLabel.textColor = [UIColor appLightGreyColor];
    
    self.bodyTextView.textContainer.lineFragmentPadding = 0;
    self.bodyTextView.textContainerInset = UIEdgeInsetsZero;
    
    for (UIButton *button in @[self.leftButton, self.rightButton]) {
        button.titleLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    }
    
    self.backingView.layer.shadowColor = [UIColor colorWithWhite:.85 alpha:1].CGColor;
    self.backingView.layer.shadowOffset = CGSizeMake(0, 2);
    self.backingView.layer.shadowOpacity = 1;
    self.backingView.layer.shadowRadius = 3;
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)prepareForReuse
{
    self.titleLabel.text = nil;
    self.cellImageView.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect shadowRect = self.backingView.bounds;
    shadowRect.size.height = shadowRect.size.height / 2;
    shadowRect.origin.y += shadowRect.size.height;
    shadowRect.origin.x -= 5;
    shadowRect.size.width += 10;
    
    self.backingView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
}
@end