//
//  CPDeviceSchedule.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-02.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CPDeviceSchedule : JSONModel

@property (nonatomic, strong) NSString *scheduleId;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *daysOn;
@property (nonatomic, assign) BOOL isActive;

@end
