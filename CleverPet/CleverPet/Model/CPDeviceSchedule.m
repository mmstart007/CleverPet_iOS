//
//  CPDeviceSchedule.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-02.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPDeviceSchedule.h"

@interface CPDeviceSchedule()

@property (nonatomic, strong) NSString *startTimeString;
@property (nonatomic, strong) NSString *endTimeString;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;

@end

@implementation CPDeviceSchedule

+ (JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{kScheduleIdKey:@"scheduleId", kStartTimeKey:@"startTimeString", kEndTimeKey:@"endTimeString"}];
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName
{
    // Ignore start/end time as they won't be parsed from the json, we'll be generating them from the strings(@"12:00:00") returned from the server
    if ([propertyName isEqualToString:@"startTime"] || [propertyName isEqualToString:@"endTime"]) {
        return YES;
    }
    return NO;
}

+ (NSDateFormatter*)timeFormatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *s_stringToIntFormatter;
    dispatch_once(&onceToken, ^{
        s_stringToIntFormatter = [[NSDateFormatter alloc] init];
        s_stringToIntFormatter.dateFormat = @"HH:mm:ss";
    });
    return s_stringToIntFormatter;
}

+ (BOOL)isWeekdaySchedule
{
    return NO;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    self = [super initWithDictionary:dict error:err];
    if (self) {
        [self parseTimeStrings];
    }
    return self;
}

- (void)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError *__autoreleasing *)error
{
    [super mergeFromDictionary:dict useKeyMapping:useKeyMapping error:error];
    [self parseTimeStrings];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[super toDictionary] mutableCopy];
    // Default toDict sends isActive as 1 or 0, where the server needs it to be true or false
    dict[kIsActiveKey] = dict[kIsActiveKey] ? @"true" : @"false";
    return dict;
}

- (void)parseTimeStrings
{
    NSDateFormatter *formatter = [CPDeviceSchedule timeFormatter];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDate *startDate = [formatter dateFromString:self.startTimeString];
    self.startTime = [currentCalendar component:NSCalendarUnitHour fromDate:startDate];
    NSDate *endDate = [formatter dateFromString:self.endTimeString];
    self.endTime = [currentCalendar component:NSCalendarUnitHour fromDate:endDate];
}

- (void)updateStartTime:(NSInteger)startTime
{
    self.startTime = startTime;
    NSDate *newDate = [[NSCalendar currentCalendar] dateBySettingUnit:NSCalendarUnitHour value:startTime ofDate:[NSDate date] options:kNilOptions];
    self.startTimeString = [[CPDeviceSchedule timeFormatter] stringFromDate:newDate];
}

- (void)updateEndTime:(NSInteger)endTime
{
    self.endTime = endTime;
    NSDate *newDate = [[NSCalendar currentCalendar] dateBySettingUnit:NSCalendarUnitHour value:endTime ofDate:[NSDate date] options:kNilOptions];
    self.endTimeString = [[CPDeviceSchedule timeFormatter] stringFromDate:newDate];
}

@end
