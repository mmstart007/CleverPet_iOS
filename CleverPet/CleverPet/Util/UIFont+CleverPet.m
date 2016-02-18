//
//  UIFont+CleverPet.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "UIFont+CleverPet.h"

NSString * const kFontName = @"Omnes";

CGFloat const kButtonTitleFontSize = 15.0;
CGFloat const kTextFieldFontSize = 15.0;
CGFloat const kSignInHeaderFontSize = 17.0;
CGFloat const kSubCopyFontSize = 13.0;

CGFloat const kTableCellTitleSize = 15.0;
CGFloat const kTableCellSubTextSize = 10.0;

@implementation UIFont(CleverPet)

+ (UIFont*)cpHairlineFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"Hairline" italic:italic] size:fontSize];
}

+ (UIFont*)cpThinFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"Thin" italic:italic] size:fontSize];
}

+ (UIFont*)cpExtraLightFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"ExtraLight" italic:italic] size:fontSize];
}

+ (UIFont*)cpLightFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"Light" italic:italic] size:fontSize];
}

+ (UIFont*)cpRegularFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"Regular" italic:italic] size:fontSize];
}

+ (UIFont*)cpMediumFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"Medium" italic:italic] size:fontSize];
}

+ (UIFont*)cpSemiboldFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"Semibold" italic:italic] size:fontSize];
}

+ (UIFont*)cpBoldFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"Bold" italic:italic] size:fontSize];
}

+ (UIFont*)cpBlackFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithName:[UIFont fontNameForStyle:@"Black" italic:italic] size:fontSize];
}

+ (NSString *)fontNameForStyle:(NSString *)fontStyle italic:(BOOL)italic
{
    return [NSString stringWithFormat:@"%@-%@%@", kFontName, fontStyle, (italic ? @"Italic" : @"")];
}

@end
