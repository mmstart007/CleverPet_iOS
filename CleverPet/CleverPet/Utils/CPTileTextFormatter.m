//
//  CPTileTextFormatter.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileTextFormatter.h"
#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "CPTile.h"
#import "CPPet.h"

@interface CPTileTextFormatter ()
@property (strong, nonatomic) NSDictionary *markdownAttributes;
@property (strong, nonatomic) NSDateFormatter *relativeDateFormatter;
@end

@implementation CPTileTextFormatter
+ (instancetype)instance {
  static CPTileTextFormatter *_instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CPTileTextFormatter alloc] init];
    });

  return _instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

- (NSDictionary *)markdownAttributes
{
    if (!_markdownAttributes)
    {
        UIFont *para = [UIFont cpLightFontWithSize:13 italic:NO];
        UIColor *paraColor = [UIColor appSubCopyTextColor];
        UIFont *emph = [UIFont cpMediumFontWithSize:13 italic:NO];
        
        NSDictionary *regularText = @{
                                      NSFontAttributeName: para,
                                      NSForegroundColorAttributeName: paraColor
                                      };
        
        _markdownAttributes = @{
                                @(RAW): regularText,
                                @(PARA): regularText,
                                @(PLAIN): regularText,
                                @(EMPH): @{
                                        NSFontAttributeName: emph
                                        }
                                };
    }
    
    return _markdownAttributes;
}

- (NSDateFormatter *)relativeDateFormatter
{
    if (!_relativeDateFormatter) {
        _relativeDateFormatter = [[NSDateFormatter alloc] init];
        _relativeDateFormatter.dateStyle = NSDateFormatterNoStyle;
        _relativeDateFormatter.timeStyle = NSDateFormatterShortStyle;
        _relativeDateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
        _relativeDateFormatter.timeZone = [NSTimeZone localTimeZone];
    }
    
    return _relativeDateFormatter;
}

- (NSAttributedString *)attributedStringFromMarkdownString:(NSString *)markdownString {
    NSMutableAttributedString *temp = [markdown_to_attr_string(markdownString, 0, self.markdownAttributes) mutableCopy];
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSRange range = [temp.string rangeOfCharacterFromSet:charSet];
    
    while (range.length != 0 && range.location == 0) {
        [temp replaceCharactersInRange:range withString:@""];
        range = [temp.string rangeOfCharacterFromSet:charSet];
    }
    
    range = [temp.string rangeOfCharacterFromSet:charSet
                                                 options:NSBackwardsSearch];
    
    while (range.length != 0 && NSMaxRange(range) == temp.length) {
        [temp replaceCharactersInRange:range withString:@""];
        range = [temp.string rangeOfCharacterFromSet:charSet
                                             options:NSBackwardsSearch];
    }
    
    return [temp copy];
}

- (NSAttributedString *)formatTileText:(NSString *)tileText forPet:(id)pet
{
    return [self attributedStringFromMarkdownString:tileText];
}

- (NSString*)filterString:(NSString*)string forPet:(CPPet *)pet name:(BOOL)filterName gender:(BOOL)filterGender
{
    NSMutableString *sanitizedString = [NSMutableString string];
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = nil;
    
    if (filterName || filterGender) {
        while ([scanner scanLocation] < [string length] - 1) {
            NSString *preReplacementString;
            NSString *replacementToken;
            
            [scanner scanUpToString:@"{{" intoString:&preReplacementString];
            if (preReplacementString) {
                [sanitizedString appendString:preReplacementString];
            }
            
            [scanner scanString:@"{{" intoString:nil];
            [scanner scanUpToString:@"}}" intoString:&replacementToken];
            [scanner scanString:@"}}" intoString:nil];
            
            // This will just remove {{}} with no content in the middle, which I think is ok
            if (replacementToken) {
                if ((filterName && [replacementToken isEqualToString:@"dog_name"]) || (filterGender && [replacementToken rangeOfString:@"|"].location != NSNotFound)) {
                    NSString *replacedToken = [self replaceToken:replacementToken forPet:pet];
                    if (replacedToken) {
                        [sanitizedString appendString:replacedToken];
                    }
                } else {
                    // We're ignoring this token type, reinsert it with {{}}
                    [sanitizedString appendFormat:@"{{%@}}", replacementToken];
                }
            }
        }
    } else {
        return string;
    }
    
    return [sanitizedString copy];
}

- (NSString*)replaceToken:(NSString*)string forPet:(CPPet*)pet
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = nil;
    NSString *prePipeToken, *postPipeToken;
    [scanner scanUpToString:@"|" intoString:&prePipeToken];
    if ([scanner scanLocation] < [string length] - 1) {
        [scanner scanString:@"|" intoString:nil];
        postPipeToken = [[scanner string] substringFromIndex:[scanner scanLocation]];
        return [pet.gender isEqualToString:kMaleKey] ? prePipeToken : postPipeToken;
    } else {
        if ([prePipeToken isEqualToString:@"dog_name"]) {
            return pet.name;
        }
        return prePipeToken;
    }
}

@end
