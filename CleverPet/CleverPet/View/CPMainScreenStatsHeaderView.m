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
#import "OJFSegmentedProgressView.h"

@interface CPMainScreenStatsHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *kibblesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *kibblesNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *playsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playsNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *progressViewHolder;
@property (strong, nonatomic) OJFSegmentedProgressView *progressView;
@property (strong, nonatomic) NSArray<FirebaseManagerHandle> *handles;
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
    
    self.progressView = [[OJFSegmentedProgressView alloc] initWithNumberOfSegments:1];
    [self.progressView setFrame:CGRectMake(0, 0, self.progressViewHolder.frame.size.width, self.progressViewHolder.frame.size.height)];
    [self.progressView setProgressTintColor:[UIColor appTealColor]];
    [self.progressView setTrackTintColor:[UIColor appDividerColor]];
    [self.progressView setSegmentSeparatorSize:0.1f];
    [self.progressView setStyle:OJFSegmentedProgressViewStyleDiscrete];
    [self.progressViewHolder addSubview:self.progressView];
    
    [self.progressView setAutoresizingMask:UIViewContentModeLeft|UIViewContentModeRight];
    
    CPFirebaseManager *firebaseManager = [CPFirebaseManager sharedInstance];
    BLOCK_SELF_REF_OUTSIDE();
    
    NSMutableArray *handles = [[NSMutableArray alloc] init];
    [handles addObjectsFromArray:@[
                                   [firebaseManager subscribeToKibblesWithBlock:[self numberUpdateBlockForLabel:self.kibblesNumberLabel]],
                                   [firebaseManager subscribeToPlaysWithBlock:[self numberUpdateBlockForLabel:self.playsNumberLabel]]
                                   ]];
    
    __block NSNumber *stageNumber = nil;
    __block NSNumber *totalStages = nil;
    
    [handles addObject:[firebaseManager subscribeToStageNumberWithBlock:^(NSNumber *value) {
        stageNumber = value;
        BLOCK_SELF_REF_INSIDE();
        
        [self updateProgressViewForStageNumber:stageNumber totalStages:totalStages];
    }]];
    
    [handles addObject:[firebaseManager subscribeToTotalStagesWithBlock:^(NSNumber *value) {
        BLOCK_SELF_REF_INSIDE();
        
        totalStages = value;
        
        [self updateProgressViewForStageNumber:stageNumber totalStages:totalStages];
    }]];
    
    self.handles = handles;
}

- (void)updateProgressViewForStageNumber:(NSNumber *)stageNumber totalStages:(NSNumber *)totalStages
{
    self.progressView.hidden = !(stageNumber && totalStages);
    self.progressView.numberOfSegments = totalStages.integerValue;
    if (totalStages.floatValue > 0) {
        self.progressView.progress = stageNumber.floatValue / totalStages.floatValue;
    }
}

- (FirebaseNumberUpdateBlock)numberUpdateBlockForLabel:(UILabel *)label
{
    return ^(NSNumber *number) {
        label.text = [NSString stringWithFormat:@"%@", @(number.unsignedIntegerValue)];
    };
}

- (FirebaseStringUpdateBlock)stringUpdateBlockForLabel:(UILabel *)label
{
    return ^(NSString *value) {
        label.text = value;
    };
}

- (void)dealloc
{
    for (FirebaseManagerHandle handle in self.handles) {
        [[CPFirebaseManager sharedInstance] unsubscribeFromHandle:handle];
    }
    self.handles = nil;
}

@end
