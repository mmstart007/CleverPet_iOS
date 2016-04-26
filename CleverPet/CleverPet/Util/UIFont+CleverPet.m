//
//  UIFont+CleverPet.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "UIFont+CleverPet.h"
#import <CoreText/SFNTLayoutTypes.h>

NSString * const kFontName = @"Raleway";

CGFloat const kNavBarTitleFontSize = 18.0;
CGFloat const kBackButtonTitleFontSize = 15.0;
CGFloat const kButtonTitleFontSize = 18.0;
CGFloat const kTextFieldFontSize = 18.0;
CGFloat const kSignInHeaderFontSize = 20.0;
CGFloat const kSubCopyFontSize = 16.0;
CGFloat const kHubStatusSubCopyFontSize = 15.0;

CGFloat const kTableCellTitleSize = 18.0;
CGFloat const kTableCellSubTextSize = 13.0;

@implementation UIFont(CleverPet)

+ (UIFont*)cpThinFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"Thin" italic:italic] andSize:fontSize];
}

+ (UIFont*)cpExtraLightFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"ExtraLight" italic:italic] andSize:fontSize];
}

+ (UIFont*)cpLightFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"Light" italic:italic] andSize:fontSize];
}

+ (UIFont*)cpRegularFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    if (italic) {
        return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"Italic" italic:NO] andSize:fontSize];
    } else {
        return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"Regular" italic:NO] andSize:fontSize];
    }
}

+ (UIFont*)cpMediumFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"Medium" italic:italic] andSize:fontSize];
}

+ (UIFont*)cpSemiboldFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"SemiBold" italic:italic] andSize:fontSize];
}

+ (UIFont*)cpBoldFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"Bold" italic:italic] andSize:fontSize];
}

+ (UIFont*)cpExtraBoldFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"ExtraBold" italic:italic] andSize:fontSize];
}

+ (UIFont*)cpBlackFontWithSize:(CGFloat)fontSize italic:(BOOL)italic
{
    return [UIFont fontWithUppercaseNumberDescriptorsName:[UIFont fontNameForStyle:@"Black" italic:italic] andSize:fontSize];
}

+ (NSString *)fontNameForStyle:(NSString *)fontStyle italic:(BOOL)italic
{
    return [NSString stringWithFormat:@"%@-%@%@", kFontName, fontStyle, (italic ? @"Italic" : @"")];
}

+ (UIFont*)fontWithUppercaseNumberDescriptorsName:(NSString*)fontName andSize:(CGFloat)fontSize
{
    NSDictionary *upperCaseNumbersAttributes = @{UIFontFeatureTypeIdentifierKey:@(kNumberCaseType), UIFontFeatureSelectorIdentifierKey:@(kUpperCaseNumbersSelector)};
    NSDictionary *fontAttributes = @{UIFontDescriptorNameAttribute:fontName, UIFontDescriptorFeatureSettingsAttribute:@[upperCaseNumbersAttributes]};
    UIFontDescriptor *descriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
    UIFont *font = [UIFont fontWithDescriptor:descriptor size:fontSize];
    return font;
}

@end
