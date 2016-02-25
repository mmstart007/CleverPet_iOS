//
//  CPTextValidator.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPTextValidator : NSObject

- (BOOL)isValidFamilyNameText:(NSString*)text;
- (BOOL)isValidPetAgeText:(NSString*)text;
- (BOOL)isValidPetNameText:(NSString*)text;
- (BOOL)isValidPetWeightText:(NSString*)text;

@end
