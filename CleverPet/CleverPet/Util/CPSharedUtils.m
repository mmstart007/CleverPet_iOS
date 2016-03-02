//
//  CPSharedUtils.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSharedUtils.h"

NSInteger const kNameFieldMinChars = 2;
NSInteger const kNameFieldMaxChars = 10;
NSInteger const kFamilyNameFieldMinChars = 1;
NSInteger const kFamilyNameFieldMaxChars = 35;

#pragma mark - JSON keys
NSString * const kErrorKey = @"error";
// User keys
NSString * const kEmailKey = @"email";
NSString * const kFirstNameKey = @"first_name";
NSString * const kLastNameKey = @"last_name";
NSString * const kAuthTokenKey = @"auth_token";
NSString * const kParticleAuthTokenKey = @"particle_oauth_token";
NSString * const kFirebaseAuthTokenKey = @"firebase_oauth_token";
// Pet keys
NSString * const kNameKey = @"name";
NSString * const kFamilyNameKey = @"family_name";
NSString * const kGenderKey = @"gender";
NSString * const kBreedKey = @"breed";
NSString * const kWeightKey = @"weight";
NSString * const kDOBKey = @"date_of_birth";
NSString * const kAlteredKey = @"altered";
//Gender keys
NSString * const kMaleKey = @"male";
NSString * const kFemaleKey = @"female";
// Device Keys
NSString * const kDeviceIdKey = @"device_ID";
NSString * const kParticleIdKey = @"particle_ID";
NSString * const kModeKey = @"mode";
NSString * const kActiveMode = @"active";
NSString * const kStandbyMode = @"standby";
NSString * const kSchedulerMode = @"scheduler";
NSString * const kWeekdayStartKey = @"weekdayStart";
NSString * const kWeekdayEndKey = @"weekdayEnd";
NSString * const kWeekendStartKey = @"weekendStart";
NSString * const kWeekendEndKey = @"weekendEnd";
NSString * const kIsActiveKey = @"is_active";
NSString * const kStartTimeKey = @"start_time";
NSString * const kEndTimeKey = @"end_time";
NSString * const kDaysOnKey = @"days_on";

@implementation CPSharedUtils

@end
