//
//  CPUserManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPUserManager.h"
#import "CPAppEngineCommunicationManager.h"
#import "CPFileUtils.h"
#import "CPLoginController.h"
#import "CPGCMManager.h"

NSString * const kPendingLogouts = @"DefaultsKey_PendingLogouts";
NSString * const kPendingLogoutGCMTokenKey = @"CPUserManager_gcmTokenKey";
NSString * const kPendingLogoutUserAuthKey = @"CPUserManager_auth";

@interface CPUserManager()

@property (nonatomic, strong) CPUser *currentUser;

@end

@implementation CPUserManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPUserManager *s_sharedInstance;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[CPUserManager alloc] init];
    });
    return s_sharedInstance;
}

- (void)userLoggedIn:(NSDictionary *)userInfo
{
    NSError *error;
    self.currentUser = [[CPUser alloc] initWithDictionary:userInfo error:&error];
    // Update to use device time zone. Probably should pull this out
    [CPSharedUtils deviceTimeZoneUpdated:self.currentUser.device.timeZone];
    // If our current user logged in, we don't need to worry about processing a pending logout for that user anymore
    [self removeUserFromPendingLogouts:self.currentUser.userId];
}

- (void)userCreatedPet:(NSDictionary *)petInfo
{
    NSError *error;
    self.currentUser.pet = [[CPPet alloc] initWithDictionary:petInfo error:&error];
    self.currentUser.weightUnits = self.currentUser.weightUnits;
}

- (void)updatePetInfo:(NSDictionary *)petInfo withCompletion:(void (^)(NSError *))completion
{
    NSDictionary *currentPetInfo = [self.currentUser.pet toDictionary];
    BOOL shouldUpdate = [self hasPetInfoChanged:petInfo];
    if (shouldUpdate) {
        NSError *error;
        [self.currentUser.pet mergeFromDictionary:petInfo useKeyMapping:YES error:&error];
        
        BLOCK_SELF_REF_OUTSIDE();
        [[CPAppEngineCommunicationManager sharedInstance] updatePet:self.currentUser.pet.petId withInfo:petInfo completion:^(NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (error) {
                [self.currentUser.pet mergeFromDictionary:currentPetInfo useKeyMapping:YES error:nil];
                if (completion) completion(error);
            } else {
                self.currentUser.weightUnits = self.currentUser.pet.weightUnits;
                // Send notification if pets name or gender has changed
                if (![currentPetInfo[kNameKey] isEqualToString:petInfo[kNameKey]] || ![currentPetInfo[kGenderKey] isEqualToString:petInfo[kGenderKey]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPetInfoUpdated object:nil];
                }
                
               if (completion) completion(nil);
            }
        }];
    }else {
        if (completion) completion(nil);
    }
}

- (BOOL)hasPetInfoChanged:(NSDictionary *)petInfo
{
    BOOL hasChanged = NO;
    NSDictionary *currentPetInfo = [self.currentUser.pet toDictionary];
    for (NSString *key in petInfo) {
        if (!currentPetInfo[key] || ![currentPetInfo[key] isEqual:petInfo[key]]) {
            hasChanged = YES;
            // Additional checking for weight, as passed in pet info will be a string, but toDict weight will be a number. Will have to do the same thing for any other primitives we may add
            if ([key isEqualToString:kWeightKey]) {
                hasChanged = [petInfo[key] floatValue] != [currentPetInfo[key] floatValue];
            }
            if (hasChanged) break;
        }
    }
    
    return hasChanged;
}

- (void)updatePetPhoto:(UIImage *)image
{
    [self.currentUser.pet setPetPhoto:image];
    [CPFileUtils saveImage:image forPet:self.currentUser.pet.petId];
}

#pragma mark - Device
- (void)userCreatedDevice:(NSDictionary *)deviceInfo
{
    NSError *error;
    self.currentUser.device = [[CPDevice alloc] initWithDictionary:deviceInfo error:&error];
    // Update to use device time zone. Probably should pull this out
    [CPSharedUtils deviceTimeZoneUpdated:self.currentUser.device.timeZone];
}

- (void)updateDeviceInfo:(NSDictionary *)deviceInfo withCompletion:(void (^)(NSError *))completion
{
    __block NSInteger pendingRequests = 0;
    __block NSError *blockError;
    void (^requestFinished)(NSError *error) = ^(NSError *error){
        if (error) {
            blockError = error;
        }
        pendingRequests--;
        if (pendingRequests == 0) {
            if (completion) completion(blockError);
        }
    };
    
    if (deviceInfo[kModeKey]) {
        NSString *oldMode = self.currentUser.device.desiredMode;
        NSString *newMode = deviceInfo[kModeKey];
        if (![oldMode isEqualToString:newMode]) {
            NSMutableDictionary *deviceUpdateDict = [[self.currentUser.device toDictionary] mutableCopy];
            deviceUpdateDict[kDesiredModeKey] = newMode;
            self.currentUser.device.desiredMode = newMode;
            pendingRequests++;
            BLOCK_SELF_REF_OUTSIDE();
            [[CPAppEngineCommunicationManager sharedInstance] updateDevice:self.currentUser.device.deviceId mode:deviceUpdateDict completion:^(NSError *error) {
                BLOCK_SELF_REF_INSIDE();
                if (error) {
                    self.currentUser.device.desiredMode = oldMode;
                }
                requestFinished(error);
            }];
        }
    }
    
    BLOCK_SELF_REF_OUTSIDE();
    void (^scheduleHandler)(CPDeviceSchedule *, NSDictionary *) = ^(CPDeviceSchedule *schedule, NSDictionary *scheduleInfo){
        BLOCK_SELF_REF_INSIDE();
        NSInteger startTime = [scheduleInfo[kStartTimeKey] integerValue];
        NSInteger endTime = [scheduleInfo[kEndTimeKey] integerValue];
        // TODO: handle midnight(24)
        
        if (schedule.startTime != startTime || schedule.endTime != endTime) {
            NSDictionary *previousSchedule = [schedule toDictionary];
            [schedule updateStartTime:startTime];
            [schedule updateEndTime:endTime];
            NSDictionary *newSchedule = [schedule toDictionary];
            
            pendingRequests++;
            [[CPAppEngineCommunicationManager sharedInstance] updateDevice:self.currentUser.device.deviceId schedule:schedule.scheduleId withInfo:newSchedule completion:^(NSError *error) {
                if (error) {
                    [schedule mergeFromDictionary:previousSchedule useKeyMapping:YES error:nil];
                }
                requestFinished(error);
            }];
        }
    };
    
    if (deviceInfo[kWeekdayKey]) {
        NSDictionary *weekdaySchedule = deviceInfo[kWeekdayKey];
        scheduleHandler(self.currentUser.device.weekdaySchedule, weekdaySchedule);
    }
    
    if (deviceInfo[kWeekendKey]) {
        NSDictionary *weekendSchedule = deviceInfo[kWeekendKey];
        scheduleHandler(self.currentUser.device.weekendSchedule, weekendSchedule);
    }
}

- (BOOL)hasDeviceInfoChanged:(NSDictionary *)deviceInfo
{
    return [self hasModeChanged:deviceInfo] || [self hasSchedule:self.currentUser.device.weekdaySchedule changed:deviceInfo[kWeekdayKey]] || [self hasSchedule:self.currentUser.device.weekendSchedule changed:deviceInfo[kWeekendKey]];
}

- (BOOL)hasModeChanged:(NSDictionary *)deviceInfo
{
    NSString *oldMode = self.currentUser.device.desiredMode;
    NSString *newMode = deviceInfo[kModeKey];
    return ![oldMode isEqualToString:newMode];
}

- (BOOL)hasSchedule:(CPDeviceSchedule *)schedule changed:(NSDictionary*)scheduleInfo
{
    NSInteger startTime = [scheduleInfo[kStartTimeKey] integerValue];
    NSInteger endTime = [scheduleInfo[kEndTimeKey] integerValue];
    
    return schedule.startTime != startTime || schedule.endTime != endTime;
}

- (unsigned int)intFromHexString:(NSString *) hexStr
{
    unsigned int hexInt = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

- (void)fetchedDeviceSchedules:(NSDictionary *)scheduleInfo
{
    NSError *error;
    NSArray *schedules = [CPDeviceSchedule arrayOfModelsFromDictionaries:scheduleInfo[kSchedulesKey] error:&error];
    // This is not robust, but will do for now
    for (CPDeviceSchedule *schedule in schedules) {
        // If Monday is present, we're a weekday. If not, we're a weekend
        char daysOn = (char)[self intFromHexString:schedule.daysOn];
        BOOL isWeekend = (daysOn & (1 << 0)) >> 0;
        if (isWeekend) {
            self.currentUser.device.weekendSchedule = schedule;
        } else {
            self.currentUser.device.weekdaySchedule = schedule;
        }
    }
}

- (CPUser*)getCurrentUser
{
    return self.currentUser;
}

- (void)logout
{
    CPUser *currentUser = self.currentUser;
    
    // TODO: Handle pending logouts that have failed. On app resume or reachability change? If we get a successful login, theoretically we can clear any pending logouts as long as the server only allows a specific push token to be associated with a single user
    self.currentUser = nil;
    [self addUserToPendingLogouts:currentUser];
    
    BLOCK_SELF_REF_OUTSIDE();
    [[CPAppEngineCommunicationManager sharedInstance] logoutWithCompletion:^(NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (!error) {
            [self removeUserFromPendingLogouts:currentUser.userId];
        }
    }];
    [[CPLoginController sharedInstance] logout];
}

- (void)clearCurrentUser
{
    self.currentUser = nil;
}

- (void)addUserToPendingLogouts:(CPUser*)user
{
    NSString *gcmToken = [[CPGCMManager sharedInstance] getToken];
    if (gcmToken) {
        // Write our user id and device token to defaults so we can attempt to remove the push on the server at a later point if the logout call fails
        NSMutableDictionary *pendingLogouts = [[[NSUserDefaults standardUserDefaults] objectForKey:kPendingLogouts] mutableCopy];
        if (!pendingLogouts) {
            pendingLogouts = [NSMutableDictionary dictionary];
        }
        
        pendingLogouts[user.userId] = @{kPendingLogoutGCMTokenKey:gcmToken, kPendingLogoutUserAuthKey:[[CPAppEngineCommunicationManager sharedInstance] currentAuthHeader]};
        [[NSUserDefaults standardUserDefaults] setObject:pendingLogouts forKey:kPendingLogouts];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)removeUserFromPendingLogouts:(NSString*)userId
{
    NSMutableDictionary *pendingLogouts = [[[NSUserDefaults standardUserDefaults] objectForKey:kPendingLogouts] mutableCopy];
    if (!pendingLogouts) {
        return;
    }
    
    pendingLogouts[userId] = nil;
    [[NSUserDefaults standardUserDefaults] setObject:pendingLogouts forKey:kPendingLogouts];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)processPendingLogouts
{
    NSDictionary *pendingLogouts = [[NSUserDefaults standardUserDefaults] objectForKey:kPendingLogouts];
    for (NSString *userId in [pendingLogouts allKeys]) {
        NSDictionary *userInfo = pendingLogouts[userId];
        BLOCK_SELF_REF_OUTSIDE();
        [[CPAppEngineCommunicationManager sharedInstance] performLogoutWithAuthHeader:userInfo[kPendingLogoutUserAuthKey] completion:^(NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (!error)
            {
                // No action to take on error, we just leave it in pending logouts to try again later
                [self removeUserFromPendingLogouts:userId];
            }
        }];
    }
}

@end
