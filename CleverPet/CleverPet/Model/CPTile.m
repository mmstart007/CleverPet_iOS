//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTile.h"
#import "AttributedMarkdown/markdown_lib.h"
#import "AttributedMarkdown/markdown_peg.h"
#import "CPTileTextFormatter.h"
@import UIKit;

@implementation CPTile {

}

+ (NSDateFormatter*)dateFormatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *s_tileDateFormatter;
    dispatch_once(&onceToken, ^{
        s_tileDateFormatter = [[NSDateFormatter alloc] init];
        s_tileDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSS";
    });
    return s_tileDateFormatter;
}

+ (JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{}];
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"cachedRowHeight"] || [propertyName isEqualToString:@"tileType"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"userDeletable"]) {
        return YES;
    }
    return NO;
}

- (NSAttributedString *)parsedBody {
    if (!_parsedBody) {
        _parsedBody = [[CPTileTextFormatter instance] formatTileText:self.message forPet:nil];
    }

    return _parsedBody;
}

// TODO: Pull this out into a custom transformer if we're receiving this format of date everywhere
- (void)setDateWithNSString:(NSString*)string
{
    NSDateFormatter *formatter = [CPTile dateFormatter];
    _date = [formatter dateFromString:string];
}

- (CPSimpleDate<Ignore> *)simpleDate
{
    if (!_simpleDate) {
        _simpleDate = [[CPSimpleDate alloc] initWithDate:self.date];
    }
    
    return _simpleDate;
}

- (void)setTemplate:(NSString *)template
{
    _template = template;
    // TODO: challenge?
    // TODO: static strings
    if ([template isEqualToString:@"image"] || [template isEqualToString:@"message"]) {
        _tileType = CPTTMessage;
    } else if ([template isEqualToString:@"video"]) {
        _tileType = CPTTVideo;
    } else if ([template isEqualToString:@"report"]) {
        _tileType = CPTTReport;
    }
}

- (void)setCategory:(NSString *)category
{
    _category = category;
    // TODO: challenge?
    // TODO: static strings
    if ([category isEqualToString:@"image"] || [category isEqualToString:@"message"]) {
        _tileType = CPTTMessage;
    } else if ([category isEqualToString:@"video"]) {
        _tileType = CPTTVideo;
    } else if ([category isEqualToString:@"report"]) {
        _tileType = CPTTReport;
    }
}

- (void)setMessage:(NSString *)message {
    self.parsedBody = nil;
    _message = message;
}

@end