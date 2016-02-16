//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTile.h"
#import "AttributedMarkdown/markdown_lib.h"
#import "AttributedMarkdown/markdown_peg.h"
@import UIKit;

@implementation CPTile {

}

+ (NSDictionary *)markdownAttributes {
    UIFont *para = [UIFont fontWithName:@"AvenirNext-Medium" size:12.0];
    UIFont *emph = [UIFont fontWithName:@"AvenirNext-Bold" size:12.0];
    UIColor *color = [UIColor redColor];
    
    return @{
             @(PARA): @{NSFontAttributeName: para},
             @(EMPH): @{
                     NSForegroundColorAttributeName: color,
                     NSFontAttributeName: emph
                        }
             };
}

- (NSAttributedString *)parsedBody {
    if (!_parsedBody) {
        NSMutableAttributedString *temp = [markdown_to_attr_string(self.body, 0, [[self class] markdownAttributes]) mutableCopy];
        NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSRange range = [temp.string rangeOfCharacterFromSet:charSet
                                                     options:NSBackwardsSearch];
        
        while (range.length != 0 && NSMaxRange(range) == temp.length) {
            [temp replaceCharactersInRange:range withString:@""];
            range = [temp.string rangeOfCharacterFromSet:charSet
                                                 options:NSBackwardsSearch];
        }
        _parsedBody = [temp copy];
    }

    return _parsedBody;
}

- (void)setBody:(NSString *)body {
    self.parsedBody = nil;
    _body = body;
}
@end