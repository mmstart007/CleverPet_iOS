//
//  CPUser.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPUser.h"

@implementation CPUser

+ (JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{@"animal":@"pet"}];
}

- (void)setWeightUnits:(NSString *)weightUnits {
    _weightUnits = weightUnits;
    _pet.weightUnits = weightUnits;
    if ([weightUnits isEqualToString:@"kg"]) {
        _pet.weight = [[NSString stringWithFormat:@"%.1f",_pet.weight/kLbsToKgs]floatValue];
    }
}

@end
