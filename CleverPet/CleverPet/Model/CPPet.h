//
//  CPPet.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CPPet : JSONModel

@property (nonatomic, strong) NSString *altered;
@property (nonatomic, strong) NSString *petId;
@property (nonatomic, strong) NSString *breed;
@property (nonatomic, strong) NSString *dateOfBirth;
@property (nonatomic, strong) NSString *familyName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger weight;

// TODO: Score/protocol/other nonsense

@end
