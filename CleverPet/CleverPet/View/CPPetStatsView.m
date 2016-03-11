//
//  CPPetStatsView.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPetStatsView.h"
#import "UIView+CPShadowEffect.h"
#import "CPLabelUtils.h"
#import "CPFirebaseManager.h"

@interface CPPetStatsView ()
@property (weak, nonatomic) IBOutlet UILabel *playsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *kibblesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playsLabel;
@property (weak, nonatomic) IBOutlet UILabel *kibblesLabel;
@property (weak, nonatomic) IBOutlet UILabel *challengeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *challengeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lifetimePointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lifetimePointsTitleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *dividerView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@end

@implementation CPPetStatsView
- (void)awakeFromNib
{
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:12 italic:NO],
                              [UIColor appSubCopyTextColor],
                              @[self.kibblesTitleLabel, self.playsTitleLabel]);
    
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:25 italic:NO],
                              [UIColor appTitleTextColor],
                              @[self.kibblesLabel, self.playsLabel]);
    
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:15 italic:NO],
                              [UIColor appTitleTextColor],
                              @[self.lifetimePointsLabel, self.challengeTitleLabel, self.errorMessageLabel]);
    
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:12 italic:NO],
                              [UIColor appSubCopyTextColor],
                              @[self.lifetimePointsTitleLabel, self.challengeNumberLabel]);
    
    self.dividerView.backgroundColor = [UIColor appDividerColor];
    
    [self.shadowView applyCleverPetShadow];
    
    self.progressView.progressTintColor = [UIColor appTealColor];
    self.progressView.trackTintColor = [UIColor appDividerColor];
    
    BLOCK_SELF_REF_OUTSIDE()
    [CPFirebaseManager sharedInstance].viewStatsUpdateBlock = ^(NSError *error, NSDictionary *update) {
        BLOCK_SELF_REF_INSIDE()
        if (error) {
            [self.errorMessageLabel setText:NSLocalizedString(@"Sorry, there was an issue getting your pet's stats", @"Error message when when stats ")];
            [self.errorView setHidden:NO];
        }else {
            [self.errorView setHidden:YES];
            if (![update isEqual:[NSNull null]]) {
                [self.challengeNumberLabel setHidden:NO];
                [self.challengeTitleLabel setHidden:NO];
                
                [self.kibblesLabel setText:[[update objectForKey:@"kibbles"] stringValue]];
                [self.playsLabel setText:[[update objectForKey:@"plays"] stringValue]];
                [self.challengeTitleLabel setText:[update objectForKey:@"challenge_name"]];
                [self.challengeNumberLabel setText:[[update objectForKey:@"challenge_number"] stringValue]];
                [self.lifetimePointsLabel setText:[[update objectForKey:@"lifetime_points"] stringValue]];
                
                NSNumber *stage = [update objectForKey:@"stage_number"];
                NSNumber *totalStages = [update objectForKey:@"total_stages"];
                float progress = [stage floatValue]/[totalStages floatValue];
                [self.progressView setProgress:progress animated:YES];
            } else {
                [self.challengeTitleLabel setHidden:YES];
                [self.challengeNumberLabel setHidden:YES];
                [self.kibblesLabel setText:@"0"];
                [self.playsLabel setText:@"0"];
                [self.lifetimePointsLabel setText:@"0"];
                [self.progressView setProgress:0.0f animated:YES];
            }
        }
    };
}

- (void)dealloc
{
    [CPFirebaseManager sharedInstance].viewStatsUpdateBlock = nil;
}

@end
