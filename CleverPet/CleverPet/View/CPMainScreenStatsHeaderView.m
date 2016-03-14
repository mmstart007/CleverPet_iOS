//
//  CPMainScreenStatsHeaderView.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainScreenStatsHeaderView.h"
#import "CPLabelUtils.h"
#import "CPFirebaseManager.h"

@interface CPMainScreenStatsHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *kibblesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *kibblesNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *playsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playsNumberLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation CPMainScreenStatsHeaderView

+ (instancetype)loadFromNib {
    return [[NSBundle mainBundle] loadNibNamed:@"CPMainScreenStatsHeaderView" owner:nil options:nil][0];
}

- (void)awakeFromNib {
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:12 italic:NO], [UIColor appSubCopyTextColor], @[self.kibblesTitleLabel, self.playsTitleLabel]);
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:12 italic:NO], [UIColor appTitleTextColor], @[self.kibblesNumberLabel, self.playsNumberLabel]);
    
    self.imageView.layer.cornerRadius = self.imageView.bounds.size.height / 2;
    self.imageView.clipsToBounds = YES;
    self.progressView.progressTintColor = [UIColor appTealColor];
    self.progressView.trackTintColor = [UIColor appDividerColor];
    
    BLOCK_SELF_REF_OUTSIDE();
    [CPFirebaseManager sharedInstance].headerStatsUpdateBlock = ^(NSError *error, CPPetStats *update) {
        BLOCK_SELF_REF_INSIDE()
        if(error) {
            [self setHidden:YES];
        }else {
            [self setHidden:NO];
            if (update != nil) {
                [self.kibblesNumberLabel setText:[update.kibbles stringValue]];
                [self.playsNumberLabel setText:[update.plays stringValue]];
                
                float progress = [update.stageNumber floatValue]/[update.totalStages floatValue];
                [self.progressView setProgress:progress animated:YES];
            }   else {
                [self.kibblesNumberLabel setText:@"0"];
                [self.playsNumberLabel setText:@"0"];
                [self.progressView setProgress:0.0f animated:YES];
            }
        }
    };
}

- (void)dealloc
{
    [CPFirebaseManager sharedInstance].headerStatsUpdateBlock = nil;
}

@end
