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
@property (nonatomic, assign, readonly) NSInteger startTime;
@property (nonatomic, assign, readonly) NSInteger endTime;

+ (BOOL)isWeekdaySchedule;
- (void)updateStartTime:(NSInteger)startTime;
- (void)updateEndTime:(NSInteger)endTime;

@end
