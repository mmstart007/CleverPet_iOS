//
//  UIFont+CleverPet.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont(CleverPet)

+ (UIFont*)cpHairlineFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;
+ (UIFont*)cpThinFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;
+ (UIFont*)cpExtraLightFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;
+ (UIFont*)cpLightFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;
+ (UIFont*)cpRegularFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;
+ (UIFont*)cpMediumFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;
+ (UIFont*)cpSemiboldFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;
+ (UIFont*)cpBoldFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;
+ (UIFont*)cpBlackFontWithSize:(CGFloat)fontSize italic:(BOOL)italic;

@end