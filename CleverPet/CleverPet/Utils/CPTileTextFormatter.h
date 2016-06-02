//
//  CPTileTextFormatter.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPPet;

@interface CPTileTextFormatter : NSObject
+ (instancetype)instance;
+ (void)setTimeZoneOffset:(NSInteger)offset;
- (NSString *)formatNonMarkdownText:(NSString *)text forPet:(CPPet *)pet;
- (NSAttributedString *)formatMarkdownText:(NSString *)text forPet:(CPPet *)pet;
- (NSDateFormatter *)relativeDateFormatter;
@end
