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

NSString * const kPendingLogouts = @"DefaultsKey_PendingLogouts";

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
}

- (void)userCreatedPet:(NSDictionary *)petInfo
{
    NSError *error;
    self.currentUser.pet = [[CPPet alloc] initWithDictionary:petInfo error:&error];
}

- (void)updatePetInfo:(NSDictionary *)petInfo
{
    NSDictionary *currentPetInfo = [self.currentUser.pet toDictionary];
    BOOL shouldUpdate = NO;
    // Don't need to do anything if no fields have been updated
    for (NSString *key in petInfo) {
        if (!currentPetInfo[key] || ![currentPetInfo[key] isEqual:petInfo[key]]) {
            shouldUpdate = YES;
            // Additional checking for weight, as passed in pet info will be a string, but toDict weight will be a number. Will have to do the same thing for any other primitives we may add
            if ([key isEqualToString:kWeightKey]) {
                shouldUpdate = [petInfo[key] integerValue] != [currentPetInfo[key] integerValue];
            }
            if (shouldUpdate) break;
        }
    }
    
    if (shouldUpdate) {
        NSError *error;
        [self.currentUser.pet mergeFromDictionary:petInfo useKeyMapping:YES error:&error];
        
        BLOCK_SELF_REF_OUTSIDE();
        [[CPAppEngineCommunicationManager sharedInstance] updatePet:self.currentUser.pet.petId withInfo:petInfo completion:^(NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            // TODO: Handle failure somehow
            if (error) {
                // reset back to original info
                [self.currentUser.pet mergeFromDictionary:currentPetInfo useKeyMapping:YES error:nil];
            }
        }];
    }
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
}

- (void)updateDeviceInfo:(NSDictionary *)deviceInfo
{
    if (deviceInfo[kModeKey]) {
        NSString *oldMode = self.currentUser.device.mode;
        NSString *newMode = deviceInfo[kModeKey];
        if (![oldMode isEqualToString:newMode]) {
            self.currentUser.device.mode = newMode;
            
            BLOCK_SELF_REF_OUTSIDE();
            [[CPAppEngineCommunicationManager sharedInstance] updateDevice:self.currentUser.device.deviceId mode:newMode completion:^(NSError *error) {
                BLOCK_SELF_REF_INSIDE();
                // TODO: Handle failure
                if (error) {
                    // Reset back to original mode
                    self.currentUser.device.mode = oldMode;
                }
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
            
            BLOCK_SELF_REF_OUTSIDE();
            [[CPAppEngineCommunicationManager sharedInstance] updateDevice:self.currentUser.device.deviceId schedule:schedule.scheduleId withInfo:newSchedule completion:^(NSError *error) {
                BLOCK_SELF_REF_INSIDE();
                if (error) {
                    // TODO: handle failure
                    [schedule mergeFromDictionary:previousSchedule useKeyMapping:YES error:nil];
                }
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

- (void)fetchedDeviceSchedules:(NSDictionary *)scheduleInfo
{
    NSError *error;
    NSArray *schedules = [CPDeviceSchedule arrayOfModelsFromDictionaries:scheduleInfo[kSchedulesKey] error:&error];
//    // This is not robust, but will do for now
//    for (CPDeviceSchedule *schedule in schedules) {
//        // If Monday is present, we're a weekday. If not, we're a weekend
//        unichar daysOn = [schedule.daysOn characterAtIndex:0];
//        BOOL isWeekend = (daysOn & (1 << 0)) >> 0;
//        if (isWeekend) {
//            self.currentUser.device.weekendSchedule = schedule;
//        } else {
//            self.currentUser.device.weekdaySchedule = schedule;
//        }
//    }
    // TODO: put in the correct schedule by checking days on
    // TODO: account for not receiving the correct number of schedules
    self.currentUser.device.weekdaySchedule = [schedules firstObject];
    self.currentUser.device.weekendSchedule = [schedules lastObject];
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
            [self removeUserFromPendingLogouts:currentUser];
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
    // Write our user id and device token to defaults so we can attempt to remove the push on the server at a later point if the logout call fails
    NSMutableDictionary *pendingLogouts = [[[NSUserDefaults standardUserDefaults] objectForKey:kPendingLogouts] mutableCopy];
    if (!pendingLogouts) {
        pendingLogouts = [NSMutableDictionary dictionary];
    }
    
    // TODO: Add push token to user object
    // TODO: we aren't getting user id back from the server, either figure out something to use as an identifier(email probably works), or ask for the id
//    pendingLogouts[user.userId] = @"pushToken";
    [[NSUserDefaults standardUserDefaults] setObject:pendingLogouts forKey:kPendingLogouts];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeUserFromPendingLogouts:(CPUser*)user
{
    NSMutableDictionary *pendingLogouts = [[[NSUserDefaults standardUserDefaults] objectForKey:kPendingLogouts] mutableCopy];
    if (!pendingLogouts) {
        return;
    }
    
//    pendingLogouts[user.userId] = nil;
    [[NSUserDefaults standardUserDefaults] setObject:pendingLogouts forKey:kPendingLogouts];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
