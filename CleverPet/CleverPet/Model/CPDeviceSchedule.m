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
    self.startTime = [self hourFromString:self.startTimeString];
    self.endTime = [self hourFromString:self.endTimeString];;
}

- (void)updateStartTime:(NSInteger)startTime
{
    self.startTime = startTime;
    self.startTimeString = [self timeStringForTime:startTime];
}

- (void)updateEndTime:(NSInteger)endTime
{
    self.endTime = endTime;
    self.endTimeString = [self timeStringForTime:endTime];
}

- (NSString*)timeStringForTime:(NSInteger)time
{
    NSDate *newDate;
    if (time == 24) {
        // Convert next midnight to 23:59:59
        newDate = [[NSCalendar currentCalendar] dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:kNilOptions];
    } else {
        newDate = [[NSCalendar currentCalendar] dateBySettingUnit:NSCalendarUnitHour value:time ofDate:[NSDate date] options:kNilOptions];
    }
    
    return [[CPDeviceSchedule timeFormatter] stringFromDate:newDate];
}

- (NSInteger)hourFromString:(NSString*)timeString
{
    NSDateFormatter *formatter = [CPDeviceSchedule timeFormatter];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDate *date = [formatter dateFromString:timeString];
    NSDateComponents *components = [currentCalendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    NSInteger hour = components.hour;
    if (components.hour == 23 && components.minute > 0) {
        hour = 24;
    }
    return hour;
}

@end
