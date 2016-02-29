//
//  CPGenderUtils.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-26.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kGenderNeutralAltered;
extern NSString * const kGenderNeutralUnaltered;
extern NSString * const kGenderNeutralUnspecified;

@interface CPGenderUtils : NSObject

+ (NSString*)stringForAlteredState:(NSString*)state withGender:(NSString *)gender;
+ (NSString*)genderNeutralStringForAlteredState:(NSString*)state;
+ (NSString*)alteredFieldHeaderForGender:(NSString*)gender;

@end
