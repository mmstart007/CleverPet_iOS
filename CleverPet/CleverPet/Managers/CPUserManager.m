//
//  CPUserManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPUserManager.h"

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

@end
