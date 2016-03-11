//
//  CPSharedUtils.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPSharedUtils : NSObject

@end

#pragma mark-- NSNotification Macros

#define REG_SELF_FOR_NOTIFICATION(notename, selectorMethod) \
[[NSNotificationCenter defaultCenter]                   \
addObserver:self                                    \
selector:@selector(selectorMethod)               \
name:notename                                \
object:nil]

#define REG_SELF_FOR_NOTIFICATION_ON_OBJ(notename, selectorMethod, obj) \
[[NSNotificationCenter defaultCenter]                               \
addObserver:self                                                \
selector:@selector(selectorMethod)                           \
name:notename                                            \
object:obj]

#define UNREG_SELF_FOR_NOTIFICATION(notename) \
[[NSNotificationCenter defaultCenter]     \
removeObserver:self                   \
name:notename               \
object:nil]

#define UNREG_SELF_FOR_NOTIFICATION_ON_OBJ(notename, obj) \
[[NSNotificationCenter defaultCenter]                 \
removeObserver:self                               \
name:notename                           \
object:obj]

#define UNREG_SELF_FOR_ALL_NOTIFICATIONS() \
[[NSNotificationCenter defaultCenter]  \
removeObserver:self]


#pragma mark - Blocks

#define BLOCK_SELF_REF_OUTSIDE() __weak __typeof(&*self) weakSelf = self;
#define BLOCK_SELF_REF_INSIDE() __typeof(&*self) self = weakSelf;

#pragma mark - Styling
#import "UIFont+CleverPet.h"
#import "UIColor+CleverPet.h"
#import "UIViewController+CleverPet.h"

#pragma mark - Data field max and min values
extern NSInteger const kNameFieldMinChars;
extern NSInteger const kNameFieldMaxChars;
extern NSInteger const kFamilyNameFieldMinChars;
extern NSInteger const kFamilyNameFieldMaxChars;

#pragma mark - JSON keys
extern NSString * const kErrorKey;
// User keys
extern NSString * const kUserIdKey;
extern NSString * const kEmailKey;
extern NSString * const kFirstNameKey;
extern NSString * const kLastNameKey;
extern NSString * const kAuthTokenKey;
extern NSString * const kParticleAuthKey;
extern NSString * const kFirebaseAuthTokenKey;
// Pet keys
extern NSString * const kPetIdKey;
extern NSString * const kNameKey;
extern NSString * const kFamilyNameKey;
extern NSString * const kGenderKey;
extern NSString * const kBreedKey;
extern NSString * const kWeightKey;
extern NSString * const kDOBKey;
extern NSString * const kAlteredKey;

// Gender keys. Correspond to the gender values returned by the server.
extern NSString * const kMaleKey;
extern NSString * const kFemaleKey;

// Device Keys
extern NSString * const kDeviceIdKey;
extern NSString * const kParticleIdKey;
extern NSString * const kModeKey;
extern NSString * const kSchedulesKey;
extern NSString * const kActiveMode;
extern NSString * const kStandbyMode;
extern NSString * const kSchedulerMode;
extern NSString * const kLastSeenKey;
extern NSString * const kTimeZoneKey;
// Schedule keys
extern NSString * const kScheduleIdKey;
extern NSString * const kWeekdayKey;
extern NSString * const kWeekendKey;
extern NSString * const kIsActiveKey;
extern NSString * const kStartTimeKey;
extern NSString * const kEndTimeKey;
extern NSString * const kDaysOnKey;

#define ASYNC void
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

