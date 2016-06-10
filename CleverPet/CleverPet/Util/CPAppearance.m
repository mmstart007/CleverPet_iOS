//
//  CPAppearance.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-19.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPAppearance.h"

@implementation CPAppearance

+ (void)initCustomAppearance
{
    // Nav bar
    [UINavigationBar appearance].tintColor = [UIColor appTealColor];
    [UINavigationBar appearance].backgroundColor = [UIColor appWhiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor appTealColor], NSFontAttributeName:[UIFont cpLightFontWithSize:kNavBarTitleFontSize italic:NO]};
    [UINavigationBar appearance].translucent = NO;
    
    // Nonsense to kill the shadow
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    // Back button font. Don't need to do color, as it's taken care of by nav bar tint
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont cpLightFontWithSize:kBackButtonTitleFontSize italic:NO]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -2) forBarMetrics:UIBarMetricsDefault];
}

@end
