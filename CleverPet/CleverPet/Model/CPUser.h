//
//  CPUser.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "CPPet.h"

@interface CPUser : JSONModel

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) CPPet<Optional> *pet;

@end
