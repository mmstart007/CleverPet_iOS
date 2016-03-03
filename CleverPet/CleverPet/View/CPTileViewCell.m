//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileViewCell.h"
#import "CPTile.h"
#import "CPTileTextFormatter.h"
#import "UIView+CPShadowEffect.h"

@interface CPTileViewCell ()
@property (weak, nonatomic) IBOutlet UIStackView *messageTileContentView;
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
@property (strong, nonatomic) IBOutlet UIView *colouredDotView;


@property (weak, nonatomic) IBOutlet UIView *swipedColorView;

// The relative priority of these 2 constraints controls whether the swiped color view covers
// or doesn't cover the cell. One should always be greater than the other to prevent constraint conflicts.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewNotCoveringConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewCoveringConstraint;

// Video layout specific stuff
@property (weak, nonatomic) IBOutlet UIView *videoContentView;
@property (weak, nonatomic) IBOutlet UITextView *videoLayoutTextView;
@property (weak, nonatomic) IBOutlet UIImageView *videoLayoutImageView;

@property (strong, nonatomic) NSMutableArray<UISwipeGestureRecognizer *> *swipeGestureRecognizers;
@end

@implementation CPTileViewCell {
}

- (void)setTile:(CPTile *)tile {
    _tile = tile;
    
    self.titleLabel.hidden = !tile.title;
    self.titleLabel.text = tile.title;
    
    self.messageTileContentView.hidden = tile.tileType == CPTTVideo;
    self.videoLayoutImageView.hidden = tile.tileType != CPTTVideo;
    
    if (tile.tileType == CPTTVideo) {
        self.videoLayoutTextView.attributedText = tile.parsedBody;
        self.videoLayoutImageView.image = tile.image;
    } else {
        self.bodyTextView.attributedText = tile.parsedBody;
        self.cellImageViewHolder.hidden = !tile.image;
        self.cellImageView.image = tile.image;
    }
    
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
            break;
        case CPTTVideo:
            tileColor = [UIColor appYellowColor];
            tileLightColor = [UIColor appLightYellowColor];
            break;
        case CPTTMac:
            break;
    }
    
    self.colorBarView.backgroundColor = tileColor;
    self.swipedColorView.backgroundColor = tileColor;
    self.affirmativeButton.backgroundColor = tileColor;
    self.negativeButton.backgroundColor = tileLightColor;
    
    [self setTextColor:[UIColor whiteColor] onButton:self.affirmativeButton];
    [self setTextColor:tileColor onButton:self.negativeButton];

    self.tagTimeStampLabel.text = [NSString stringWithFormat:@"Device Message | %@", [[CPTileTextFormatter instance].relativeDateFormatter stringFromDate:tile.date]];
    
    self.colouredDotView.backgroundColor = tileColor;
}

- (void)swipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    if (self.tile.isSwipeable && [self.swipeGestureRecognizers containsObject:recognizer]) {
        [self setSwipedMode:YES withAnimation:YES callDelegateMethod:YES];
    }
}

- (void)setSwipedMode:(BOOL)swipedMode withAnimation:(BOOL)animated callDelegateMethod:(BOOL)callDelegateMethod {
    if (animated) {
        [self layoutIfNeeded];
    }

    self.colorViewCoveringConstraint.priority = swipedMode ? 999 : 998;
    self.colorViewNotCoveringConstraint.priority = swipedMode ? 998 : 999;
    
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (callDelegateMethod) {
                [self.delegate didSwipeTileViewCell:self];
            }
        }];
    } else {
        [self layoutIfNeeded];
        if (callDelegateMethod) {
            [self.delegate didSwipeTileViewCell:self];
        }
    }
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
    self.contentView.backgroundColor = [UIColor appBackgroundColor];
    
    self.titleLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    self.titleLabel.textColor = [UIColor appTitleTextColor];
    
    self.tagTimeStampLabel.font = [UIFont cpLightFontWithSize:10 italic:NO];
    self.tagTimeStampLabel.textColor = [UIColor appSubCopyTextColor];
    
    self.bodyTextView.textContainer.lineFragmentPadding = 0;
    self.bodyTextView.textContainerInset = UIEdgeInsetsZero;
    self.videoLayoutTextView.textContainer.lineFragmentPadding = self.bodyTextView.textContainer.lineFragmentPadding;
    self.videoLayoutTextView.textContainerInset = self.bodyTextView.textContainerInset;
    
    for (UIButton *button in @[self.affirmativeButton, self.negativeButton]) {
        button.titleLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    }
    
    [self.backingView applyCleverPetShadow];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.colouredDotView.layer.cornerRadius = 2;
    self.colouredDotView.clipsToBounds = YES;
    
    self.swipeGestureRecognizers = [[NSMutableArray alloc] init];
    for (NSNumber *gestureDirection in @[@(UISwipeGestureRecognizerDirectionLeft), @(UISwipeGestureRecognizerDirectionRight)]) {
        UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)];
        gestureRecognizer.direction = gestureDirection.unsignedIntegerValue;
        [self.swipeGestureRecognizers addObject:gestureRecognizer];
        [self addGestureRecognizer:gestureRecognizer];
    }
}

- (void)prepareForReuse
{
    self.titleLabel.text = nil;
    self.cellImageView.image = nil;
    
    self.bodyTextView.text = nil;
    self.videoLayoutImageView.image = nil;
    self.videoLayoutTextView.text = nil;
    
    [self setSwipedMode:NO withAnimation:NO callDelegateMethod:NO];
}
@end