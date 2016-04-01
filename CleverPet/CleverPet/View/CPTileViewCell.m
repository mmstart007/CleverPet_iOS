//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileViewCell.h"
#import "CPTile.h"
#import "CPTileTextFormatter.h"
#import "UIView+CPShadowEffect.h"
#import "CPTileCommunicationManager.h"
#import "CPUserManager.h"
#import "CPReportGraphHolder.h"

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
@property (weak, nonatomic) IBOutlet UIImageView *swipableImage;

// The relative priority of these 2 constraints controls whether the swiped color view covers
// or doesn't cover the cell. One should always be greater than the other to prevent constraint conflicts.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewNotCoveringConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewCoveringConstraint;

// The relative priority of these 2 constraints controls whether the title label is pinned to the cell bounds(image/message tiles), or the video image thumbnail (video tiles). One should always be greater than the other to prevent constraint conflicts.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleNonVideoTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleVideoTrailingConstraint;

// Video layout specific stuff
@property (weak, nonatomic) IBOutlet UIView *videoContentView;
@property (weak, nonatomic) IBOutlet UIView *videoImageContainer;
@property (weak, nonatomic) IBOutlet UITextView *videoLayoutTextView;
@property (weak, nonatomic) IBOutlet UIImageView *videoLayoutImageView;

@property (weak, nonatomic) IBOutlet CPReportGraphHolder *reportContentView;

@property (strong, nonatomic) NSMutableArray<UISwipeGestureRecognizer *> *swipeGestureRecognizers;
@property (assign, nonatomic) BOOL allowSwiping;

@end

@implementation CPTileViewCell {
    CPTile *_tile;
}

- (CPTile *)tile {
    return _tile;
}

- (void)setTile:(CPTile *)tile forSizing:(BOOL)forSizing allowSwiping:(BOOL)allowSwiping {
    _tile = tile;
    
    [self.reportContentView setGraph:nil forSizing:forSizing];
    self.allowSwiping = allowSwiping;
    
    self.titleLabel.hidden = !tile.title;
    // TODO: pass in pet
    CPPet *pet = [[CPUserManager sharedInstance] getCurrentUser].pet;
    self.titleLabel.text = [[CPTileTextFormatter instance] formatNonMarkdownText:tile.title forPet:pet];
    
    self.messageTileContentView.hidden = tile.templateType != CPTileTemplateMessage;
    self.videoLayoutImageView.hidden = tile.templateType != CPTileTemplateVideo;
    self.reportContentView.hidden = tile.templateType != CPTileTemplateReport;
    
    self.videoLayoutTextView.attributedText = nil;
    self.bodyTextView.attributedText = nil;
    self.videoLayoutImageView.image = nil;
    self.cellImageView.image = nil;
    self.cellImageViewHolder.hidden = YES;
    self.videoImageContainer.hidden = YES;
    self.swipableImage.hidden = YES;
    [self.cellImageView cancelImageDownloadTask];
    [self.videoLayoutImageView cancelImageDownloadTask];
    
    if (tile.templateType == CPTileTemplateVideo) {
        self.videoLayoutTextView.attributedText = tile.parsedBody;
        self.videoImageContainer.hidden = NO;
    } else if (tile.templateType == CPTileTemplateMessage) {
        self.bodyTextView.attributedText = tile.parsedBody;
        self.cellImageViewHolder.hidden = !tile.imageUrl;
    } else if (tile.templateType == CPTileTemplateReport) {
        [self.reportContentView setGraph:tile.graph forSizing:forSizing];
    }
    
    // Pin the trailing edge of the title label to the appropriate view
    self.titleNonVideoTrailingConstraint.priority = tile.templateType == CPTileTemplateVideo ? 998 : 999;
    self.titleVideoTrailingConstraint.priority = tile.templateType == CPTileTemplateVideo ? 999 : 998;
    
    self.primaryButton.hidden = tile.templateType == CPTileTemplateVideo || !tile.primaryButtonText;
    self.secondaryButton.hidden = tile.templateType == CPTileTemplateVideo || !tile.secondaryButtonText;
    
    // Ignore button titles for video tiles
    if (tile.templateType != CPTileTemplateVideo) {
        [self setButtonTitle:[[CPTileTextFormatter instance] formatNonMarkdownText:tile.primaryButtonText forPet:pet] onButton:self.primaryButton];
        [self setButtonTitle:[[CPTileTextFormatter instance] formatNonMarkdownText:tile.secondaryButtonText forPet:pet] onButton:self.secondaryButton];
    }
    
    self.buttonHolder.hidden = self.primaryButton.hidden && self.secondaryButton.hidden;
    
    // Uppercase the first character, since it's all lowercase coming from the server
    NSString *categoryString = tile.category;
    if ([categoryString length] > 0) {
        categoryString = [categoryString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[categoryString substringToIndex:1] uppercaseString]];
    }
    self.tagTimeStampLabel.text = [NSString stringWithFormat:@"%@ | %@", categoryString, [[CPTileTextFormatter instance].relativeDateFormatter stringFromDate:tile.date]];
    
    self.swipableImage.hidden = !(tile.userDeletable && self.allowSwiping);
    
    if (!forSizing) {
        [self loadContent];
    }
}

// We don't need to load images/update colors unless we're actually going to display the tile
- (void)loadContent
{
    if (self.tile.templateType == CPTileTemplateVideo) {
        [self.videoLayoutImageView setImageWithURL:self.tile.videoThumbnailUrl];
    } else if (self.tile.templateType == CPTileTemplateMessage) {
        [self.cellImageView setImageWithURL:self.tile.imageUrl];
    }
    
    UIColor *tileColor = [UIColor blackColor];
    UIColor *tileLightColor = [UIColor blackColor];
    switch (self.tile.tileType) {
        case CPTTMessage:
            tileColor = [UIColor appTealColor];
            tileLightColor = [UIColor appLightTealColor];
            break;
        case CPTTReport:
            tileColor = [UIColor appOrangeColor];
            tileLightColor = [UIColor appLightOrangeColor];
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

    self.colouredDotView.backgroundColor = tileColor;
}

- (void)swipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    if (self.tile.userDeletable && self.allowSwiping && [self.swipeGestureRecognizers containsObject:recognizer]) {
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
    
    self.bodyTextView.attributedText = nil;
    self.videoLayoutImageView.image = nil;
    self.videoLayoutTextView.attributedText = nil;
    
    [self setSwipedMode:NO withAnimation:NO callDelegateMethod:NO];
    // TODO: cancel request response block somehow. Maybe mark request in progress on the tile so we have the correct state when scrolling back to a tile if the request takes a long time?
    [self requestInProgress:NO];
}

- (void)requestInProgress:(BOOL)inProgress
{
    self.primaryButton.enabled = !inProgress;
    self.secondaryButton.enabled = !inProgress;
    // Set alpha on the buttons so they look disabled-ish
    self.primaryButton.alpha = inProgress ? .5f : 1.f;
    self.secondaryButton.alpha = inProgress ? .5f : 1.f;
}

#pragma mark - IBActions
- (IBAction)secondaryButtonTapped:(id)sender
{
    [self buttonTappedWithPath:self.tile.secondaryButtonUrl];
}

- (IBAction)primaryButtonTapped:(id)sender
{
    [self buttonTappedWithPath:self.tile.primaryButtonUrl];
}

- (IBAction)playVideoTapped:(id)sender
{
    [self.delegate playVideoForCell:self];
    [self primaryButtonTapped:nil];
}

- (void)buttonTappedWithPath:(NSString *)path
{
    [self requestInProgress:YES];
    if (self.allowSwiping) {
        if (_tile.tileType != CPTTChallenge) {
            [self setSwipedMode:YES withAnimation:YES callDelegateMethod:NO];
        }
        
        CPTile *tileForRequest = _tile;
        BLOCK_SELF_REF_OUTSIDE();
        [[CPTileCommunicationManager sharedInstance] handleButtonPressWithPath:path completion:^(NSError *error){
            BLOCK_SELF_REF_INSIDE();
            if (error) {
                [self.delegate displayError:error];
                if ([_tile.tileId isEqualToString:tileForRequest.tileId]) {
                    // Only update our button state if we haven't been reused
                    [self requestInProgress:NO];
                    if (_tile.tileType != CPTTChallenge) {
                        [self resetSwipeState];
                    }
                }
            }
        }];
    }
}

- (void)resetSwipeState
{
    [self setSwipedMode:NO withAnimation:YES callDelegateMethod:NO];
}

@end