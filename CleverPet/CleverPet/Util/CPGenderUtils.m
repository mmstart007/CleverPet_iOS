//
//  CPGenderUtils.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-26.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPGenderUtils.h"

// TODO: defines instead of consts when we do localization
// Format returned by and sent to the server
NSString * const kGenderNeutralAltered = @"altered";
NSString * const kGenderNeutralUnaltered = @"unaltered";
NSString * const kGenderNeutralUnspecified = @"unspecified";

// Format displayed to the user
NSString * const kMaleAltered = @"Neutered";
NSString * const kMaleUnaltered = @"Not Neutered";
NSString * const kMaleUnspecified = @"Unspecified";
NSString * const kFemaleAltered = @"Spayed";
NSString * const kFemaleUnaltered = @"Not Spayed";
NSString * const kFemaleUnspecified = @"Unspecified";

@implementation CPGenderUtils

+ (NSDictionary *)alteredToGenderMapping
{
    static dispatch_once_t onceToken;
    static NSDictionary *s_alteredToGenderMapping;
    dispatch_once(&onceToken, ^{
        s_alteredToGenderMapping = @{kGenderNeutralAltered:@{kMaleKey:kMaleAltered, kFemaleKey:kFemaleAltered}, kGenderNeutralUnaltered:@{kMaleKey:kMaleUnaltered, kFemaleKey:kFemaleUnaltered}, kGenderNeutralUnspecified:@{kMaleKey:kMaleUnspecified, kFemaleKey:kFemaleUnspecified}};
    });
    return s_alteredToGenderMapping;
}

+ (NSString*)stringForAlteredState:(NSString *)state withGender:(NSString *)gender
{
    
    return [CPGenderUtils alteredToGenderMapping][[state lowercaseString]][[gender lowercaseString]];
}

+ (NSString*)genderNeutralStringForAlteredState:(NSString *)state
{
    static dispatch_once_t onceToken;
    static NSSet *s_alteredStrings;
    static NSSet *s_unalteredStrings;
    static NSSet *s_unspecifiedStrings;
    dispatch_once(&onceToken, ^{
        s_alteredStrings = [NSSet setWithArray:@[kMaleAltered, kFemaleAltered]];
        s_unalteredStrings = [NSSet setWithArray:@[kMaleUnaltered, kFemaleUnaltered]];
        s_unspecifiedStrings = [NSSet setWithArray:@[kMaleUnspecified, kFemaleUnspecified]];
    });
    
    if ([s_alteredStrings containsObject:state]) {
        return kGenderNeutralAltered;
    }
    
    if ([s_unalteredStrings containsObject:state]) {
        return kGenderNeutralUnaltered;
    }
    
    if ([s_unspecifiedStrings containsObject:state]) {
        return kGenderNeutralUnspecified;
    }
    
    return nil;
}

+ (NSString *)alteredFieldHeaderForGender:(NSString *)gender
{
    // TODO: update this if the header should be Neutered/Not Neutered instead of just Neutered
    return [CPGenderUtils stringForAlteredState:kGenderNeutralAltered withGender:gender];
}

@end
