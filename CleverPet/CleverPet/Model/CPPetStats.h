//
//  CPPetStats.h
//  CleverPet
//
//  Created by Michelle Hillier on 2016-03-11.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CPPetStats : JSONModel

@property (nonatomic, strong) NSString *challengeName;
@property (nonatomic, strong) NSNumber *challengeNumber;
@property (nonatomic, strong) NSNumber *lifetimePoints;
@property (nonatomic, strong) NSNumber *stageNumber;
@property (nonatomic, strong) NSNumber *totalStages;
@property (nonatomic, strong) NSNumber *kibbles;
@property (nonatomic, strong) NSNumber *plays;

@end
