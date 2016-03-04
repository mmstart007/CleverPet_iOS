//
//  CPPet.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPet.h"
#import "CPFileUtils.h"

@interface CPPet()

@property (nonatomic, strong) UIImage<Ignore> *image;

@end

@implementation CPPet

+ (JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{kPetIdKey:@"petId"}];
}

+ (void)validateInput:(NSDictionary*)proposedInput isInitialSetup:(BOOL)isInitialSetup completion:(void (^)(BOOL, NSString *))completion
{
    // TODO: pull this validation out(to the pet profile object?) so we can use it from settings as well
    NSString *name = proposedInput[kNameKey];
    if ([name length] < kNameFieldMinChars || [name length] > kNameFieldMaxChars) {
        if (completion) completion(NO, [NSString stringWithFormat:NSLocalizedString(@"Name must be between %d and %d characters long", @"Error message when name name does not fit requirements. First %d is minimum number of characters, second is maximum"), kNameFieldMinChars, kNameFieldMaxChars]);
        return;
    }
    
    NSString *familyName = proposedInput[kFamilyNameKey];
    if ([familyName length] < kFamilyNameFieldMinChars || [familyName length] > kFamilyNameFieldMaxChars) {
        if (completion) completion(NO, [NSString stringWithFormat:NSLocalizedString(@"Family name must be between %d and %d characters long", @"Error message when family name does not fit requirements. First %d is minimum number of characters, second is maximum"), kFamilyNameFieldMinChars, kFamilyNameFieldMaxChars]);
        return;
    }
    
    // TODO: validate is actually in the list of breeds
    NSString *breed = proposedInput[kBreedKey];
    if ([breed length] == 0) {
        if (completion) completion(NO, NSLocalizedString(@"Please enter the breed of your pet", @"Error message when pet breed is empty"));
        return;
    }
    
    // TODO: validate is actually in the list of genders
    NSString *gender = proposedInput[kGenderKey];
    if ([gender length] == 0) {
        if (completion) completion(NO, NSLocalizedString(@"Please enter the gender of your pet", @"Error message when pet gender is empty"));
        return;
    }
    
    // Age only present during initial setup
    if (isInitialSetup) {
        NSString *age = proposedInput[kDOBKey];
        if ([age length] == 0) {
            if (completion) completion(NO, NSLocalizedString(@"Please enter your pets age", @"Error message when pet age is empty"));
            return;
        }
    }
        
    NSString *weight = proposedInput[kWeightKey];
    if ([weight length] == 0) {
        if (completion) completion(NO, NSLocalizedString(@"Please enter your pets weight", @"Error message when pet weight is empty"));
        return;
    }
    
    // TODO: verify altered is one of the accepted options
    if(completion) completion(YES, nil);
}

- (UIImage *)petPhoto
{
    if (!self.image) {
        self.image = [CPFileUtils getImageForPet:self.petId];
    }
    
    if (self.image) {
        return self.image;
    } else {
        return [UIImage imageNamed:@"pet placeholder"];
    }
}

- (void)setPetPhoto:(UIImage *)image
{
    self.image = image;
}

@end
