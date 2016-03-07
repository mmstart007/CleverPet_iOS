//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileViewCell.h"
#import "CPTile.h"
#import "CPTileTextFormatter.h"
#import "UIView+CPShadowEffect.h"
#import "CPTileCommunicationManager.h"

@interface CPTileViewCell ()
@property (weak, nonatomic) IBOutlet UIStackView *messageTileContentView;
@property (weak, nonatomic) IBOutlet UILabel *tagTimeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIView *colorBarView;
@property (weak, nonatomic) IBOutlet UIView *cellImageViewHolder;
@property (weak, nonatomic) IBOutlet UIButton *secondaryButton;
@property (weak, nonatomic) IBOutlet UIButton *primaryButton;
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
    
    if (tile.templateType == CPTileTemplateVideo) {
        self.videoLayoutTextView.attributedText = tile.parsedBody;
        self.bodyTextView.attributedText = nil;
        [self.videoLayoutImageView setImageWithURL:tile.videoThumbnailUrl];
    } else {
        self.bodyTextView.attributedText = tile.parsedBody;
        self.videoLayoutTextView.attributedText = nil;
        self.cellImageViewHolder.hidden = !tile.imageUrl;
        [self.cellImageView setImageWithURL:tile.imageUrl];
    }
    // TODO: report template
    
    self.primaryButton.hidden = !tile.primaryButtonText;
    self.secondaryButton.hidden = !tile.secondaryButtonText;
    
    [self setButtonTitle:tile.primaryButtonText onButton:self.primaryButton];
    [self setButtonTitle:tile.secondaryButtonText onButton:self.secondaryButton];
    
    self.buttonHolder.hidden = self.primaryButton.hidden && self.secondaryButton.hidden;
    
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
    
    // TODO: convert button background colors to images, or set alpha on them or something, so they look disabled
    self.colorBarView.backgroundColor = tileColor;
    self.swipedColorView.backgroundColor = tileColor;
    self.primaryButton.backgroundColor = tileColor;
    self.secondaryButton.backgroundColor = tileLightColor;
    
    [self setTextColor:[UIColor whiteColor] onButton:self.primaryButton];
    [self setTextColor:tileColor onButton:self.secondaryButton];

    self.tagTimeStampLabel.text = [NSString stringWithFormat:@"Device Message | %@", [[CPTileTextFormatter instance].relativeDateFormatter stringFromDate:tile.date]];
    
    self.colouredDotView.backgroundColor = tileColor;
}

- (void)swipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    if (self.tile.userDeletable && [self.swipeGestureRecognizers containsObject:recognizer]) {
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
    
    for (UIButton *button in @[self.primaryButton, self.secondaryButton]) {
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
    // TODO: cancel request response block somehow. Maybe mark request in progress on the tile so we have the correct state when scrolling back to a tile if the request takes a long time?
    [self requestInProgress:NO];
}

- (void)requestInProgress:(BOOL)inProgress
{
    self.primaryButton.enabled = !inProgress;
    self.secondaryButton.enabled = !inProgress;
}

- (IBAction)secondaryButtonTapped:(id)sender
{
    [self buttonTappedWithPath:self.tile.secondaryButtonUrl];
}

- (IBAction)primaryButtonTapped:(id)sender
{
    [self buttonTappedWithPath:self.tile.primaryButtonUrl];
}
     
- (void)buttonTappedWithPath:(NSString *)path
{
    // TODO: chain this back up through the data source -> data manager -> communications manager instead of calling directly?
    [self requestInProgress:YES];
    BLOCK_SELF_REF_OUTSIDE();
    [[CPTileCommunicationManager sharedInstance] handleButtonPressWithPath:path completion:^(NSError *error){
        BLOCK_SELF_REF_INSIDE();
        // TODO: display error;
        [self requestInProgress:NO];
    }];
}

@end