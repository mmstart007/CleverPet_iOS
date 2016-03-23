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

@interface CPAbstractMutableString : NSObject
- (instancetype)initWithString:(NSMutableString *)string;
- (instancetype)initWithAttributedString:(NSMutableAttributedString *)attributedString;

- (void)replaceCharactersInRange:(NSRange)range withString:(nonnull NSString *)aString;
- (NSString *)string;

@property (strong, nonatomic) NSMutableString *mutableString;
@property (strong, nonatomic) NSMutableAttributedString *attributedString;
@end

@implementation CPAbstractMutableString
- (instancetype)initWithString:(NSMutableString *)string {
    if (self = [super init]) {
        self.mutableString = string;
    }
    
    return self;
}

- (instancetype)initWithAttributedString:(NSMutableAttributedString *)attributedString {
    if (self = [super init]) {
        self.attributedString = attributedString;
    }
    
    return self;
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    if (self.mutableString) {
        [self.mutableString replaceCharactersInRange:range withString:aString];
    } else {
        [self.attributedString replaceCharactersInRange:range withString:aString];
    }
}

- (NSString *)string {
    if (self.mutableString) {
        return self.mutableString;
    } else {
        return self.attributedString.string;
    }
}
@end

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

+ (void)setTimeZoneOffset:(NSInteger)offset
{
    [[[self instance] relativeDateFormatter] setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
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

- (NSString *)formatNonMarkdownText:(NSString *)text forPet:(CPPet *)pet
{
    NSString *genderedString = [self filterStringForGender:text forPet:pet];
    return [self filterStringForPetName:genderedString forPet:pet];
}

- (NSAttributedString *)formatMarkdownText:(NSString *)text forPet:(CPPet *)pet
{
    NSString *genderedString = [self filterStringForGender:text forPet:pet];
    NSAttributedString *formattedString = [self attributedStringFromMarkdownString:genderedString];
    return [self filterAttributedStringForPetName:formattedString forPet:pet];
}

- (NSAttributedString *)filterAttributedStringForPetName:(NSAttributedString *)string forPet:(CPPet *)pet
{
    NSMutableAttributedString *attributedString = [string mutableCopy];
    [self filterAbstractStringForPetName:[[CPAbstractMutableString alloc] initWithAttributedString:attributedString] forPet:pet];
    return attributedString;
}

- (NSAttributedString *)filterAttributedStringForGender:(NSAttributedString *)string forPet:(CPPet *)pet
{
    NSMutableAttributedString *attributedString = [string mutableCopy];
    [self filterAbstractStringForGender:[[CPAbstractMutableString alloc] initWithAttributedString:attributedString] forPet:pet];
    return attributedString;
}

- (NSString *)filterStringForPetName:(NSString *)string forPet:(CPPet *)pet
{
    NSMutableString *mutableString = [string mutableCopy];
    [self filterAbstractStringForPetName:[[CPAbstractMutableString alloc] initWithString:mutableString] forPet:pet];
    return mutableString;
}

- (NSString *)filterStringForGender:(NSString *)string forPet:(CPPet *)pet
{
    NSMutableString *mutableString = [string mutableCopy];
    [self filterAbstractStringForGender:[[CPAbstractMutableString alloc] initWithString:mutableString] forPet:pet];
    return mutableString;
}

- (NSError *)filterAbstractStringForPetName:(CPAbstractMutableString *)string forPet:(CPPet *)pet
{
    NSError *error = nil;
    NSRegularExpression *tokenFinder = [NSRegularExpression regularExpressionWithPattern:@"{{dog_name}}"
                                                                                 options:NSRegularExpressionIgnoreMetacharacters
                                                                                   error:&error];
    
    if (error) {
        return error;
    }
    
    NSTextCheckingResult *result = nil;
    while ((result = [tokenFinder firstMatchInString:string.string options:0 range:NSMakeRange(0, string.string.length)]) != nil) {
        [string replaceCharactersInRange:result.range withString:pet.name];
    }
    
    return nil;
}

- (NSError *)filterAbstractStringForGender:(CPAbstractMutableString *)string forPet:(CPPet *)pet
{
    NSError *error = nil;
    NSRegularExpression *tokenFinder = [NSRegularExpression regularExpressionWithPattern:@"\\{\\{(.*?)\\|(.*?)\\}\\}" options:0 error:&error];
    
    if (error) {
        return error;
    }
    
    NSTextCheckingResult *result = nil;
    while ((result = [tokenFinder firstMatchInString:string.string options:0 range:NSMakeRange(0, string.string.length)])) {
        NSLog(@"%@", result);
    }
    
    return nil;
}
@end
