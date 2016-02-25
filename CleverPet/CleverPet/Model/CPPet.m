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
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{@"animal_ID":@"petId"}];
}

- (UIImage *)petPhoto
{
    if (!self.image) {
        self.image = [CPFileUtils getImageForPet:self.petId];
    }
    return self.image;
}

@end
