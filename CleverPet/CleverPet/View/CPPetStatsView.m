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
#import "OJFSegmentedProgressView.h"

@interface CPPetStatsView ()
@property (weak, nonatomic) IBOutlet UILabel *playsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *kibblesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playsLabel;
@property (weak, nonatomic) IBOutlet UILabel *kibblesLabel;
@property (weak, nonatomic) IBOutlet UILabel *challengeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *challengeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lifetimePointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lifetimePointsTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *progressViewHolder;
@property (weak, nonatomic) IBOutlet UIView *dividerView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (strong, nonatomic) OJFSegmentedProgressView *progressView;

@property (strong, nonatomic) NSArray<FirebaseManagerHandle> *handles;
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
    
    self.progressView = [[OJFSegmentedProgressView alloc] initWithNumberOfSegments:1];
    [self.progressView setFrame:CGRectMake(0, 0, self.progressViewHolder.frame.size.width, self.progressViewHolder.frame.size.height)];
    [self.progressView setProgressTintColor:[UIColor appTealColor]];
    [self.progressView setTrackTintColor:[UIColor appDividerColor]];
    [self.progressView setSegmentSeparatorSize:0.1f];
    [self.progressView setStyle:OJFSegmentedProgressViewStyleDiscrete];
    [self.progressViewHolder addSubview:self.progressView];
    
    [self.progressView setAutoresizingMask:UIViewContentModeLeft|UIViewContentModeRight];
    self.progressView.layer.cornerRadius = 1;
    
#define SUBSCRIBE(Type, Name, LabelName) [[CPFirebaseManager sharedInstance] subscribeTo##Name##WithBlock:[self updateBlockFor##Type##Label:LabelName]]
   
    NSMutableArray *handles = [[NSMutableArray alloc] init];
    
    [handles addObjectsFromArray:@[
                                   SUBSCRIBE(Number, Kibbles, self.kibblesLabel),
                                   SUBSCRIBE(Number, Plays, self.playsLabel),
                                   SUBSCRIBE(String, ChallengeName, self.challengeTitleLabel),
                                   SUBSCRIBE(Number, LifetimePoints, self.lifetimePointsLabel)
                                   ]];
    
    CPFirebaseManager *firebaseManager = [CPFirebaseManager sharedInstance];
    
    __block NSNumber *stageNumber = nil;
    __block NSNumber *totalStages = nil;
    
    BLOCK_SELF_REF_OUTSIDE();
    [handles addObject:[firebaseManager subscribeToStageNumberWithBlock:^(NSNumber *value) {
        BLOCK_SELF_REF_INSIDE();
        stageNumber = value;
        
        [self updateProgressViewForStageNumber:stageNumber totalStages:totalStages];
    }]];
    
    [handles addObject:[firebaseManager subscribeToTotalStagesWithBlock:^(NSNumber *value) {
        BLOCK_SELF_REF_INSIDE();
        totalStages = value;
        
        [self updateProgressViewForStageNumber:stageNumber totalStages:totalStages];
    }]];
    
    [handles addObject:[firebaseManager subscribeToChallengeNumberWithBlock:^(NSNumber *value) {
        BLOCK_SELF_REF_INSIDE();
        if (value) {
            self.challengeNumberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Challenge %@", @"Challenge number label text"), value];
        } else {
            self.challengeNumberLabel.text = nil;
        }
    }]];
    
    self.handles = handles;
}

- (FirebaseStringUpdateBlock)updateBlockForStringLabel:(UILabel *)label
{
    return ^(NSString *value) {
        label.text = value;
    };
}

- (FirebaseNumberUpdateBlock)updateBlockForNumberLabel:(UILabel *)label
{
    return ^(NSNumber *value) {
        label.text = [NSString stringWithFormat:@"%@", @(value.unsignedIntegerValue)];
    };
}

- (void)updateProgressViewForStageNumber:(NSNumber *)stageNumber totalStages:(NSNumber *)totalStages
{
    self.progressView.hidden = !(stageNumber && totalStages);
    self.progressView.numberOfSegments = totalStages.integerValue;
    self.progressView.progress = stageNumber.floatValue / totalStages.floatValue;
}

- (void)dealloc
{
    for (FirebaseManagerHandle handle in self.handles) {
        [[CPFirebaseManager sharedInstance] unsubscribeFromHandle:handle];
    }
}

@end
