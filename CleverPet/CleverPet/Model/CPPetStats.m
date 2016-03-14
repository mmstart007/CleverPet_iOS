//
//  CPPetStats.m
//  CleverPet
//
//  Created by Michelle Hillier on 2016-03-11.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPetStats.h"

@implementation CPPetStats

+ (JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{ @"challenge_name" : @"challengeName",
                                                                                                       @"challenge_number" : @"challengeNumber",
                                                                                                       @"lifetime_points" : @"lifetimePoints",
                                                                                                       @"stage_number" : @"stageNumber",
                                                                                                       @"total_stages" : @"totalStages" }];
}

@end
