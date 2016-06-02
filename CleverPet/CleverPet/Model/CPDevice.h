//
//  CPDevice.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-01.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "CPDeviceSchedule.h"

@interface CPDevice : JSONModel

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString<Optional> *mode;
@property (nonatomic, strong) NSString<Optional> *desiredMode;
@property (nonatomic, strong) NSString<Optional> *particleId;
@property (nonatomic, assign) NSInteger timeZone;
@property (nonatomic, strong) CPDeviceSchedule<Optional> *weekdaySchedule;
@property (nonatomic, strong) CPDeviceSchedule<Optional> *weekendSchedule;

@end
