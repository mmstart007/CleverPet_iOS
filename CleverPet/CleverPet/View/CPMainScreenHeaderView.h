//
//  CPMainScreenHeaderView.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPPet;

@interface CPMainScreenHeaderView : UIView
+ (instancetype)loadFromNib;
- (void)setupForPet:(CPPet*)pet;
@end
