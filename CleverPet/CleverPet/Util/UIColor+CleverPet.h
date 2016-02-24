//
//  UIColor+CleverPet.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DeclareColor(NAME) + (UIColor*)app##NAME##Color
#define UIColorFromRGB(RGB) [UIColor colorWithRed:((RGB)>>16)/255.0 green:(((RGB)>>8)&0xFF)/255.0 blue:((RGB)&0xFF)/255.0 alpha:1.0]

@interface UIColor(CleverPet)

+ (UIColor*)appGreenColor;
+ (UIColor*)appTealColor;
+ (UIColor*)appYellowColor;
+ (UIColor*)appRedColor;
+ (UIColor*)appOrangeColor;
+ (UIColor*)appBlackColor;
+ (UIColor*)appGreyColor;
+ (UIColor*)appWhiteColor;
+ (UIColor*)appBackgroundColor;
+ (UIColor*)appLightTealColor;
// #333333
+ (UIColor*)appTitleTextColor;
// #808080
+ (UIColor*)appSubCopyTextColor;
+ (UIColor*)appTextFieldPlaceholderColor;

DeclareColor(LightRed);
DeclareColor(LightGreen);
DeclareColor(LightOrange);
DeclareColor(LightYellow);
@end
