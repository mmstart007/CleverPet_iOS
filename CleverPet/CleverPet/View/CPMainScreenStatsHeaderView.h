//
//  CPMainScreenStatsHeaderView.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPMainScreenStatsHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

+ (instancetype)loadFromNib;
@end
