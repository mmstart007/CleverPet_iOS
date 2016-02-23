//
//  CPTileTextFormatter.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPTileTextFormatter : NSObject
+ (instancetype)instance;
- (NSAttributedString *)formatTileText:(NSString *)tileText forPet:(id)pet;
- (NSDateFormatter *)relativeDateFormatter;
@end
