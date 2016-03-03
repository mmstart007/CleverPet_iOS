//
//  CPDevice.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-01.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPDevice.h"

@implementation CPDevice

+ (JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{kDeviceIdKey:@"deviceId", kParticleIdKey:@"particleId"}];
}

@end
