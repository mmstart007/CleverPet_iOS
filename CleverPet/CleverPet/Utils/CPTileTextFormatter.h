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
- (NSAttributedString *)formatTileText:(NSString *)tileText forPet:(id)pet;
- (NSDateFormatter *)relativeDateFormatter;
- (NSString *)filterString:(NSString*)string forPet:(CPPet*)pet name:(BOOL)filterName gender:(BOOL)filterGender;
@end
