//
//  UIView+CPShadowEffect.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "UIView+CPShadowEffect.h"

@implementation UIView (CPShadowEffect)
- (void)applyCleverPetShadow
{
    self.layer.shadowColor = [UIColor colorWithWhite:.85 alpha:1].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 1;
}

- (void)removeCleverPetShadow
{
    self.layer.shadowOpacity = 0;
    self.layer.shadowColor = nil;
    self.layer.shadowRadius = 0;
    self.layer.shadowOffset = CGSizeZero;
}
@end
