//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileViewCell.h"
#import "CPTile.h"
#import "CPTileTextFormatter.h"
#import "UIView+CPShadowEffect.h"

@interface CPTileViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *tagTimeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIView *colorBarView;
@property (weak, nonatomic) IBOutlet UIView *cellImageViewHolder;
@property (weak, nonatomic) IBOutlet UIButton *negativeButton;
@property (weak, nonatomic) IBOutlet UIButton *affirmativeButton;
@property (weak, nonatomic) IBOutlet UIStackView *buttonHolder;
@property (weak, nonatomic) IBOutlet UIView *backingView;
@end

@implementation CPTileViewCell {
}

- (void)setTile:(CPTile *)tile {
    _tile = tile;
    
    self.titleLabel.hidden = !tile.title;
    self.titleLabel.text = tile.title;
    
    self.bodyTextView.attributedText = tile.parsedBody;
    
    self.cellImageViewHolder.hidden = !tile.image;
    self.cellImageView.image = tile.image;
    
    self.affirmativeButton.hidden = !tile.affirmativeButtonText;
    self.negativeButton.hidden = !tile.negativeButtonText;
    
    [self setButtonTitle:tile.affirmativeButtonText onButton:self.affirmativeButton];
    [self setButtonTitle:tile.negativeButtonText onButton:self.negativeButton];
    
    self.buttonHolder.hidden = self.affirmativeButton.hidden && self.negativeButton.hidden;
    
    UIColor *tileColor = [UIColor blackColor];
    UIColor *tileLightColor = [UIColor blackColor];
    switch (tile.tileType) {
        case CPTTMessage:
            tileColor = [UIColor appTealColor];
            tileLightColor = [UIColor appLightTealColor];
            break;
        case CPTTReport:
            tileColor = [UIColor appRedColor];
            tileLightColor = [UIColor appLightRedColor];
            break;
        case CPTTChallenge:
            tileColor = [UIColor appTealColor];
            tileLightColor = [UIColor appLightTealColor];
        case CPTTMac:
            break;
    }
    
    self.colorBarView.backgroundColor = tileColor;
    self.affirmativeButton.backgroundColor = tileColor;
    self.negativeButton.backgroundColor = tileLightColor;
    
    [self setTextColor:[UIColor whiteColor] onButton:self.affirmativeButton];
    [self setTextColor:tileColor onButton:self.negativeButton];
    
    self.tagTimeStampLabel.text = [NSString stringWithFormat:@"Device Message | %@", [[CPTileTextFormatter instance].relativeDateFormatter stringFromDate:tile.date]];
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

- (void)setButtonTitle:(NSString *)buttonTitle onButton:(UIButton *)button
{
    for (NSNumber *controlState in @[
                                     @(UIControlStateNormal),
                                     @(UIControlStateSelected),
                                     @(UIControlStateHighlighted)
                                     ]) {
        [button setTitle:buttonTitle forState:controlState.unsignedIntegerValue];
    }
}

- (void)awakeFromNib
{    
    self.titleLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    self.titleLabel.textColor = [UIColor appTitleTextColor];
    
    self.tagTimeStampLabel.font = [UIFont cpLightFontWithSize:10 italic:NO];
    self.tagTimeStampLabel.textColor = [UIColor appSubCopyTextColor];
    
    self.bodyTextView.textContainer.lineFragmentPadding = 0;
    self.bodyTextView.textContainerInset = UIEdgeInsetsZero;
    
    for (UIButton *button in @[self.affirmativeButton, self.negativeButton]) {
        button.titleLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    }
    
    [self.backingView applyCleverPetShadow];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)prepareForReuse
{
    self.titleLabel.text = nil;
    self.cellImageView.image = nil;
}
@end