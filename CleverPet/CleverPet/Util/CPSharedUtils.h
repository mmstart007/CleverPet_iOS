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
extern NSString * const kEmailKey;
extern NSString * const kFirstNameKey;
extern NSString * const kLastNameKey;
extern NSString * const kAuthTokenKey;
// Pet keys
extern NSString * const kNameKey;
extern NSString * const kFamilyNameKey;
extern NSString * const kGenderKey;
extern NSString * const kBreedKey;
extern NSString * const kWeightKey;
extern NSString * const kDOBKey;
extern NSString * const kAlteredKey;

#define ASYNC void
