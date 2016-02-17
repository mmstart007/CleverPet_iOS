//
// Created by Daryl at Finger Foods on 2016-02-16.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "CPMarkdownAttributedString.h"
@import UIKit;


@implementation CPMarkdownAttributedString {

}

+ (NSDictionary *)markdownAttributes {
    static NSDictionary *s_markdownAttributes;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIFont *para = [UIFont cpLightFontWithSize:13 italic:NO];
        UIColor *paraColor = [UIColor appLightGreyColor];
//        UIFont *emph = [UIFont fontWithName:@"AvenirNext-Bold" size:12.0];
        UIFont *emph = [UIFont cpMediumFontWithSize:13 italic:NO];
        
        s_markdownAttributes = @{
                                 @(PARA): @{
                                         NSFontAttributeName: para,
                                         NSForegroundColorAttributeName: paraColor
                                         },
                                 @(EMPH): @{
                                         NSFontAttributeName: emph
                                         }
                                 };
    });

    return s_markdownAttributes;
}

+ (NSAttributedString *)attributedStringFromMarkdownString:(NSString *)markdownString {
    NSMutableAttributedString *temp = [markdown_to_attr_string(markdownString, 0, [self markdownAttributes]) mutableCopy];
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange range = [temp.string rangeOfCharacterFromSet:charSet
                                                 options:NSBackwardsSearch];

    while (range.length != 0 && NSMaxRange(range) == temp.length) {
        [temp replaceCharactersInRange:range withString:@""];
        range = [temp.string rangeOfCharacterFromSet:charSet
                                             options:NSBackwardsSearch];
    }
    
    return [temp copy];
}
@end