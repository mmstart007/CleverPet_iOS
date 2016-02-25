//
//  CPTextValidator.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-23.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTextValidator.h"

@interface CPTextValidator()

@property (nonatomic, strong) NSCharacterSet *invalidNameCharacters;
@property (nonatomic, strong) NSCharacterSet *invalidFamilyNameCharacters;
@property (nonatomic, strong) NSCharacterSet *invalidNumericalCharacters;

@end

@implementation CPTextValidator

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSMutableCharacterSet *alphaSet = [NSMutableCharacterSet alphanumericCharacterSet];
        // alpha includes letter, numbers and marks, we want to remove marks
        [alphaSet formIntersectionWithCharacterSet:[[NSCharacterSet nonBaseCharacterSet] invertedSet]];
        self.invalidNameCharacters = [alphaSet invertedSet];
        
        // Family name additionally allows spaces
        [alphaSet addCharactersInString:@" "];
        [alphaSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
        self.invalidFamilyNameCharacters = [alphaSet invertedSet];
        
        self.invalidNumericalCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    }
    return self;
}

- (BOOL)isValidFamilyNameText:(NSString *)text
{
    return [text rangeOfCharacterFromSet:self.invalidFamilyNameCharacters options:NSCaseInsensitiveSearch].location == NSNotFound && [text length] <= kFamilyNameFieldMaxChars;
}

- (BOOL)isValidPetAgeText:(NSString *)text
{
    return [text rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet] options:NSCaseInsensitiveSearch].location == NSNotFound;
}

- (BOOL)isValidPetNameText:(NSString *)text
{
    return [text rangeOfCharacterFromSet:self.invalidNameCharacters options:NSCaseInsensitiveSearch].location == NSNotFound && [text length] <= kNameFieldMaxChars;
}

- (BOOL)isValidPetWeightText:(NSString *)text
{
    return [text rangeOfCharacterFromSet:self.invalidNumericalCharacters options:NSCaseInsensitiveSearch].location == NSNotFound;
}

@end
