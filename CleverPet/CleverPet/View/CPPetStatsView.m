//
//  CPPetStatsView.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPetStatsView.h"
#import "UIView+CPShadowEffect.h"

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
                              @[self.lifetimePointsLabel, self.challengeTitleLabel]);
    
    ApplyFontAndColorToLabels([UIFont cpLightFontWithSize:12 italic:NO],
                              [UIColor appSubCopyTextColor],
                              @[self.lifetimePointsTitleLabel, self.challengeNumberLabel]);
    
    self.dividerView.backgroundColor = [UIColor appDividerColor];
    
    [self.shadowView applyCleverPetShadow];
}

void ApplyFontAndColorToLabels(UIFont *font, UIColor *color, NSArray<UILabel *> *labels) {
    for (UILabel *label in labels) {
        label.font = font;
        label.textColor = color;
    }
}
@end
