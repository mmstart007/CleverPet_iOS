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

NSString * const kExternalHorizontalRuleToken = @"---";
NSString * const kInternalHorizontalRuleToken = @"Insert_Horizontal_Rule";
CGFloat const kHorizontalRuleHeight = 1.f;
CGFloat const kHorizontalRuleWidth = 300.f;

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

+ (UIImage *)horizontalRuleImage
{
    static dispatch_once_t onceToken;
    static UIImage *s_horizontalRule;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(kHorizontalRuleWidth, kHorizontalRuleHeight), NO, [[UIScreen mainScreen] scale]);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        [[UIColor colorWithWhite:.9f alpha:1.f] setFill];
        CGContextFillRect(currentContext, CGRectMake(0, 0, kHorizontalRuleWidth, kHorizontalRuleHeight));
        s_horizontalRule = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return s_horizontalRule;
}

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
    if (!text) return nil;
    
    NSString *genderedString = [self filterStringForGender:text forPet:pet];
    return [self filterStringForPetName:genderedString forPet:pet];
}

- (NSAttributedString *)formatMarkdownText:(NSString *)text forPet:(CPPet *)pet
{
    if (!text) return nil;
    
    NSString *newText = [text stringByReplacingOccurrencesOfString:kExternalHorizontalRuleToken withString:kInternalHorizontalRuleToken];
    NSString *genderedString = [self filterStringForGender:newText forPet:pet];
    NSAttributedString *formattedString = [self attributedStringFromMarkdownString:genderedString];
    formattedString = [self filterAttributedStringForPetName:formattedString forPet:pet];
    return [self processHorizontalRulesForAttributedString:formattedString];
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
    while ((result = [tokenFinder firstMatchInString:string.string options:0 range:NSMakeRange(0, string.string.length)]) != nil) {
        NSString *tokenString = [string.string substringWithRange:result.range];
        tokenString = [tokenString stringByReplacingOccurrencesOfString:@"{" withString:@""];
        tokenString = [tokenString stringByReplacingOccurrencesOfString:@"}" withString:@""];
        NSArray *tokens = [tokenString componentsSeparatedByString:@"|"];
        if ([tokens count] > 1) {
            [string replaceCharactersInRange:result.range withString:([pet.gender isEqualToString:kMaleKey] ? tokens[0] : tokens[1])];
        }
    }
    
    return nil;
}

- (NSAttributedString *)processHorizontalRulesForAttributedString:(NSAttributedString*)string
{
    NSMutableAttributedString *mutableAttributedString = [string mutableCopy];
    NSMutableString *mutableString = [[string string] mutableCopy];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@)", kInternalHorizontalRuleToken] options:kNilOptions error:nil];
    
    NSRange matchRange = NSMakeRange(0, 0);
    while (matchRange.location != NSNotFound) {
        matchRange = [regex rangeOfFirstMatchInString:mutableString options:kNilOptions range:NSMakeRange(0, [mutableString length])];
        if (matchRange.location != NSNotFound) {
            NSTextAttachment *imageAttachement = [[NSTextAttachment alloc] init];
            imageAttachement.image = [CPTileTextFormatter horizontalRuleImage];
            NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:imageAttachement];
            [mutableAttributedString replaceCharactersInRange:matchRange withAttributedString:imageString];
            // Center the image attachement
            NSRange imageRange = NSMakeRange(matchRange.location, [imageString length]);
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:imageRange];
            
            // Build out a string with same length as our image string to maintain the right spacing in the string we're searching
            NSMutableString *imageReplacementString = [NSMutableString string];
            for (NSUInteger i = 0; i < imageRange.length; i++) {
                [imageReplacementString appendString:@" "];
            }
            [mutableString replaceCharactersInRange:matchRange withString:imageReplacementString];
        }
    }
    
    return [mutableAttributedString copy];
}

@end
