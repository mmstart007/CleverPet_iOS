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

- (NSAttributedString *)parsedBody {
    if (!_parsedBody) {
        _parsedBody = [[CPTileTextFormatter instance] formatTileText:self.message forPet:nil];
    }

    return _parsedBody;
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

- (void)setMessage:(NSString *)message {
    self.parsedBody = nil;
    _message = message;
}

@end