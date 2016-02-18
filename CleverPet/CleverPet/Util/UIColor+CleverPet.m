//
//  UIColor+CleverPet.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "UIColor+CleverPet.h"

#define UIColorFromRGB(RGB) [UIColor colorWithRed:((RGB)>>16)/255.0 green:(((RGB)>>8)&0xFF)/255.0 blue:((RGB)&0xFF)/255.0 alpha:1.0]

@implementation UIColor(CleverPet)

+ (UIColor*)appGreenColor
{
    return [UIColor colorWithRed:159.0/255.0 green:192.0/255.0 blue:79.0/255.0 alpha:1.0];
}

+ (UIColor*)appTealColor
{
    return [UIColor colorWithRed:11.0/255.0 green:172.0/255.0 blue:193.0/255.0 alpha:1.0];
}

+ (UIColor*)appYellowColor
{
    return [UIColor colorWithRed:247.0/255.0 green:190.0/255.0 blue:46.0/255.0 alpha:1.0];
}

+ (UIColor*)appRedColor
{
    return [UIColor colorWithRed:234.0/255.0 green:96.0/255.0 blue:96.0/255.0 alpha:1.0];
}

+ (UIColor*)appOrangeColor
{
    return [UIColor colorWithRed:232.0/255.0 green:125.0/255.0 blue:53.0/255.0 alpha:1.0];
}

+ (UIColor*)appBlackColor
{
    return [UIColor colorWithRed:29.0/255.0 green:29.0/255.0 blue:29.0/255.0 alpha:1.0];
}

+ (UIColor*)appGreyColor
{
    return [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
}

+ (UIColor*)appWhiteColor
{
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (UIColor*)appBackgroundColor
{
    return [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:249.0/255.0 alpha:1.0];
}

+ (UIColor*)appLightTealColor
{
    return [UIColor colorWithRed:230.0/255.0 green:247.0/255.0 blue:249.0/255.0 alpha:1.0];
}

+ (UIColor*)appDarkGreyTextColor
{
    return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
}

+ (UIColor*)appLightGreyColor
{
    return [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
}
@end
