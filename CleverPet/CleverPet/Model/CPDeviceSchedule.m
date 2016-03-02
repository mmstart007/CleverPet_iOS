//
//  CPDeviceSchedule.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-02.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPDeviceSchedule.h"

@implementation CPDeviceSchedule

+ (JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{kScheduleIdKey:@"scheduleId"}];
}

@end
