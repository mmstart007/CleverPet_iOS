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
    NSString *userId = userInfo[@"user_id"];
    [self loadUserFromDefaults:userId];
    if (!self.currentUser) {
        NSError *error;
        self.currentUser = [[CPUser alloc] initWithDictionary:userInfo error:&error];
        [self saveUserToDefaults];
    }
}

- (void)userCreatedPet:(NSDictionary *)petInfo
{
    NSError *error;
    self.currentUser.pet = [[CPPet alloc] initWithDictionary:petInfo error:&error];
    [self saveUserToDefaults];
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
            } else {
                [self saveUserToDefaults];
            }
        }];
    }
}

- (void)updatePetPhoto:(UIImage *)image
{
    [self.currentUser.pet setPetPhoto:image];
    [CPFileUtils saveImage:image forPet:self.currentUser.pet.petId];
}

- (CPUser*)getCurrentUser
{
    return self.currentUser;
}

- (void)loadUserFromDefaults:(NSString *)userId
{
    NSError *error;
    self.currentUser = [[CPUser alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:[self defaultsKeyForUser:userId]] error:&error];
}

- (void)saveUserToDefaults
{
    NSDictionary *dict = [self.currentUser toDictionary];
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:[self defaultsKeyForUser:self.currentUser.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)defaultsKeyForUser:(NSString *)userId
{
    return [NSString stringWithFormat:@"User: %@", userId];
}

- (void)logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self defaultsKeyForUser:self.currentUser.userId]];
    self.currentUser = nil;
    [[CPLoginController sharedInstance] logout];
}

@end
